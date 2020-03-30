# frozen_string_literal: true

require 'logger'

class AutomaticSat::Logger
  def self.log
    if @logger.nil?
      @logger = Logger.new STDOUT
      @logger.level = Logger::DEBUG
      @logger.datetime_format = '%Y-%m-%d %H:%M:%S '
    end
    @logger
  end

  def self.invoice_start(user_name, customer_name, amount)
    format(
      'AutomaticSat - Creating %s\'s invoice for %s for a total of %s MXN',
      user_name, customer_name, amount
    )
  end

  def self.invoice_end(user_name, customer_name, amount)
    format(
      'AutomaticSat - Created %s\'s invoice for %s for a total of %s MXN',
      user_name, customer_name, amount
    )
  end

  def self.invoice_email(user_name, customer_name, amount)
    format(
      'AutomaticSat - Sending email for %s\'s invoice for %s for a total of %s MXN',
      user_name, customer_name, amount
    )
  end

  def self.tax_return_start(user_name, sales_revenue, paid_expenses)
    format(
      'AutomaticSat - Creating %s\'s tax return sales revenue %s MXN and paid_expenses of %s MXN',
      user_name, sales_revenue, paid_expenses
    )
  end

  def self.tax_return_end(user_name, sales_revenue, paid_expenses)
    format(
      'AutomaticSat - Created %s\'s tax return sales revenue %s MXN and paid_expenses of %s MXN',
      user_name, sales_revenue, paid_expenses
    )
  end

  def self.taxes(value)
    format( 'AutomaticSat - You need to pay %s MXN :(', value)
  end
end
