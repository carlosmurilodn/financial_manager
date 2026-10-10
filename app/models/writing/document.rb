module Writing
  class Document
    BLOCKS = %w[paragraph heading horizontalRule bulletList orderedList blockquote].freeze
    MARKS = %w[bold italic strike].freeze
    CHILDREN = {
      "doc" => BLOCKS,
      "paragraph" => %w[text hardBreak], "heading" => %w[text hardBreak],
      "blockquote" => BLOCKS, "listItem" => BLOCKS,
      "bulletList" => %w[listItem], "orderedList" => %w[listItem],
      "horizontalRule" => [], "hardBreak" => [], "text" => []
    }.freeze
    MAX_BYTES = 5.megabytes
    MAX_DEPTH = 32

    def initialize(content, allowed_marks: MARKS)
      @content = content
      @allowed_marks = allowed_marks
    end

    def valid?
      @content.is_a?(Hash) && @content["type"] == "doc" &&
        @content.to_json.bytesize <= MAX_BYTES && valid_node?(@content, 0)
    end

    private

    def valid_node?(node, depth)
      return false if depth > MAX_DEPTH || !node.is_a?(Hash)

      type = node["type"]
      return false unless CHILDREN.key?(type)
      return false unless (node.keys - %w[type attrs content text marks]).empty?
      return false unless valid_attributes?(type, node.fetch("attrs", {}))
      return false unless valid_marks?(node.fetch("marks", []))
      return false if type != "text" && node.key?("text")
      return false if type != "text" && node.fetch("marks", []).any?
      return valid_text?(node) if type == "text"

      children = node.fetch("content", [])
      return false unless children.is_a?(Array)
      return false if %w[doc blockquote listItem bulletList orderedList].include?(type) && children.empty?
      return false if type == "listItem" && (!children.first.is_a?(Hash) || children.first["type"] != "paragraph")

      children.all? do |child|
        child.is_a?(Hash) && CHILDREN[type].include?(child["type"]) && valid_node?(child, depth + 1)
      end
    end

    def valid_text?(node)
      node["text"].is_a?(String) && !node["text"].empty? && !node.key?("content")
    end

    def valid_marks?(marks)
      marks.is_a?(Array) && marks.all? { |mark| mark.is_a?(Hash) && mark.keys == [ "type" ] && @allowed_marks.include?(mark["type"]) }
    end

    def valid_attributes?(type, attrs)
      return false unless attrs.is_a?(Hash)

      case type
      when "paragraph"
        (attrs.keys - %w[firstLineIndent textAlign]).empty? &&
          [ true, false ].include?(attrs.fetch("firstLineIndent", true)) && valid_alignment?(attrs)
      when "heading"
        (attrs.keys - %w[level textAlign]).empty? && [ 1, 2 ].include?(attrs.fetch("level", 1)) && valid_alignment?(attrs)
      when "orderedList"
        (attrs.keys - %w[start type]).empty? && attrs.fetch("start", 1).is_a?(Integer) &&
          attrs.fetch("start", 1).positive? && [ nil, "1", "a", "A", "i", "I" ].include?(attrs["type"])
      else
        attrs.empty?
      end
    end

    def valid_alignment?(attrs)
      %w[left justify].include?(attrs.fetch("textAlign", "left"))
    end
  end
end
