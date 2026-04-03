# frozen_string_literal: true

require "spec_helper"

RSpec.describe PineDatasetPipeline::ReferenceExtractor do
  let(:fixture_html) { File.read(File.expand_path("fixtures/reference_ta_rsi_fragment.html", __dir__)) }

  it "extracts API entries from section ids in reference HTML" do
    pages = [
      {
        final_url: "https://www.tradingview.com/pine-script-reference/v6/",
        html: fixture_html
      }
    ]

    result = described_class.extract(pages, seed_path: "/nonexistent/seed.yml")

    expect(result[:functions]["ta.rsi"]).to include(
      name: "ta.rsi",
      namespace: "ta"
    )
    expect(result[:functions]["ta.rsi"][:signature]).to include("ta.rsi")
    expect(result[:namespaces]["ta"]).to include("ta.rsi")
  end

  it "merges seed file entries" do
    seed = File.expand_path("../data/seed/reference_seed.yml", __dir__)
    pages = []

    result = described_class.extract(pages, seed_path: seed)

    expect(result[:functions]["ta.rsi"]).to include(
      name: "ta.rsi",
      namespace: "ta"
    )
    expect(result[:functions]["ta.rsi"][:signature]).to include("ta.rsi")
  end

  it "deduplicates identical reference HTML across URLs" do
    pages = [
      { final_url: "https://www.tradingview.com/pine-script-reference/v6/#fun_ta.rsi", html: fixture_html },
      { final_url: "https://www.tradingview.com/pine-script-reference/v6/#fun_ta.sma", html: fixture_html }
    ]

    result = described_class.extract(pages, seed_path: "/nonexistent/seed.yml")

    expect(result[:functions]["ta.rsi"]).not_to be_nil
  end
end
