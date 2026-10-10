require "base64"

module Writing
  class PublicationDocument
    attr_reader :chapters, :fonts

    def initialize(book, options)
      @book = book
      @options = options
      @fonts = PublicationFonts.new(options.font)
      converter = PublicationContent.new(options)
      has_text = false
      @chapters = options.selected_chapters(book).preload(:writing_scenes).map do |chapter|
        scenes = chapter.writing_scenes.sort_by { |scene| [ scene.position, scene.created_at, scene.id ] }
        documents = scenes.map(&:content)
        # Preserve legacy text if present; current chapters store literary text in scenes.
        documents.unshift(chapter.content) if converter.text?(chapter.content)
        has_text ||= documents.any? { |document| converter.text?(document) }
        parts = documents.map { |document| converter.render(document) }
        { title: chapter.title, id: chapter.id, html: parts.join('<div class="scene-break">* * *</div>').html_safe }
      end
      raise PublicationPdf::Error, "Nenhum texto literário disponível nos capítulos selecionados." unless has_text
    end

    def html(pages = {})
      ApplicationController.render(template: "writing_publications/document", layout: false,
        locals: { book: @book, options: @options, chapters: @chapters, pages: pages, font_css: @fonts.css, cover: cover_data })
    end

    private

    def cover_data
      return nil unless @options.include_cover && @book.cover.attached?
      return @cover_data if defined?(@cover_data)

      blob = @book.cover.blob
      data = blob.download
      type = blob.content_type
      if type == "image/webp"
        require "vips"
        data = Vips::Image.new_from_buffer(data, "").write_to_buffer(".png")
        type = "image/png"
      end
      raise PublicationPdf::Error, "A capa deve ser JPEG, PNG ou WebP." unless %w[image/jpeg image/png].include?(type)

      @cover_data = "data:#{type};base64,#{Base64.strict_encode64(data)}"
    end
  end
end
