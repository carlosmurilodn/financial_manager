module WritingCharactersHelper
  def writing_character_field_errors(character, field)
    return if character.errors[field].empty?

    tag.small(character.errors[field].join(", "), class: "writing-field-error", id: "writing-character-#{field}-error", role: "alert")
  end

  def writing_character_field_accessibility(character, field)
    { invalid: character.errors[field].any?, describedby: ("writing-character-#{field}-error" if character.errors[field].any?) }
  end
end
