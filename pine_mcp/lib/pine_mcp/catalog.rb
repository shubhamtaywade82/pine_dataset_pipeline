# frozen_string_literal: true

require 'json'

module PineMcp
  module Catalog
    class << self
      attr_reader :functions, :normalized_pages, :mcp_index, :root

      def load!(dataset_root)
        @root = dataset_root
        @functions = load_hash("#{dataset_root}/reference/functions.json")
        norm = read_json("#{dataset_root}/normalized_pages.json")
        @normalized_pages = norm.is_a?(Array) ? norm : []
        @mcp_index = load_hash("#{dataset_root}/mcp_index.json")
      end

      def load_hash(path)
        data = read_json(path)
        data.is_a?(Hash) ? data : {}
      end

      def read_json(path)
        return nil unless File.file?(path)

        JSON.parse(File.read(path))
      rescue JSON::ParserError
        nil
      end
    end
  end
end
