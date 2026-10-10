class WritingBackupsController < ApplicationController
  def create
    result = Backups::DatabaseDump.call(full_database: true)
    response.headers["Cache-Control"] = "private, no-store"
    send_data result.data, filename: result.filename, type: result.content_type, disposition: "attachment"
  rescue Backups::DatabaseDump::Error => e
    Rails.logger.error("Writing studio backup failed: #{e.class} - #{e.message}")
    redirect_to writing_books_path, alert: "Não foi possível gerar o backup: #{e.message}", status: :see_other
  rescue Errno::ENOENT
    redirect_to writing_books_path, alert: "Não foi possível gerar o backup. pg_dump não está disponível no servidor.", status: :see_other
  end
end
