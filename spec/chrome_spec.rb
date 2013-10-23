require 'spec_helper'

Capybara.register_driver :chrome do |app|
  require 'selenium-webdriver'
  driver = if %x[uname -sr].chomp =~ /Linux.*stab/
    Capybara::Selenium::Driver.new(app, :browser => :chrome, :switches => %w[--no-sandbox])
  else
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end

  browser = driver.browser
  max_width, max_height = browser.execute_script("return [window.screen.availWidth, window.screen.availHeight];")

  # the window to left top position and maximize it to the screen height/width
  browser.manage.window.position = Selenium::WebDriver::Point.new(0,0)
  browser.manage.window.resize_to(max_width, max_height)
  driver
end

module TestSessions
  Chrome = Capybara::Session.new(:chrome, TestApp)
end

Capybara::SpecHelper.run_specs TestSessions::Chrome, "chrome", :skip => [
  :response_headers,
  :status_code,
  :trigger
]

describe Capybara::Session do
  context 'with selenium driver' do
    before do
      @session = TestSessions::Chrome
    end

    describe '#driver' do
      it "should be a selenium driver" do
        @session.driver.should be_an_instance_of(Capybara::Selenium::Driver)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :selenium
      end
    end

    describe "exit codes" do
      before do
        @current_dir = Dir.getwd
        Dir.chdir(File.join(File.dirname(__FILE__), '..'))
      end

      after do
        Dir.chdir(@current_dir)
      end

      it "should have return code 1 when running selenium_driver_rspec_failure.rb" do
        `rspec spec/fixtures/selenium_driver_rspec_failure.rb`
        $?.exitstatus.should be 1
      end

      it "should have return code 0 when running selenium_driver_rspec_success.rb" do
        `rspec spec/fixtures/selenium_driver_rspec_success.rb`
        $?.exitstatus.should be 0
      end
    end
  end
end
