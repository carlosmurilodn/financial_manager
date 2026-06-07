module TurboStreamResponses
  private

  def turbo_flash_stream(message, type: :notice)
    flash.now[type] = message
    turbo_stream.update("app-flash-container", partial: "shared/flash_messages")
  end

  def turbo_visit_stream(url)
    turbo_stream.append(
      "modal",
      "<turbo-stream action='visit' target='_top' url='#{url}'></turbo-stream>".html_safe
    )
  end
end
