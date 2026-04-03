# frozen_string_literal: true

module PineDatasetPipeline
  class Normalizer
    def self.normalize(page)
      classified = Classifier.classify(page)

      {
        source_url: classified[:source_url],
        final_url: classified[:final_url],
        canonical_url: classified[:canonical] || classified[:final_url],
        title: classified[:title],
        description: classified[:description],
        layer: classified[:layer],
        topic: classified[:topic],
        is_reference_manual: classified[:is_reference_manual],
        is_docs_home: classified[:is_docs_home],
        content_hash: classified[:content_hash],
        crawled_at: classified[:crawled_at],
        headings: classified[:headings],
        code_blocks: classified[:code_blocks],
        anchors: classified[:anchors],
        keywords: keywords_for(classified),
        raw_excerpt: classified[:html].to_s[0, 5000]
      }
    end

    def self.keywords_for(page)
      keywords = []
      keywords << page[:layer]
      keywords << page[:topic]
      keywords << 'pine_script_v6'
      keywords << 'reference_manual' if page[:is_reference_manual]
      keywords << 'docs_home' if page[:is_docs_home]
      keywords.compact.uniq
    end
  end
end
