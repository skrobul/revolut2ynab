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

  RSpec.describe YNABStatement do

    let(:t1) {
      instance_double(Transaction,
        description: 'some retailer',
        paid_out: 12.03,
        paid_in: 0.0,
        category: 'shopping',
        date: Date.new(2016, 3, 1)
      )
    }

    let(:t2) {
      instance_double(Transaction,
        description: 'some income',
        paid_out: 0.0,
        paid_in: 30.0,
        category: 'general',
        date: Date.new(2015, 11, 2)
      )
    }
    let(:rstatement) { instance_double(Statement, transactions: [t1, t2]) }
    let(:ystatement) { YNABStatement.from_revolut(rstatement) }

    describe '.from_revolut' do
      subject(:transactions) { ystatement.transactions }

      it 'converts expenses' do
        expect(transactions.first).to have_attributes(date: Date.new(2016, 3, 1), outflow: 12.03, inflow: 0.0, payee: 'some retailer', memo: 'shopping')
      end

      it 'converts incomes' do
        expect(transactions.last).to have_attributes(date: Date.new(2015, 11, 2), outflow: 0.0, inflow: 30.0, payee: 'some income', memo: 'general')
      end
    end

    describe '#to_csv' do
      subject(:result) { ystatement.to_csv.split("\n") }

      it 'includes the headers' do
        expect(result[0]).to eq 'Date,Payee,Memo,Outflow,Inflow'
      end

      it 'includes expenses' do
        expect(result[1]).to eq '2016-03-01,some retailer,shopping,12.03,0.0'
      end

      it 'includes income' do
        expect(result[2]).to eq '2015-11-02,some income,general,0.0,30.0'
      end
    end
  end
end
