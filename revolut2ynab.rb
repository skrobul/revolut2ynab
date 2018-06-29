#!/usr/bin/env ruby
require 'csv'

module Revolut
  Transaction = Struct.new(:date, :description, :paid_out, :paid_in, :exchange_out, :exchange_in, :balance, :category, :notes)
  class Statement
    attr_reader :path
    def initialize(path)
      @path = path
    end

    def transactions
      @transactions ||= parse_statement
    end

    def parse_statement
      CSV.read(path, col_sep: '; ', headers: true).map do |row|
        Transaction.new(
          Date.parse(row.fetch('Completed Date ')),
          row.fetch('Description ').sub(/ FX Rate .*/, '').strip,
          row.fetch('Paid Out (GBP) ').strip.to_f,
          row.fetch('Paid In (GBP) ').strip.to_f,
          row.fetch('Exchange Out').lstrip.rstrip,
          row.fetch('Exchange In').lstrip.rstrip,
          Float(row.fetch('Balance (GBP)')),
          row.fetch('Category'),
          row.fetch('Notes')
        )
      end
    end

    private

    def extract_rate(desc)
      desc.split(' FX Rate ')
    end
  end
end


#Revolut::Statement.new($1)
