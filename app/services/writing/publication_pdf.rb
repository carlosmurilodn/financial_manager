require "nokogiri"
require "timeout"
require "tmpdir"

module Writing
  class PublicationPdf
    class Error < StandardError; end
    TIMEOUT = 15.minutes.to_i

    def initialize(book, options, store)
      @book = book
      @options = options
      @store = store
    end

    def generate
      started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      document = PublicationDocument.new(@book, @options)
      Dir.mktmpdir("layout-", @store.directory) do |work|
        @work = Pathname.new(work)
        pages = {}
        body_start = 1
        4.times do
          @work.join("book.html").write(document.html(pages))
          write_page_furniture(body_start)
          run_renderer(started)
          absolute = outline_pages(document.chapters)
          first_page = absolute.values.first
          calculated = absolute.transform_values { |page| @options.number_front_matter ? page : page - first_page + 1 }
          if calculated == pages && first_page == body_start
            File.rename(@work.join("book.pdf"), @store.pdf_path)
            return document.fonts.family
          end
          pages = calculated
          body_start = first_page
        end
        raise Error, "Não foi possível estabilizar a paginação. Tente novamente com outras configurações."
      end
    end

    private

    def renderer_options
      margin = "#{@options.margin_mm}mm"
      {
        page_size: nil, page_width: "#{@options.page_width}mm", page_height: "#{@options.page_height}mm",
        margin_top: margin, margin_bottom: margin, margin_left: margin, margin_right: margin,
        encoding: "UTF-8", print_media_type: true, disable_smart_shrinking: true,
        disable_external_links: true, disable_local_file_access: true, allow: @work.to_s,
        disable_plugins: true, enable_javascript: true, javascript_delay: 50,
        header_html: @work.join("header.html").to_s, footer_html: @work.join("footer.html").to_s,
        header_spacing: 4, footer_spacing: 4, outline_depth: 1, dump_outline: @work.join("outline.xml").to_s,
        title: @book.title, quiet: true, load_error_handling: "abort", load_media_error_handling: "abort"
      }
    end

    def run_renderer(started)
      remaining = TIMEOUT - (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started)
      raise Error, "A geração excedeu 15 minutos. Exporte menos capítulos por vez." if remaining <= 0

      File.open(@work.join("book.html")) do |source|
        kit = PDFKit.new(source, renderer_options)
        pid = Process.spawn(*kit.command(@work.join("book.pdf")), out: File::NULL, err: @work.join("renderer.log").to_s, pgroup: true)
        _pid, status = Timeout.timeout(remaining) { Process.waitpid2(pid) }
        path = @work.join("book.pdf")
        unless status.success? && path.file? && File.binread(path, 5) == "%PDF-"
          Rails.logger.error("Writing PDF renderer failed (exit #{status.exitstatus})")
          raise Error, "Não foi possível gerar o PDF. Confira a instalação do wkhtmltopdf com Qt corrigido e tente novamente."
        end
      rescue Timeout::Error
        stop_renderer(pid)
        raise Error, "A geração excedeu 15 minutos. Exporte menos capítulos por vez."
      end
    rescue PDFKit::Error, Errno::ENOENT => error
      Rails.logger.error("Writing PDF renderer unavailable: #{error.class}")
      raise Error, "Gerador PDF indisponível. Confira a instalação do wkhtmltopdf."
    end

    def stop_renderer(pid)
      return unless pid

      Process.kill("TERM", -pid)
      Timeout.timeout(5) { Process.waitpid(pid) }
    rescue Timeout::Error
      Process.kill("KILL", -pid)
      Process.waitpid(pid)
    rescue Errno::ESRCH, Errno::ECHILD
      nil
    end

    def outline_pages(chapters)
      xml = Nokogiri::XML(@work.join("outline.xml").read) { |config| config.strict.nonet }
      items = xml.xpath("/o:outline/o:item/o:item", "o" => "http://wkhtmltopdf.org/outline")
      unless items.size == chapters.size && items.map { |item| item["title"].to_s.squish } == chapters.map { |chapter| chapter[:title].squish }
        raise Error, "Gerador não retornou a estrutura dos capítulos. Use wkhtmltopdf com Qt corrigido."
      end
      chapters.zip(items).to_h { |chapter, item| [ chapter[:id], Integer(item["page"]) ] }
    rescue Nokogiri::XML::SyntaxError, ArgumentError
      raise Error, "Não foi possível calcular as páginas do sumário."
    end

    def write_page_furniture(body_start)
      common = { options: @options, body_start: body_start }
      %w[header footer].each do |part|
        html = ApplicationController.render(template: "writing_publications/furniture", layout: false,
          locals: common.merge(part: part, title: @book.title.truncate(90)))
        @work.join("#{part}.html").write(html)
      end
    end
  end
end
