# frozen_string_literal: true

require 'selenium-webdriver'

class AutomaticSat::Invoice
  attr_accessor :driver

  def initialize(driver, invoice_args)
    @driver = driver
    @invoice_args = invoice_args
  end

  def create
    visit_create_invoice_page
    fill_customer_invoice_data
    go_to_voucher_section
    add_concept(@invoice_args[:invoice_amount], @invoice_args[:invoice_description])
    validate_voucher
    enter_confirmation_user_credentials
    download_files
  end

  private

  def visit_create_invoice_page
    visit_main_invoice_page
    enter_creation_user_credentials
    driver.find_element(id: 'menuDesplegable').click
    sleep 2
  end

  def visit_main_invoice_page
    driver.navigate.to ENV['SAT_HOME_PAGE_URL']
    driver.find_element(css: 'a[alt="/personas/factura-electronica"]').click
    invoice_creation_link = driver.find_element(link_text: 'Genera tu factura')
    driver.execute_script("arguments[0].target='_self';", invoice_creation_link)
    invoice_creation_link.click
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

  def fill_customer_invoice_data
    customer_dropdown = driver.find_element(id: 'Receptor_RfcCargado')
    customer_dropdown_options = Selenium::WebDriver::Support::Select.new(customer_dropdown)
    customer_dropdown_options.select_by(:text, @invoice_args[:invoice_customer_name])
    sleep 2
  end

  def go_to_voucher_section
    driver.find_element(css: '.btn.btn-primary').click
    sleep 2
  end

  def add_concept(amount, description)
    driver.find_element(id: 'btnMuestraConcepto').click
    sleep 2

    driver.find_element(id: 'ClaveProdServ').send_keys(:arrow_down, :tab)
    sleep 1

    add_amount(amount)
    add_description(description)
    go_to_taxs_section
    go_to_concepts_section
    confirm_concept
  end

  def add_amount(amount)
    amount_field = driver.find_element(id: 'ValorUnitario')
    amount_field.clear
    amount_field.send_keys(amount)
  end

  def add_description(description)
    description_field = driver.find_element(id: 'Descripcion')
    description_field.clear
    description_field.send_keys(description)
  end

  def go_to_taxs_section
    driver.find_element(css: 'a[href="#tabImpuestos"]').click
    sleep 1
  end

  def go_to_concepts_section
    driver.find_element(id: 'CondicionesDePago').send_keys(:arrow_left)
    driver.find_element(css: 'a[href="#tabConceptos"]').click
    sleep 1
  end

  def confirm_concept
    driver.find_element(css: '#tabConceptos #btnAceptarModal').click
    sleep 1
  end

  def validate_voucher
    driver.find_element(css: 'button[formaction="/Comprobante/ValidarComprobante"]').click
    sleep 1
  end

  def enter_confirmation_user_credentials
    driver.find_element(id: 'certificate').send_keys @invoice_args[:certificate_path]
    driver.find_element(id: 'privateKey').send_keys @invoice_args[:private_key_path]
    driver.find_element(id: 'privateKeyPassword').send_keys @invoice_args[:private_key_password]
    driver.find_element(id: 'btnValidaOSCP').click
    sleep 3

    driver.find_element(id: 'btnFirmar').click
    sleep 2
  end

  def download_files
    driver.find_element(css: 'span[title="Descargar archivo XML"]').click
    driver.find_element(css: 'span[title="Descargar representación impresa"]').click
  end
end
