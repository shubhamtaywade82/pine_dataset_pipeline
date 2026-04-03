# frozen_string_literal: true

module PineDatasetPipeline
  module Utils
    class Slug
      def self.call(value)
        value.to_s.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/\A_|_\z/, '')
      end
    end
  end
end
