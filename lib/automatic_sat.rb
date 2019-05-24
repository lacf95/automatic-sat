# frozen_string_literal: true

class AutomaticSat
  attr_reader :users

  def initialize(users_file = './users.yml', credentials_path = './user-credentials')
    file = File.read(users_file)
    @users = YAML.safe_load(file, [Symbol])
    @credentials_path = Pathname.new(credentials_path)
  end

  def generate_invoices
    users.each do |user|
      credentials = user_credentials(user)
      user[:invoices].each do |invoice_info|
        driver = AutomaticSat::Driver.create
        invoice = new_invoice(driver, credentials, invoice_info)
        AutomaticSat::Logger.log.info "AutomaticSat - Creating #{user[:name]}'s invoice for #{invoice_info[:customer_name]} for a total of #{invoice_info[:amount]} MXN"
        invoice.create
        driver.quit
        AutomaticSat::Logger.log.info "AutomaticSat - Created #{user[:name]}'s invoice for #{invoice_info[:customer_name]} for a total of #{invoice_info[:amount]} MXN"
      end
    end
  end

  private

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
require 'pry' unless ENV['ENV'] == 'production'

require_relative 'automatic_sat/logger'
require_relative 'automatic_sat/driver'
require_relative 'automatic_sat/invoice'
require_relative 'automatic_sat/file_searcher'
