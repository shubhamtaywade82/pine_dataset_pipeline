# frozen_string_literal: true

module PineDatasetPipeline
  class Classifier
    def self.classify(page)
      path = URI.parse(page[:final_url]).path

      layer =
        case path
        when %r{\A/pine-script-reference/v6/}
          "reference"
        when %r{\A/pine-script-docs/language/}
          "language"
        when %r{\A/pine-script-docs/concepts/}
          "concepts"
        when %r{\A/pine-script-docs/writing/}
          "writing"
        when %r{\A/pine-script-docs/release-notes/}
          "release_notes"
        when %r{\A/pine-script-docs/}
          "primer"
        else
          "unknown"
        end

      topic = infer_topic(page, path, layer)

      page.merge(
        layer: layer,
        topic: topic,
        is_reference_manual: layer == "reference",
        is_docs_home: path == "/pine-script-docs/" || path == "/pine-script-docs"
      )
    end

    def self.infer_topic(page, path, layer)
      text = [page[:title], *page[:headings].map { |h| h[:text] }].join(" ").downcase

      return "built_ins" if text.include?("built-ins") || path.include?("/built-ins/")
      return "type_system" if text.include?("type system") || path.include?("/type-system/")
      return "strategies" if text.include?("strategies") || path.include?("/strategies/")
      return "user_defined_functions" if text.include?("user-defined functions") || path.include?("/user-defined-functions/")
      return "style_guide" if text.include?("style guide") || path.include?("/style-guide/")
      return "release_notes" if layer == "release_notes"

      layer
    end
  end
end
