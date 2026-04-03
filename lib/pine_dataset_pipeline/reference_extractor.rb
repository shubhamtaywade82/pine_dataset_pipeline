# frozen_string_literal: true

require 'yaml'

module PineDatasetPipeline
  class ReferenceExtractor
    REFERENCE_PATH = %r{/pine-script-reference/v6}i.freeze
    SECTION_ID = /\A(fun|var|type|field|method|keyword|enum)_[a-zA-Z0-9_.]+\z/.freeze

    def self.extract(pages, seed_path: default_seed_path)
      functions = {}
      deduped_reference_pages(pages).each do |page|
        extract_from_page(page, functions)
      end

      merge_seed!(functions, seed_path)
      {
        functions: functions,
        namespaces: namespaces_from(functions)
      }
    end

    def self.default_seed_path
      File.expand_path('../../data/seed/reference_seed.yml', __dir__)
    end

    def self.deduped_reference_pages(pages)
      seen_hashes = {}
      out = []
      pages.each do |page|
        next unless reference_page?(page)

        html = html_for(page)
        next if html.empty?

        key = Digest::SHA256.hexdigest(html)
        next if seen_hashes[key]

        seen_hashes[key] = true
        out << page
      end
      out
    end

    def self.extract_from_page(page, functions)
      html = html_for(page)
      return if html.empty?

      doc = Nokogiri::HTML(html)
      source_url = url_for(page)

      doc.xpath('//*[@id]').each do |node|
        id = node['id']
        next unless id&.match?(SECTION_ID)

        api_name = api_name_from_section_id(id)
        next if api_name.nil? || api_name.empty?

        entry = build_entry(node, id, api_name, source_url)
        next if entry.nil?

        existing = functions[api_name]
        functions[api_name] = merge_entry(existing, entry)
      end

      fallback_code_block_extract(doc, source_url, functions)
    end

    def self.merge_entry(existing, incoming)
      return incoming if existing.nil?

      %i[description signature].each do |key|
        next if incoming[key].to_s.empty?

        existing[key] = incoming[key] if existing[key].to_s.length < incoming[key].to_s.length
      end
      existing[:source_urls] = ([*existing[:source_urls]] | [*incoming[:source_urls]]).uniq
      existing[:source_url] ||= incoming[:source_url]
      existing[:section_ids] = ([*existing[:section_ids]] | [*incoming[:section_ids]]).uniq
      existing
    end

    def self.build_entry(node, section_id, api_name, source_url)
      signature = signature_from_section(node)
      description = description_from_section(node)

      {
        name: api_name,
        section_id: section_id,
        section_ids: [section_id],
        signature: signature,
        description: description,
        namespace: api_name.split('.').first,
        source_url: source_url,
        source_urls: [source_url].compact
      }.compact
    end

    def self.signature_from_section(node)
      node.css('pre code, code').each do |code|
        text = Parser.normalize_whitespace(code.text)
        next if text.length < 5

        return text if pine_signature_like?(text)
      end

      text = Parser.normalize_whitespace(node.text)
      text.lines.map(&:strip).find { |l| pine_signature_like?(l) }
    end

    def self.pine_signature_like?(text)
      return false if text.nil?

      t = text.strip
      return false if t.length < 5

      (t.include?('(') && t.include?(')')) || t.include?('→') || t.include?('->')
    end

    def self.description_from_section(node)
      parts = []
      node.children.each do |child|
        next if child.name == 'pre'

        if child.element?
          parts << child.text unless %w[table script style].include?(child.name)
        elsif child.text?
          t = Parser.normalize_whitespace(child.text)
          parts << t unless t.empty?
        end
      end
      text = Parser.normalize_whitespace(parts.join(' '))
      text = text[0, 4000] if text.length > 4000
      text
    end

    def self.fallback_code_block_extract(doc, source_url, functions)
      doc.css('pre code, code').each do |code|
        text = Parser.normalize_whitespace(code.text)
        next unless text.include?('=>') || text.include?('→') || text.match?(/\)\s*[→-]>/) || text.match?(/\w\.\w+\(/)

        sig = infer_signature(text)
        next unless sig

        name = sig[:name]
        next if functions[name]

        functions[name] = {
          name: name,
          signature: sig[:signature],
          namespace: name.split('.').first,
          source_url: source_url,
          source_urls: [source_url].compact,
          section_ids: []
        }
      end
    end

    def self.infer_signature(text)
      first = text.lines.map(&:strip).find do |line|
        line.match?(/^[a-z_][\w.]*\s*\(/i) ||
          line.match?(/^(?:ta|math|array|color|strategy|request|str|syminfo|nz|fixnan)\.[a-z_]\w*\s*\(/i)
      end
      return nil unless first

      name = first.split('(').first.strip
      return nil if name.empty?

      { name: name, signature: first }
    end

    def self.api_name_from_section_id(id)
      id.sub(/\A(fun|var|type|field|method|keyword|enum)_/, '')
    end

    def self.reference_page?(page)
      url = url_for(page)
      return false if url.nil? || url.empty?

      URI.parse(url).path.match?(REFERENCE_PATH)
    rescue URI::InvalidURIError
      false
    end

    def self.url_for(page)
      (page[:final_url] || page['final_url']).to_s
    end

    def self.html_for(page)
      (page[:html] || page['html']).to_s
    end

    def self.namespaces_from(functions)
      namespaces = Hash.new { |h, k| h[k] = [] }
      functions.each_key do |name|
        ns = name.to_s.split('.').first
        namespaces[ns] << name.to_s
      end
      namespaces.transform_values(&:uniq)
    end

    def self.merge_seed!(functions, seed_path)
      return unless seed_path && File.exist?(seed_path)

      seed = YAML.load_file(seed_path)
      return unless seed.is_a?(Hash)

      (seed['functions'] || {}).each do |name, meta|
        next unless name.is_a?(String) && meta.is_a?(Hash)

        sym_meta = stringify_for_merge(meta)
        functions[name] = if functions[name]
                            functions[name].merge(sym_meta) do |_, old, new|
                              new.nil? || new == {} ? old : new
                            end
                          else
                            { name: name, namespace: name.split('.').first }.merge(sym_meta)
                          end
      end
    end

    def self.stringify_for_merge(h)
      h.transform_keys(&:to_sym).transform_values do |v|
        case v
        when Hash then stringify_for_merge(v)
        else v
        end
      end
    end
  end
end
