require "base64"

module Writing
  class PublicationFonts
    FILES = {
      "Georgia" => %w[georgia.ttf georgiab.ttf georgiai.ttf georgiaz.ttf],
      "Times New Roman" => %w[times.ttf timesbd.ttf timesi.ttf timesbi.ttf],
      "Liberation Serif" => %w[LiberationSerif-Regular.ttf LiberationSerif-Bold.ttf LiberationSerif-Italic.ttf LiberationSerif-BoldItalic.ttf]
    }.freeze
    STYLES = [ [ "normal", "normal" ], [ "bold", "normal" ], [ "normal", "italic" ], [ "bold", "italic" ] ].freeze
    attr_reader :family

    def initialize(requested)
      @paths = font_paths(requested)
      @family = requested
      unless @paths
        @family = "Liberation Serif"
        @paths = font_paths(@family)
      end
    end

    def css
      @paths.each_with_index.map do |path, index|
        weight, style = STYLES[index]
        data = Base64.strict_encode64(File.binread(path))
        "@font-face { font-family: 'Publication Serif'; font-weight: #{weight}; font-style: #{style}; src: url(data:font/truetype;base64,#{data}) format('truetype'); }"
      end.join("\n")
    end

    private

    def font_paths(family)
      directories = if family == "Liberation Serif"
        [ Rails.root.join("vendor/fonts/publication") ]
      else
        [ ENV["WRITING_PDF_FONT_DIR"], "/usr/share/fonts/truetype/msttcorefonts", "/usr/local/share/fonts", "/mnt/c/Windows/Fonts" ].compact
      end
      directories.each do |directory|
        paths = FILES.fetch(family).map { |name| File.join(directory, name) }
        return paths if paths.all? { |path| File.file?(path) && File.readable?(path) }
      end
      nil
    end
  end
end
