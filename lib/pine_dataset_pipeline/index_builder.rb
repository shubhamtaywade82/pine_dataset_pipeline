# frozen_string_literal: true

module PineDatasetPipeline
  class IndexBuilder
    def self.build(normalized_pages)
      by_url = {}
      by_layer = Hash.new { |h, k| h[k] = [] }
      by_topic = Hash.new { |h, k| h[k] = [] }
      by_title = Hash.new { |h, k| h[k] = [] }

      normalized_pages.each do |page|
        by_url[page[:final_url]] = {
          layer: page[:layer],
          topic: page[:topic],
          title: page[:title]
        }

        by_layer[page[:layer]] << page[:final_url]
        by_topic[page[:topic]] << page[:final_url]
        by_title[page[:title].to_s.downcase] << page[:final_url] if page[:title]
      end

      {
        generated_at: Time.now.utc.iso8601,
        counts: {
          pages: normalized_pages.size,
          layers: by_layer.transform_values(&:size),
          topics: by_topic.transform_values(&:size)
        },
        by_url: by_url,
        by_layer: by_layer,
        by_topic: by_topic,
        by_title: by_title
      }
    end
  end
end
