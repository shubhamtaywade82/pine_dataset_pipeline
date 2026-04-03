# frozen_string_literal: true

module PineDatasetPipeline
  module CrawlPageSerializer
    module_function

    def for_json(page)
      h = symbolize_keys(page)
      h.delete(:html_doc)
      h
    end

    def symbolize_keys(obj)
      return obj unless obj.is_a?(Hash)

      obj.transform_keys { |k| k.is_a?(Symbol) ? k : k.to_sym }
    end
  end
end
