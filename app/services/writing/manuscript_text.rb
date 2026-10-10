module Writing
  class ManuscriptText
    WORD_PATTERN = /\p{L}[\p{L}\p{M}\p{N}]*(?:[’']\p{L}[\p{L}\p{M}\p{N}]*)*|\p{N}+(?:[.,]\p{N}+)*/u

    attr_reader :text, :paragraph_sizes, :words

    def initialize(documents)
      @blocks = []
      @paragraph_sizes = []
      documents.each do |document|
        visit(document) if Document.new(document).valid?
      end
      @text = @blocks.join("\n\n").unicode_normalize(:nfc)
      @words = self.class.words(@text)
    end

    def self.words(text)
      text.unicode_normalize(:nfc).downcase.scan(WORD_PATTERN)
    end

    def metrics
      { words: words.size, characters: text.length, characters_without_spaces: text.gsub(/[[:space:]]/, "").length,
        paragraphs: paragraph_sizes.size }
    end

    private

    def visit(node)
      if %w[paragraph heading].include?(node["type"])
        value = node.fetch("content", []).map { |child| child["type"] == "hardBreak" ? "\n" : child.fetch("text", "") }.join
        return if value.strip.empty?

        @blocks << value
        @paragraph_sizes << self.class.words(value).size if node["type"] == "paragraph"
      else
        node.fetch("content", []).each { |child| visit(child) }
      end
    end
  end
end
