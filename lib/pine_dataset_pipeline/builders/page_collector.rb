# frozen_string_literal: true

module PineDatasetPipeline
  module Builders
    class PageCollector
      def self.build(crawl_result)
        crawl_result.pages.map { |page| Normalizer.normalize(page) }
      end
    end
  end
end
