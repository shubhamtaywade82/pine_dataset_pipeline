# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PineDatasetPipeline::CrawlPageSerializer do
  it 'drops html_doc and keeps html for JSON export' do
    page = {
      final_url: 'https://example.com',
      html: '<html></html>',
      html_doc: Nokogiri::HTML('<html></html>')
    }

    jsonish = described_class.for_json(page)

    expect(jsonish).not_to have_key(:html_doc)
    expect(jsonish[:html]).to eq('<html></html>')
  end
end
