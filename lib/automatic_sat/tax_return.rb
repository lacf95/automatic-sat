# frozen_string_literal: true

class AutomaticSat::TaxReturn
  attr_accessor :driver

  def initialize(driver, tax_return_args)
    @driver = driver
    @tax_return_args = tax_return_args
    @taxes = nil
  end

  def create
    visit_tax_return
    enter_creation_user_credentials
    select_declaration
    fill_values
    download_files
    return @taxes
  end

  def visit_tax_return
    driver.navigate.to ENV['SAT_HOME_PAGE_URL'] + 'personas/declaraciones'
    tax_return_link = driver.find_element(link_text: 'Presenta tu declaración del RIF a través de Mis cuentas')
    driver.get(tax_return_link['href'])
    declaracion = driver.find_element(id: 'j_idt8:j_idt37')
    driver.execute_script("arguments[0].click();", declaracion)
    sleep 2
  end

  def enter_creation_user_credentials
    driver.switch_to.frame('frameCentro');
    sleep 1
    driver.find_element(id: 'buttonFiel').click
    sleep 2

    driver.find_element(id: 'fileCertificate').send_keys @tax_return_args[:certificate_path]
    driver.find_element(id: 'filePrivateKey').send_keys @tax_return_args[:private_key_path]
    driver.find_element(id: 'privateKeyPassword').send_keys @tax_return_args[:private_key_password]
    driver.find_element(id: 'submit').click
    sleep 2
  end

  def select_declaration
    driver.find_element(id: 'frmPanelRIF:cboPeriodo_label').click
    sleep 1
    driver.find_element(css: 'li[data-label="Enero - Febrero"]').click
    driver.find_element(id: 'frmPanelRIF:declarar').click
    sleep 1
    driver.find_element(id: 'frmPanelRIF:decNormCompl:0:btnCompl').click
    sleep 1
  end

  def fill_values
    sales_revenue = driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r4c2reg:txtNumber_input')
    sales_revenue.clear
    sales_revenue.send_keys(@tax_return_args[:sales_revenue])
    driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r2c2reg:txtNumber_input').send_keys('0')
    driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r3c2reg:txtNumber_input').send_keys('0')
    driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r9c2reg:txtNumber_input').send_keys('1')

    sales_revenue = driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r34c2reg:txtNumber_input')
    sales_revenue.clear
    sales_revenue.send_keys(@tax_return_args[:sales_revenue])
    paid_expenses = driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r35c2reg:txtNumber_input')
    paid_expenses.clear
    paid_expenses.send_keys(@tax_return_args[:paid_expenses])

    driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r31c1reg:j_idt61').click
    sleep 1
    driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r32c1reg:sbcAceptar').click
    sleep 1


    calculate = driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r61c1reg:j_idt61')
    driver.execute_script("arguments[0].click();", calculate)
    sleep 1
    accept = driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r62c1reg:sbcAceptar')
    driver.execute_script("arguments[0].click();", accept)
    sleep 1

    @taxes = driver.find_element(id: 'frmPagoRIF:dynaFormPagoRIF:r50c2reg:txtNumber_hinput')['value']
    driver.find_element(id: 'frmPagoRIF:btnPresentar').click
    driver.find_element(id: 'frmPagoRIF:j_idt70').click
  end

  def download_files
    driver.find_element(id: 'detalleOperacion:btnDescargar').click
  end
end
