module WritingBooksHelper
  def writing_action_label(icon, label)
    safe_join([tag.span(icon, class: "material-symbols-rounded", aria: { hidden: true }), tag.span(label)])
  end

  def writing_book_field_errors(book, field)
    return if book.errors[field].empty?

    tag.small(book.errors[field].join(", "), class: "writing-field-error", id: "writing-book-#{field}-error", role: "alert")
  end

  def writing_book_field_accessibility(book, field)
    { invalid: book.errors[field].any?, describedby: ("writing-book-#{field}-error" if book.errors[field].any?) }
  end
end
