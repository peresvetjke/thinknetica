# frozen_string_literal: true

require_relative '../../spec/spec_helper'
require_relative '../../lib/directlink'

RSpec.describe DirectLink, type: :lib do
  describe '.imgur' do
    subject do
      VCR.use_cassette("imgur") do
        described_class.imgur(link)
      end
    end

    context 'when url is correct' do
      let(:link) { "https://imgur.com/8IX7Mp9" }

      it { is_expected.to eq ["#{link}.png", 720, 537, :png] }
    end

    context 'when url is incorrect' do
      context 'when wrong host' do
        let(:link) { 'http://example.com/' }

        it { expect { subject }.to raise_error DirectLink::ErrorBadLink }
      end

      context 'when wrong path' do
        let(:link) { 'https://imgur.com/a/badlinkpattern' }

        it { expect { subject }.to raise_error DirectLink::ErrorBadLink }
      end
    end
  end

  describe '.reddit' do
    subject { described_class.reddit(link) }

    after { VCR.eject_cassette }

    let(:json_link) { File.join(link, 'json') }

    context 'when url is correct' do
      before { VCR.insert_cassette 'reddit' }

      let(:link) { "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original" }

      it { is_expected.to eq ["https://preview.redd.it/ic0t7aw7g1n41.jpg", 720, 537, :jpg] }
    end

    context 'when url is incorrect' do
      context 'when wrong host' do
        let(:link) { 'http://example.com/' }

        it { expect { subject }.to raise_error DirectLink::ErrorBadLink }
      end

      context 'when wrong path' do
        before { VCR.insert_cassette 'reddit_invalid' }

        let(:link) { 'https://old.reddit.com/wrong/path' }

        it { expect { subject }.to raise_error DirectLink::ErrorBadLink }
      end
    end
  end

  describe 'DirectLink' do
    subject { DirectLink link }

    context 'when imgur' do
      context 'when link is valid' do
        let(:link) { "https://imgur.com/8IX7Mp9" }

        it 'calls #imgur' do
          expect(described_class).to receive(:imgur).with(link)
          subject
        end
      end

      context 'when link is invalid' do
        context 'with invalid pattern' do
          let(:link) { "https://imgur.com/a/badlinkpattern" }

          it 'calls #imgur' do
            expect(described_class).to receive(:imgur).with(link)
            subject
          end
        end
      end
    end

    context 'when reddit' do
      context 'when link is valid' do
        let(:link) { "https://old.reddit.com/r/CatsSittingLikeThis/comments/fjl4ay/the_original" }

        it 'calls #reddit' do
          expect(described_class).to receive(:reddit).with(link)
          subject
        end
      end

      context 'when link is invalid' do
        let(:link) { "https://old.reddit.com/wrong/path" }

        it 'calls #reddit' do
          expect(described_class).to receive(:reddit).with(link)
          subject
        end
      end
    end
  end
end
