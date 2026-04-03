# frozen_string_literal: true

module PineDatasetPipeline
  class McpIndexBuilder
    CONCEPT_HINTS = {
      'repainting' => [/repaint/i],
      'request.security' => [/request\.security/i, /security\s*\(/i],
      'strategy_orders' => [/strategy\.(entry|exit|close)/i],
      'execution_model' => [/execution model/i, /bar-?by-?bar/i],
      'type_system' => [/type system/i, /simple int/i, /series float/i]
    }.freeze

    def self.build(normalized_pages, functions_hash)
      by_name = {}
      functions_hash.each do |name, meta|
        by_name[name.to_s] = {
          namespace: meta[:namespace] || meta['namespace'],
          source_url: meta[:source_url] || meta['source_url'],
          has_signature: !(meta[:signature] || meta['signature']).to_s.empty?
        }.compact
      end

      by_namespace = Hash.new { |h, k| h[k] = [] }
      by_name.each_key do |name|
        ns = name.split('.').first
        by_namespace[ns] << name
      end

      {
        generated_at: Time.now.utc.iso8601,
        reference: {
          by_name: by_name,
          by_namespace: by_namespace.transform_values(&:sort)
        },
        concepts: concept_index(normalized_pages),
        docs: {
          by_layer: docs_by_layer(normalized_pages),
          by_url: docs_by_url(normalized_pages)
        }
      }
    end

    def self.docs_by_layer(pages)
      layers = Hash.new { |h, k| h[k] = [] }
      pages.each do |p|
        layer = (p[:layer] || p['layer']).to_s
        url = (p[:final_url] || p['final_url']).to_s
        title = (p[:title] || p['title']).to_s
        layers[layer] << { url: url, title: title } unless url.empty?
      end
      layers.transform_values { |arr| arr.uniq { |e| e[:url] } }
    end

    def self.docs_by_url(pages)
      pages.each_with_object({}) do |p, h|
        url = (p[:final_url] || p['final_url']).to_s
        next if url.empty?

        h[url] = {
          layer: p[:layer] || p['layer'],
          topic: p[:topic] || p['topic'],
          title: p[:title] || p['title']
        }.compact
      end
    end

    def self.concept_index(pages)
      CONCEPT_HINTS.transform_values do |patterns|
        pages.each_with_object([]) do |p, acc|
          blob = [
            p[:title],
            p[:description],
            *(p[:headings] || p['headings'] || []).map { |x| x[:text] || x['text'] }
          ].compact.join(' ')

          next if blob.empty?

          acc << (p[:final_url] || p['final_url']).to_s if patterns.any? { |rx| blob.match?(rx) }
        end.uniq
      end
    end
  end
end
