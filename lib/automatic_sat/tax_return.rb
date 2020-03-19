# frozen_string_literal: true

class AutomaticSat::TaxReturn
  attr_accessor :driver

  def initialize(driver, tax_return_args)
    @driver = driver
    @invoice_args = tax_return_args
  end

  def create
    visit_tax_return
    enter_creation_user_credentials
    fill_values
    download_files
  end

  def visit_tax_return
    driver.navigate.to ENV['SAT_HOME_PAGE_URL'] + 'personas/declaraciones'
    tax_return_link = driver.find_element(link_text: 'Presenta tu declaración del RIF a través de Mis cuentas')
    tax_return_link.click
    driver.find_element(id: 'j_idt8:j_idt37').click
    sleep 2
  end

  def enter_creation_user_credentials
    driver.find_element(id: 'buttonFiel').click
    sleep 2

    driver.find_element(id: 'fileCertificate').send_keys @invoice_args[:certificate_path]
    driver.find_element(id: 'filePrivateKey').send_keys @invoice_args[:private_key_path]
    driver.find_element(id: 'privateKeyPassword').send_keys @invoice_args[:private_key_password]
    driver.find_element(id: 'submit').click
    sleep 2
  end

  def fill_values
    driver.find_element(id: 'frmPanelRIF:cboPeriodo_label').click
    sleep 1
    driver.find_element(css: 'li[data-label="Enero - Febrero"]')
    amount_field = driver.find_element(id: 'ValorUnitario')
    amount_field.clear
    amount_field.send_keys(amount)
  end

  def download_files
  end
end
