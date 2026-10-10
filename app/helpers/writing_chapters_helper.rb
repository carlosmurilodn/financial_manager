module WritingChaptersHelper
  def literary_manuscript_html(document)
    return literary_document_html(document.content) unless document.is_a?(WritingChapter)

    parts = []
    document.writing_scenes.ordered.each do |scene|
      parts << tag.hr(class: "literary-scene-break") if parts.any?(&:present?)
      parts << literary_document_html(scene.content)
    end
    safe_join(parts)
  end

  def literary_document_html(document)
    safe_join(Array(document["content"]).map { |node| literary_node_html(node) })
  end

  def literary_node_html(node)
    attrs = node.fetch("attrs", {})
    children = safe_join(Array(node["content"]).map { |child| literary_node_html(child) })
    case node["type"]
    when "text"
      Array(node["marks"]).reduce(ERB::Util.html_escape(node["text"])) do |text, mark|
        case mark["type"]
        when "bold" then tag.strong(text)
        when "italic" then tag.em(text)
        when "strike" then tag.s(text)
        else text
        end
      end
    when "paragraph"
      indent = attrs.fetch("firstLineIndent", true)
      tag.p(children, class: "literary-paragraph", data: { literary_indent: indent, literary_align: attrs.fetch("textAlign", "left") })
    when "heading"
      tag.public_send(attrs.fetch("level", 1) == 2 ? :h2 : :h1, children, data: { literary_align: attrs.fetch("textAlign", "left") })
    when "hardBreak" then tag.br
    when "horizontalRule" then tag.hr(class: "literary-scene-break")
    when "bulletList" then tag.ul(children)
    when "orderedList" then tag.ol(children, start: attrs.fetch("start", 1), type: attrs["type"])
    when "listItem" then tag.li(children)
    when "blockquote" then tag.blockquote(children)
    end
  end
end
