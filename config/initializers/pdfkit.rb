PDFKit.configure do |config|
  config.wkhtmltopdf = `which wkhtmltopdf`.strip.presence || '/usr/local/bin/wkhtmltopdf'
  config.default_options = {
    page_size: 'A4',
    print_media_type: true,
    encoding: 'UTF-8',
    quiet: true,
    margin_top: '10mm',
    margin_right: '10mm',
    margin_bottom: '10mm',
    margin_left: '10mm'
  }
  config.root_url = "http://localhost:3000"
end
