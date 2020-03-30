# frozen_string_literal: true

class AutomaticSat
  attr_reader :users

  def initialize(users_file = './users.yml', credentials_path = './user-credentials', downloads_path = './downloads')
    file = File.read(users_file)
    @users = YAML.safe_load(file, [Symbol])
    @credentials_path = Pathname.new(credentials_path)
    @downloads_path = Pathname.new(downloads_path)
    @mailer = AutomaticSat::Mailer.new([], @downloads_path)
  end

  def generate_invoices
    users.each do |user|
      credentials = user_credentials(user)
      user[:invoices].each do |invoice_info|
        AutomaticSat::Logger.log.info(AutomaticSat::Logger.invoice_start(user[:name], invoice_info[:customer_name], invoice_info[:amount]))
        invoice_name = generate_invoice(credentials, invoice_info)
        AutomaticSat::Logger.log.info(AutomaticSat::Logger.invoice_end(user[:name], invoice_info[:customer_name], invoice_info[:amount]))
        AutomaticSat::Logger.log.info(AutomaticSat::Logger.invoice_email(user[:name], invoice_info[:customer_name], invoice_info[:amount]))
        @mailer.to = [{ email: user[:email], name: user[:name] }, { email: invoice_info[:customer_email], name: invoice_info[:customer_name] }]
        @mailer.send_invoice_email(invoice_info[:description], invoice_name)
      end
    end
  end

  def generate_taxes_return
    users.each do |user|
      credentials = user_credentials(user)
      user[:taxes_returns].each do |tax_return_info|
        AutomaticSat::Logger.log.info(AutomaticSat::Logger.tax_return_start(user[:name], tax_return_info[:sales_revenue], tax_return_info[:paid_expenses]))
        tax_return_amount = generate_tax_return(credentials, tax_return_info)
        AutomaticSat::Logger.log.info(AutomaticSat::Logger.tax_return_end(user[:name], tax_return_info[:sales_revenue], tax_return_info[:paid_expenses]))
        AutomaticSat::Logger.log.info(AutomaticSat::Logger.taxes(tax_return_amount))
      end
    end

  end

  private

  def generate_invoice(credentials, invoice_info)
    driver = AutomaticSat::Driver.create
    invoice = new_invoice(driver, credentials, invoice_info)
    invoice_name = invoice.create
    driver.quit
    invoice_name
  end

  def new_invoice(driver, credentials, invoice_info)
    AutomaticSat::Invoice.new(
      driver,
      certificate_path: credentials[:certificate_path],
      private_key_path: credentials[:private_key_path],
      private_key_password: credentials[:private_key_password],
      invoice_customer_name: invoice_info[:customer_name],
      invoice_description: invoice_info[:description],
      invoice_amount: invoice_info[:amount]
    )
  end

  def generate_tax_return(credentials, tax_return_info)
    driver = AutomaticSat::Driver.create
    tax_return = new_tax_return(driver, credentials, tax_return_info)
    tax_return_amount = tax_return.create
    driver.quit
    tax_return_amount
  end

  def new_tax_return(driver, credentials, tax_return_info)
    AutomaticSat::TaxReturn.new(
      driver,
      certificate_path: credentials[:certificate_path],
      private_key_path: credentials[:private_key_path],
      private_key_password: credentials[:private_key_password],
      period: tax_return_info[:period],
      sales_revenue: tax_return_info[:sales_revenue],
      paid_expenses: tax_return_info[:paid_expenses]
    )
  end

  def user_credentials(user)
    user_bucket = AutomaticSat::FileSearcher.find_by_name(@credentials_path, user[:rfc])
    user_certificate = AutomaticSat::FileSearcher.find_certificate(user_bucket)
    user_private_key = AutomaticSat::FileSearcher.find_private_key(user_bucket)
    user_private_key_password = AutomaticSat::FileSearcher.find_private_key_password(user_bucket)

    {
      certificate_path: public_path(user_bucket, user_certificate),
      private_key_path: public_path(user_bucket, user_private_key),
      private_key_password: file_content(user_private_key_password)
    }
  end

  def public_path(user_bucket, file)
    "#{ENV['CREDENTIALS_PATH']}#{user_bucket.basename}/#{file.basename}"
  end

  def file_content(file)
    File.open(file, &:readline)
  end
end

require 'selenium-webdriver'
require 'yaml'
require 'sendgrid-ruby'
require 'json'
require 'pry' unless ENV['APP_ENV'] == 'production'

require_relative 'automatic_sat/logger'
require_relative 'automatic_sat/driver'
require_relative 'automatic_sat/invoice'
require_relative 'automatic_sat/file_searcher'
require_relative 'automatic_sat/file_iterator'
require_relative 'automatic_sat/mailer'
require_relative 'automatic_sat/tax_return'
