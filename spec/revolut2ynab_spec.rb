require_relative 'spec_helper'
require_relative '../revolut2ynab'

module Revolut
  RSpec.describe Statement do
    let(:statement_file) { 'spec/example_statement.csv' }
    subject(:stm) { Statement.new(statement_file) }

    it 'parses all required transactions' do
      lines_in_file = File.open(statement_file).inject(0) { |num, _line| num += 1 }
      expect(stm.transactions.size).to eq(lines_in_file - 1)
    end

    it 'handles transactions with apostrophe in the name' do
      expect(stm.transactions).to include an_object_having_attributes(description: "Heladeria D'alicia")
    end

    it 'includes info about currency exchanged out' do
      expect(stm.transactions).to include an_object_having_attributes(exchange_out: 'EUR 17.85')
    end

    it 'includes paid out for native transactions' do
      expect(stm.transactions).to include an_object_having_attributes(description: 'Gather   Gather', paid_out: 3.30)
    end

    it 'includes category' do
      expect(stm.transactions).to include an_object_having_attributes(category: 'health', paid_out: 7.92)
    end

    it 'includes the notes' do
      expect(stm.transactions).to include an_object_having_attributes(notes: 'my reference note')
    end

    it 'parses the date' do
      expect(stm.transactions).to include an_object_having_attributes(date: Date.new(2018, 6, 19))
    end

    it 'includes balance' do
      expect(stm.transactions).to include an_object_having_attributes(balance: 64.28)
    end

    it 'returns transactions ordered by date (newest first)' do
      dates = stm.transactions.map(&:date)
      expect(dates.sort.reverse).to eq dates
    end
  end
end
