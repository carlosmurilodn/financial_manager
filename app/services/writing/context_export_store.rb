module Writing
  class ContextExportStore < PublicationStore
    def self.root
      Rails.root.join("tmp/writing_context_exports")
    end

    def zip_path
      directory.join("book.zip")
    end

    private

    def interrupted_message
      "Geração interrompida por reinício do servidor. Gere um novo ZIP."
    end
  end
end
