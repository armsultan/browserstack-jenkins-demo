require 'rubygems'
require 'selenium-webdriver'
USER_NAME = ENV['BROWSERSTACK_USERNAME']
ACCESS_KEY = ENV['BROWSERSTACK_ACCESS_KEY']
def run_session(bstack_options)
 caps = Selenium::WebDriver::Remote::Capabilities.new
 caps["browserstack.networkLogs"] = "true"
 options = Selenium::WebDriver::Options.send "chrome"
 options.browser_name = bstack_options["browserName"].downcase
 options.add_option('bstack:options', bstack_options)
 driver = Selenium::WebDriver.for(:remote,
   :url => "https://#{USER_NAME}:#{ACCESS_KEY}@hub.browserstack.com/wd/hub",
   :capabilities => options)
 begin
  # Navigate home
  driver.navigate.to "https://www.armand.nz"
  if driver.find_element(:partial_link_text, 'Linkedin')
    driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"passed", "reason": "Link found, page loaded!"}}')
  else
    driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Title not matched"}}')
  end
  # Navigate to Search 
  driver.find_element(:link_text, "Search").click #Assuming there is only one "Search", either ways it will click the first "Search" link
  if driver.title == "Search"
    driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"passed", "reason": "Search page loaded!"}}')
  else
    driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Search page failed to load"}}')
  end
  # Search keyword
  element = driver.find_element(:name, "q")
  wait = Selenium::WebDriver::Wait.new(:timeout => 5) # seconds
  element.send_keys "raspberry"
  element.submit
  wait = Selenium::WebDriver::Wait.new(:timeout => 5) # seconds
   if driver.find_element(:partial_link_text, 'Raspberry')
     driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"passed", "reason": "Search results found!"}}')
   else
     driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Search failed"}}')
   end
  driver.find_element(:partial_link_text, "Raspberry").click #Assuming there is only one "Raspberry", either ways it will click the first "Raspberry" link
  rescue
   driver.execute_script('browserstack_executor: {"action": "setSessionStatus", "arguments": {"status":"failed", "reason": "Test failed"}}')
 end
 driver.quit
end
BUILD_NAME = ENV['BROWSERSTACK_BUILD_NAME'] 
#https://www.browserstack.com/app-automate/capabilities?tag=w3c
caps = [{
  "browserName" => "Chrome",
  "browserVersion" => "103.0",
  "os" => "Windows",
  "osVersion" => "11",
  "buildName" => BUILD_NAME,
  "sessionName" => "Chrome 103.0 on Windows",
  "networkLogs" => "true"
},
{
  "browserName" => "Firefox",
  "browserVersion" => "102.0",
  "os" => "Windows",
  "osVersion" => "10",
  "buildName" => BUILD_NAME,
  "sessionName" => "Firefox 102.0 on Windows",
  "networkLogs" => "true"
},
{
  "browserName" => "Safari",
  "browserVersion" => "14.1",
  "os" => "OS X",
  "osVersion" => "Big Sur",
  "buildName" => BUILD_NAME,
  "sessionName" => "Safari 14.1 on OS X",
  "networkLogs" => "true"
},
{
  "browserName" => "android",
  "deviceName" => "Samsung Galaxy S22 Ultra",
  "osVersion" => "12.0",
  "buildName" => BUILD_NAME,
  "sessionName" => "Samsung Galaxy S22 Ultra - Android 12.0",
  "networkLogs" => "true"
},
{
  "browserName" => "ios",
  "deviceName" => "iPhone 13 Pro Max",
  "osVersion" => "15",
  "buildName" => BUILD_NAME,
  "sessionName" => "iPhone 13 Pro Max - iOS 15",
  "networkLogs" => "true"
}]
# Run five parallel tests
t1 = Thread.new{ run_session(caps[0]) }
t2 = Thread.new{ run_session(caps[1]) }
t3 = Thread.new{ run_session(caps[2]) }
t4 = Thread.new{ run_session(caps[3]) }
t5 = Thread.new{ run_session(caps[4]) }
t1.join()
t2.join()
t3.join()
t4.join()
t5.join()
