# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PineDatasetPipeline::Parser do
  describe '.absolutize' do
    it 'resolves a relative href against an HTTPS base URI' do
      base = URI.parse('https://example.com/docs/page/')

      expect(described_class.absolutize(base, 'section')).to eq('https://example.com/docs/page/section')
    end

    it 'returns nil for empty or non-http schemes' do
      base = URI.parse('https://example.com/')

      expect(described_class.absolutize(base, '')).to be_nil
      expect(described_class.absolutize(base, '   ')).to be_nil
      expect(described_class.absolutize(base, 'mailto:a@b.com')).to be_nil
      expect(described_class.absolutize(base, 'javascript:void(0)')).to be_nil
      expect(described_class.absolutize(base, '#frag')).to be_nil
    end
  end

  describe '.internal_links' do
    it 'collects absolute URLs for same-origin relative links' do
      html = '<html><body><a href="/a">A</a><a href="b">B</a></body></html>'
      doc = Nokogiri::HTML(html)

      links = described_class.internal_links(doc, 'https://docs.example.com/root/')

      expect(links).to contain_exactly('https://docs.example.com/a', 'https://docs.example.com/root/b')
    end
  end
end
