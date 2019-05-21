# frozen_string_literal: true

require 'selenium-webdriver'

class AutomaticSat::Driver
  def self.create(selenium_url = ENV['SELENIUM_URL'])
    profile = Selenium::WebDriver::Firefox::Profile.new

    profile['browser.download.dir'] = '/downloads'
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/pdf, text/xml'
    profile['pdfjs.disabled'] = true

    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox(firefox_profile: profile)

    driver = Selenium::WebDriver.for :remote, url: selenium_url, desired_capabilities: capabilities

    driver.manage.timeouts.implicit_wait = 2

    driver
  end
end
