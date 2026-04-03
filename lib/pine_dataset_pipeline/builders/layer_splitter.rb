# frozen_string_literal: true

module PineDatasetPipeline
  module Builders
    class LayerSplitter
      def self.split(normalized_pages)
        normalized_pages.group_by { |page| page[:layer] }
      end
    end
  end
end
