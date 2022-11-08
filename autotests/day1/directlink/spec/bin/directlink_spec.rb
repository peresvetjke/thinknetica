require_relative '../../spec/spec_helper'
require_relative '../../lib/directlink'
require "open3"
require "shellwords"

# frozen_string_literal: true

RSpec.describe DirectLink, type: :bin do
	subject { Open3.capture2e "./bin/directlink #{input.shellescape}" }

  let(:output) { subject[0] }
	let(:status) { subject[1].exitstatus }

  after { VCR.eject_cassette }

  context 'when imgur' do
    context 'when valid url' do
      before { VCR.insert_cassette 'imgur' }

      let(:input) { "https://imgur.com/8IX7Mp9" }
      let(:expected_status) { 0 }
      let(:expected_output) do
        <<~HEREDOC
          <= #{input}
          => #{input}.png
             png 720x537
          HEREDOC
      end

      it { expect(output).to eq expected_output }
      it { expect(status).to eq expected_status }
    end

    context 'when invalid input' do
      let(:error_message) { "bad link\n" }
      let(:expected_status) { 1 }
  
      context 'when not a link' do
        let(:input) { "test" }
  
        it { expect(output).to include error_message }
        it { expect(status).to eq expected_status }
      end
  
      context 'when bad pattern' do
        let(:input) { "https://imgur.com/a/badlinkpattern" }
  
        it { expect(output).to include error_message }
        it { expect(status).to eq expected_status }
      end
  
    end
  end

  context 'when reddit' do
    context 'when valid url' do
      before { VCR.insert_cassette 'reddit' }

      let(:input) { "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original" }
      let(:image_url) { "https://preview.redd.it/ic0t7aw7g1n41.jpg" }
      let(:expected_status) { 0 }
      let(:expected_output) do
        <<~HEREDOC
          <= #{input}
          => #{image_url}
             jpg 720x537
          HEREDOC
      end

      it { expect(output).to eq expected_output }
      it { expect(status).to eq expected_status }
    end

    context 'when invalid input' do
      before { VCR.insert_cassette 'reddit_invalid' }

      let(:error_message) { "bad link\n" }
      let(:expected_status) { 1 }
  
      context 'when not a link' do
        let(:input) { "test" }
  
        it { expect(output).to include error_message }
        it { expect(status).to eq expected_status }
      end
  
      context 'when bad pattern' do
        let(:input) { 'https://old.reddit.com/wrong/path' }
  
        it { expect(output).to include error_message }
        it { expect(status).to eq expected_status }
      end
  
    end
  end
end