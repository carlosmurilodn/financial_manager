module Writing
  class PublicationOptions
    include ActiveModel::Model
    include ActiveModel::Attributes

    FORMATS = { "a5" => [ "A5 — Livro Tradicional (14,8 × 21 cm)", 148, 210 ], "a4" => [ "A4 — Manuscrito Para Revisão", 210, 297 ], "editorial" => [ "Editorial — 16 × 23 cm", 160, 230 ] }.freeze
    FONTS = [ "Georgia", "Times New Roman", "Liberation Serif" ].freeze
    LINE_HEIGHTS = { "1.0" => "1,0", "1.15" => "1,15", "1.5" => "1,5", "2.0" => "2,0" }.freeze
    MARGINS = { "standard" => [ "Padrão — 20 mm", 20 ], "narrow" => [ "Estreitas — 15 mm", 15 ], "wide" => [ "Amplas — 25 mm", 25 ] }.freeze
    ALIGNMENTS = { "manuscript" => "Original Do Manuscrito", "left" => "Esquerda", "justify" => "Justificado" }.freeze
    FLAGS = { "include_cover" => "Incluir Capa Do Livro", "include_title_page" => "Incluir Folha De Rosto", "include_toc" => "Gerar Sumário", "paginate" => "Numerar Páginas", "number_front_matter" => "Numerar Também Páginas Iniciais" }.freeze

    attribute :page_format, :string, default: "a5"
    attribute :font, :string, default: "Georgia"
    attribute :font_size, :integer, default: 12
    attribute :line_height, :string, default: "1.5"
    attribute :alignment, :string, default: "manuscript"
    attribute :margins, :string, default: "standard"
    attribute :content_scope, :string, default: "all"
    attribute :chapter_ids, default: -> { [] }
    FLAGS.each_key { |flag| attribute flag, :boolean, default: flag != "number_front_matter" }

    validates :page_format, inclusion: { in: FORMATS.keys }
    validates :font, inclusion: { in: FONTS }
    validates :font_size, inclusion: { in: 10..14 }
    validates :line_height, inclusion: { in: LINE_HEIGHTS.keys }
    validates :alignment, inclusion: { in: ALIGNMENTS.keys }
    validates :margins, inclusion: { in: MARGINS.keys }
    validates :content_scope, inclusion: { in: %w[all selected] }
    validate :valid_chapter_selection

    def selected_chapters(book)
      scope = book.writing_chapters.ordered
      return scope if content_scope == "all"

      book.writing_chapters.find(chapter_ids)
      scope.where(id: chapter_ids)
    end

    def page_width
      FORMATS.fetch(page_format)[1]
    end

    def page_height
      FORMATS.fetch(page_format)[2]
    end

    def margin_mm
      MARGINS.fetch(margins)[1]
    end

    private

    def valid_chapter_selection
      if !chapter_ids.is_a?(Array) || chapter_ids.any? { |id| !id.to_s.match?(/\A[1-9]\d*\z/) }
        errors.add(:base, "Seleção de capítulos inválida.")
      elsif content_scope == "selected" && chapter_ids.empty?
        errors.add(:base, "Selecione pelo menos um capítulo.")
      end
    end
  end
end
