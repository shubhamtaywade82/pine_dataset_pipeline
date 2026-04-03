# frozen_string_literal: true

require "spec_helper"

RSpec.describe PineDatasetPipeline::McpIndexBuilder do
  it "builds reference and concept indexes" do
    pages = [
      {
        final_url: "https://example.com/repaint",
        layer: "concepts",
        topic: "strategies",
        title: "Repainting",
        description: "Avoid repainting indicators",
        headings: []
      }
    ]
    functions = {
      "ta.rsi" => { namespace: "ta", source_url: "https://tv.com/ref", signature: "ta.rsi()" }
    }

    idx = described_class.build(pages, functions)

    expect(idx[:reference][:by_name]["ta.rsi"][:namespace]).to eq("ta")
    expect(idx[:reference][:by_namespace]["ta"]).to include("ta.rsi")
    expect(idx[:concepts]["repainting"]).to include("https://example.com/repaint")
  end
end
