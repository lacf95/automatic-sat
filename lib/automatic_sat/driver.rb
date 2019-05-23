# frozen_string_literal: true

require 'selenium-webdriver'

class AutomaticSat::Driver
  def self.create(selenium_url = ENV['SELENIUM_URL'])
    driver = Selenium::WebDriver.for :remote, url: selenium_url, desired_capabilities: capabilities
    driver.manage.timeouts.implicit_wait = 2
    driver
  end

  def self.capabilities
    capabilities = Selenium::WebDriver::Remote::Capabilities.firefox firefox_profile: firefox_profile
    unless ENV['DEBUG_MODE'] == 'true'
      capabilities['moz:firefoxOptions'] = {
        args: ['-headless']
      }
    end
    capabilities
  end

  def self.firefox_profile
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile['browser.privatebrowsing.autostart'] = true
    profile['browser.download.dir'] = '/downloads'
    profile['browser.download.folderList'] = 2
    profile['browser.helperApps.neverAsk.saveToDisk'] = 'application/pdf, text/xml'
    profile['pdfjs.disabled'] = true
    profile
  end

  private_class_method :capabilities
  private_class_method :firefox_profile
end
