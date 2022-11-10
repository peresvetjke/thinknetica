# frozen_string_literal: true

require_relative '../../spec/spec_helper'
require_relative '../../lib/directlink'
require "open3"
require "shellwords"

RSpec.describe DirectLink, type: :bin do
	subject { Open3.capture2e "./bin/directlink #{input.shellescape}" }

  let(:output) { subject[0] }
	let(:status) { subject[1].exitstatus }

  after { VCR.eject_cassette }

  shared_examples 'returns error' do
    it 'returns error', :aggregate_failures do
      expect(output).to include "bad link\n"
      expect(status).to eq 1
    end
  end

  context 'when imgur' do
    context 'when valid url' do
      before { VCR.insert_cassette 'imgur' }

      let(:input) { "https://imgur.com/8IX7Mp9" }
      let(:expected_output) do
        <<~HEREDOC
          <= #{input}
          => #{input}.png
             png 720x537
          HEREDOC
      end

      it 'returns successful response', :aggregate_failures do
        expect(output).to eq expected_output
        expect(status).to eq 0
      end
    end

    context 'when invalid input' do
      context 'when not a link' do
        let(:input) { "test" }

        it_behaves_like 'returns error'
      end

      context 'when bad pattern' do
        let(:input) { "https://imgur.com/a/badlinkpattern" }

        it_behaves_like 'returns error'
      end
    end
  end

  context 'when reddit' do
    context 'when valid url' do
      before { VCR.insert_cassette 'reddit' }

      let(:input) { "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original" }
      let(:image_url) { "https://i.redd.it/ic0t7aw7g1n41.jpg" }
      let(:expected_output) do
        <<~HEREDOC
          <= #{input}
          => #{image_url}
             jpg 720x537
          HEREDOC
      end

      it 'returns successful response', :aggregate_failures do
        expect(output).to eq expected_output
        expect(status).to eq 0
      end
    end

    context 'when invalid input' do
      before { VCR.insert_cassette 'reddit_invalid' }

      context 'when not a link' do
        let(:input) { "test" }

        it_behaves_like 'returns error'
      end

      context 'when bad pattern' do
        let(:input) { 'https://old.reddit.com/wrong/path' }

        it_behaves_like 'returns error'
      end
    end
  end
end