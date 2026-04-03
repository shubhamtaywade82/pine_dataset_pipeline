# frozen_string_literal: true

module PineDatasetPipeline
  module Writers
    class JsonWriter
      def self.write(path, payload)
        FileUtils.mkdir_p(File.dirname(path))
        File.write(path, JSON.pretty_generate(payload))
      end
    end
  end
end
