require "spec_helper"
require "date"
require "active_support/core_ext/date/calculations"
require "active_support/core_ext/time/calculations"
require_relative "../../../app/services/cards/pay_invoice"

RSpec.describe Cards::PayInvoice do
  describe ".call" do
    it "marks unpaid card expenses from the selected invoice month as paid" do
      now = Time.new(2026, 6, 7, 15, 30, 0)
      user = double("user")
      balance_month = Date.new(2026, 6, 1)
      initial_scope = double("initial_scope")
      user_scope = double("user_scope")
      unpaid_scope = double("unpaid_scope")
      invoice_scope = double("invoice_scope")
      card = double("card", expenses: initial_scope)

      stub_const("Expense", Class.new do
        def self.card_payment_method_values; end
      end)
      stub_const("ActiveRecord", Module.new)
      stub_const("ActiveRecord::Base", Class.new do
        def self.transaction; end
      end)
      allow(Expense).to receive(:card_payment_method_values).and_return([ 2, 3, 5 ])
      allow(Time).to receive(:current).and_return(now)
      allow(ActiveRecord::Base).to receive(:transaction).and_yield

      expect(initial_scope).to receive(:where)
        .with(user: user)
        .and_return(user_scope)
      expect(user_scope).to receive(:where)
        .with(paid: false, payment_method: [ 2, 3, 5 ])
        .and_return(unpaid_scope)
      expect(unpaid_scope).to receive(:where)
        .with(balance_month: Date.new(2026, 6, 1)..Date.new(2026, 6, 30))
        .and_return(invoice_scope)
      expect(invoice_scope).to receive(:update_all)
        .with(paid: true, paid_at: now, updated_at: now)

      described_class.call(card: card, user: user, balance_month: balance_month)
    end
  end
end
