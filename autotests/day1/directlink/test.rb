require "minitest/autorun"
require "webmock/minitest"

require_relative "lib/directlink"

valid_imgur_link = "https://imgur.com/8IX7Mp9"
valid_reddit_link = "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original/"

describe "./bin" do
  require "open3"
  require "shellwords"
  popen = lambda do |input|
    Open3.capture2e "./bin/directlink #{input.shellescape}"
  end

  [
    <<~HEREDOC,
      <= #{valid_imgur_link}
      => #{valid_imgur_link}.png
         png 720x537
      HEREDOC
  ].each do |expected_output|
    it "output" do
      string, status = popen[valid_imgur_link]
      assert_equal [0, expected_output], [status.exitstatus, string]
    end
  end

  [
    ["test", "bad link\n"],
    ["https://imgur.com/a/badlinkpattern", "bad link\n"],
  ].each do |input, expected_output_substr|
    it "fails" do
      string, status = popen[input]
      assert_equal 1, status.exitstatus, "for #{input}"
      assert string[expected_output_substr], "for #{input} string:\n#{string}"
    end
  end

end

describe "./lib" do

  %w{
    https://imgur.com/a/badlinkpattern
    http://example.com/
  }.product( [
    method(:DirectLink),
    DirectLink.method(:imgur),
  ] ).each do |link, mtd|
    it "ErrorBadLink #{mtd} #{link}" do
      assert_equal link, (
        assert_raises DirectLink::ErrorBadLink do
          mtd.call link
        end
      ).message
    end
  end

  describe "mocked" do
    before do
      WebMock.reset!
      stub_request(:get, /\.png\z/).to_return body: "GIF89a\x01\x00\x01\x00\x00\xff\x00,\x00\x00\x00\x00\x01\x00\x01\x00\x00\x02\x00"
    end

    [
      ["https://imgur.com/a/badlinkpattern", :imgur],
      [valid_imgur_link, :imgur],
    ].each do |input, mtd|
      it "DirectLink() choses #{mtd}" do
        DirectLink.stub mtd, ->(link){
          assert_equal input, link
          throw :_
        } do
          catch :_ do
            DirectLink input
            fail "DirectLink##{mtd} was not called"
          end
        end
      end
    end

    [
      [valid_imgur_link, "#{valid_imgur_link}.png", 1, 1, :gif],
    ].each do |link, *stub|
      it "success #{link}" do
        assert_equal stub, DirectLink.imgur(link)
      end
    end

  end

end
