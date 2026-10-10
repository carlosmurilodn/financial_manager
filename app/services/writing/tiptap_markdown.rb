module Writing
  class TiptapMarkdown
    class Error < StandardError; end

    def self.escape(text)
      text.to_s.gsub(/([\\`*_{}\[\]()#+.!|>~\-])/) { |character| "\\#{character}" }
        .gsub("&", "&amp;").gsub("<", "&lt;").gsub("\r\n", "\n")
    end

    def render(document)
      unless Document.new(document, allowed_marks: Document::MARKS + [ "underline" ]).valid?
        raise Error, "O manuscrito contém estrutura inválida. Revise o conteúdo antes de exportar."
      end

      render_node(document).strip
    end

    private

    def render_node(node)
      children = Array(node["content"])
      case node["type"]
      when "text"
        text = self.class.escape(node.fetch("text"))
        delimiters = { "bold" => "**", "italic" => "*", "strike" => "~~" }
        Array(node["marks"]).each do |mark|
          delimiter = delimiters[mark["type"]]
          next unless delimiter

          text = text.sub(/\A(\s*)(.*?)(\s*)\z/m) do
            "#{Regexp.last_match(1)}#{delimiter}#{Regexp.last_match(2)}#{delimiter}#{Regexp.last_match(3)}"
          end
        end
        text
      when "paragraph" then children.map { |child| render_node(child) }.join
      when "heading" then "#{'#' * node.fetch('attrs', {}).fetch('level', 1)} #{children.map { |child| render_node(child) }.join}"
      when "hardBreak" then "  \n"
      when "horizontalRule" then "* * *"
      when "blockquote"
        children.map { |child| render_node(child) }.join("\n\n").lines.map { |line| "> #{line}" }.join
      when "bulletList", "orderedList"
        start = node.fetch("attrs", {}).fetch("start", 1)
        children.each_with_index.map do |child, index|
          prefix = node["type"] == "orderedList" ? "#{start + index}. " : "- "
          lines = render_node(child).split("\n", -1)
          prefix + lines.first.to_s + lines.drop(1).map { |line| "\n#{' ' * prefix.length}#{line}" }.join
        end.join("\n")
      else
        children.map { |child| render_node(child) }.join("\n\n")
      end
    end
  end
end
