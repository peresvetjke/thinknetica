require "minitest_cuprite"
minitest_cuprite "headless": "darwin" != Gem::Platform.local.os

require "minitest/reporters"
Minitest::Reporters.use! [
  Minitest::Reporters::SpecReporter.new,
  Minitest::Reporters::JUnitReporter.new,
]

describe :test do
  it "test" do
    visit "http://automationpractice.com/index.php"
  end
end
