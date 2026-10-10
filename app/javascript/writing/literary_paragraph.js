import Paragraph from "@tiptap/extension-paragraph"
import Heading from "@tiptap/extension-heading"
import { Extension, mergeAttributes } from "@tiptap/core"
import { DOMSerializer } from "@tiptap/pm/model"
import { Plugin } from "@tiptap/pm/state"

function alignmentAttribute() {
  return {
    default: "left",
    parseHTML: element => element.dataset.literaryAlign === "justify" || element.style.textAlign === "justify" ? "justify" : "left",
    renderHTML: attributes => ({ "data-literary-align": attributes.textAlign }),
  }
}

function narrativeSelection(state) {
  const { $from, $to } = state.selection
  return $from.depth === 1 && $to.depth === 1 && $from.sameParent($to) && $from.parent.type.name === "paragraph"
}

export const LiteraryParagraph = Paragraph.extend({
  addAttributes() {
    return {
      ...this.parent?.(),
      firstLineIndent: {
        default: true,
        parseHTML: element => {
          const value = element.getAttribute("data-literary-indent")
          if (value !== null) return value === "true"
          if (element.style.textIndent) return parseFloat(element.style.textIndent) > 0
          return !["H1", "H2", "HR"].includes(element.previousElementSibling?.tagName)
        },
        renderHTML: attributes => ({ "data-literary-indent": attributes.firstLineIndent ? "true" : "false" }),
      },
      textAlign: alignmentAttribute(),
    }
  },

  renderHTML({ HTMLAttributes }) {
    return ["p", mergeAttributes(this.options.HTMLAttributes, HTMLAttributes, { class: "literary-paragraph" }), 0]
  },
})

export const LiteraryHeading = Heading.extend({
  addAttributes() {
    return { ...this.parent?.(), textAlign: alignmentAttribute() }
  },
})

export const LiteraryEditing = Extension.create({
  name: "literaryEditing",
  priority: 1000,

  addProseMirrorPlugins() {
    return [new Plugin({
      props: {
        clipboardSerializer: {
          serializeFragment: (fragment, options, target) => {
            const dom = DOMSerializer.fromSchema(this.editor.schema).serializeFragment(fragment, options, target)
            const { $from } = this.editor.state.selection
            let nestedContext = false
            for (let depth = 1; depth <= $from.depth; depth += 1) {
              if (["listItem", "blockquote"].includes($from.node(depth).type.name)) nestedContext = true
            }
            const singleNestedParagraph = nestedContext && fragment.childCount === 1 && fragment.firstChild.type.name === "paragraph"
            dom.querySelectorAll("p").forEach(paragraph => {
              const special = singleNestedParagraph || paragraph.closest("li, blockquote")
              const indent = !special && paragraph.dataset.literaryIndent === "true"
              paragraph.dataset.literaryIndent = String(indent)
              // Clipboard HTML needs explicit styles for word processors outside this app.
              paragraph.style.textIndent = indent ? "1.25cm" : "0"
              paragraph.style.textAlign = paragraph.dataset.literaryAlign || "left"
            })
            return dom
          },
        },
      },
    })]
  },

  addCommands() {
    return {
      setFirstLineIndent: value => ({ tr, state, dispatch }) => {
        if (!narrativeSelection(state)) return false
        const { $from } = tr.selection
        if ($from.parent.attrs.firstLineIndent === value) return true
        if (dispatch) tr.setNodeMarkup($from.before(), undefined, { ...$from.parent.attrs, firstLineIndent: value })
        return true
      },
      setLiteraryAlignment: value => ({ commands }) => {
        if (!["left", "justify"].includes(value)) return false
        return commands.updateAttributes(this.editor.isActive("heading") ? "heading" : "paragraph", { textAlign: value })
      },
    }
  },

  addKeyboardShortcuts() {
    const indentNewParagraph = value => this.editor.chain().splitBlock().command(({ tr }) => {
      const { $from } = tr.selection
      if ($from.depth === 1 && $from.parent.type.name === "paragraph") {
        tr.setNodeMarkup($from.before(), undefined, { ...$from.parent.attrs, firstLineIndent: value })
      }
      return true
    }).run()

    return {
      Tab: () => this.editor.commands.setFirstLineIndent(true),
      "Shift-Tab": () => this.editor.commands.setFirstLineIndent(false),
      Enter: () => {
        if (narrativeSelection(this.editor.state)) return indentNewParagraph(true)
        const { $from, empty } = this.editor.state.selection
        if (empty && $from.depth === 1 && $from.parent.type.name === "heading" && $from.parentOffset === $from.parent.content.size) {
          return indentNewParagraph(false)
        }
        return false
      },
    }
  },
})
