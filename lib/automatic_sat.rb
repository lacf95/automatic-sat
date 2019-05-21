# frozen_string_literal: true

require 'yaml'

class AutomaticSat
  attr_reader :users

  def initialize(users_file = './users.yml')
    file = File.read(users_file)
    @users = YAML.safe_load(file)
  end

  def generate_invoices
    users.each do |user|
      user['invoices'].each do |invoice|
        driver = AutomaticSat::Driver.create
        invoice = new_invoice(driver, user, invoice)
        invoice.create
        driver.quit
      end
    end
  end

  def new_invoice(driver, user, invoice)
    AutomaticSat::Invoice.new(
      driver,
      certificate_path: "#{ENV['CREDENTIALS_PATH']}#{user['rfc']}/#{user['certificate']}",
      private_key_path: "#{ENV['CREDENTIALS_PATH']}#{user['rfc']}/#{user['private_key']}",
      private_key_password: user['private_key_password'],
      invoice_customer_name: invoice['customer_name'],
      invoice_description: invoice['description'],
      invoice_amount: invoice['amount']
    )
  end
end

require_relative 'automatic_sat/driver'
require_relative 'automatic_sat/invoice'
