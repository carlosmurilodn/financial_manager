module Writing
  class PublicationContent
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::OutputSafetyHelper

    def initialize(options)
      @options = options
    end

    def render(document)
      validate_document!(document)
      safe_join(document.fetch("content").map { |node| render_node(node) })
    end

    def text?(document)
      validate_document!(document)
      nodes_have_text?(Array(document["content"]))
    end

    private

    def validate_document!(document)
      unless Document.new(document, allowed_marks: Document::MARKS + [ "underline" ]).valid?
        raise PublicationPdf::Error, "O manuscrito contém estrutura ou formatação inválida. Revise o conteúdo antes de exportar."
      end
    end

    def nodes_have_text?(nodes)
      nodes.any? { |node| node["type"] == "text" ? node["text"].to_s.strip.present? : nodes_have_text?(Array(node["content"])) }
    end

    def render_node(node)
      attrs = node.fetch("attrs", {})
      children = safe_join(Array(node["content"]).map { |child| render_node(child) })
      case node["type"]
      when "text"
        Array(node["marks"]).reduce(ERB::Util.html_escape(node["text"])) do |text, mark|
          tag_name = { "bold" => :strong, "italic" => :em, "strike" => :s, "underline" => :u }.fetch(mark["type"])
          tag.public_send(tag_name, text)
        end
      when "paragraph"
        tag.p(children.presence || tag.br, class: "paragraph #{alignment(attrs)} #{attrs.fetch('firstLineIndent', true) ? 'indented' : 'unindented'}")
      when "heading"
        tag.div(children, class: "manuscript-heading heading-#{attrs.fetch('level', 1)} #{alignment(attrs)}")
      when "hardBreak" then tag.br
      when "horizontalRule" then tag.div("* * *", class: "scene-break")
      when "bulletList" then tag.ul(children)
      when "orderedList" then tag.ol(children, start: attrs.fetch("start", 1), type: attrs["type"])
      when "listItem" then tag.li(children)
      when "blockquote" then tag.blockquote(children)
      end
    end

    def alignment(attrs)
      value = @options.alignment == "manuscript" ? attrs.fetch("textAlign", "left") : @options.alignment
      "align-#{value}"
    end
  end
end
