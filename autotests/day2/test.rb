require "minitest_cuprite"
minitest_cuprite "headless": false

describe :test do
  it "test" do
    visit "https://the-internet.herokuapp.com/login"
    find_all("input")[0].set "qwe"
    require "irb"; binding.irb
  end
end
