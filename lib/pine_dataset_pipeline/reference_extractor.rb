# frozen_string_literal: true

module PineDatasetPipeline
  class ReferenceExtractor
    def self.extract(normalized_pages)
      reference_pages = normalized_pages.select { |p| p[:is_reference_manual] }

      functions = {}
      namespaces = Hash.new { |h, k| h[k] = [] }

      reference_pages.each do |page|
        page[:code_blocks].each do |block|
          next unless block[:text].include?("=>") || block[:text].include?("()")

          signature = infer_signature(block[:text])
          next unless signature

          name = signature[:name]
          functions[name] = signature.merge(
            source_url: page[:final_url],
            source_title: page[:title]
          )

          namespace = name.split(".").first
          namespaces[namespace] << name
        end
      end

      {
        functions: functions,
        namespaces: namespaces.transform_values(&:uniq)
      }
    end

    def self.infer_signature(text)
      first = text.lines.map(&:strip).find { |line| line.match?(/^[a-z_][\w.]*\(/i) || line.match?(/^(?:ta|math|array|color|strategy|request)\.[a-z_][\w]*\(/i) }
      return nil unless first

      name = first.split("(").first.strip
      {
        name: name,
        signature: first
      }
    end
  end
end
