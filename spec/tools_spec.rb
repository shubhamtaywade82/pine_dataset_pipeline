# frozen_string_literal: true

require 'spec_helper'

RSpec.describe PineDatasetPipeline::Classifier do
  it 'classifies the docs home page' do
    page = {
      final_url: 'https://www.tradingview.com/pine-script-docs/',
      title: 'Pine Script® User Manual',
      headings: [{ text: 'Language' }]
    }

    classified = described_class.classify(page)

    expect(classified[:layer]).to eq('primer')
    expect(classified[:is_docs_home]).to be(true)
  end
end
