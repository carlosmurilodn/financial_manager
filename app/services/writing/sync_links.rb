module Writing
  class SyncLinks
    def initialize(book, scope, targets)
      @book, @scope, @targets = book, scope, targets
    end

    def call(selected)
      desired = selected.map { |association, record| [ association.to_sym, record.id ] }.uniq
      existing = @scope.to_a
      existing.each do |link|
        association = @targets.find { |target| link.public_send("#{target}_id").present? }
        pair = [ association, link.public_send("#{association}_id") ]
        desired.delete(pair) ? nil : link.destroy!
      end
      desired.each { |association, id| @scope.create!(writing_book: @book, "#{association}_id" => id) }
    end
  end
end
