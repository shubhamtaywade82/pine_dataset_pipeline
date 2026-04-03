# frozen_string_literal: true

module PineDatasetPipeline
  class Parser
    META_SELECTORS = {
      title: 'title',
      description: 'meta[name="description"]',
      canonical: 'link[rel="canonical"]'
    }.freeze

    def self.parse(html, source_url:, final_url:, status:, content_type:)
      doc = Nokogiri::HTML(html)

      {
        source_url: source_url,
        final_url: final_url,
        status: status,
        content_type: content_type,
        title: first_text(doc, META_SELECTORS[:title]),
        description: doc.at_css(META_SELECTORS[:description])&.[]('content'),
        canonical: doc.at_css(META_SELECTORS[:canonical])&.[]('href'),
        headings: extract_headings(doc),
        code_blocks: extract_code_blocks(doc),
        anchors: extract_anchors(doc),
        html_doc: doc,
        html: html,
        content_hash: Digest::SHA256.hexdigest(html),
        crawled_at: Time.now.utc.iso8601
      }
    end

    def self.internal_links(doc, base_url)
      base_uri = URI.parse(base_url)

      doc.css('a[href]').map { |a| a['href'] }
                        .compact
                        .map { |href| absolutize(base_uri, href) }
                        .compact
         .uniq
    end

    def self.extract_headings(doc)
      doc.css('h1,h2,h3,h4,h5,h6').map do |node|
        {
          level: node.name,
          text: normalize_whitespace(node.text),
          id: node['id']
        }
      end
    end

    def self.extract_code_blocks(doc)
      doc.css('pre code, code').map do |node|
        text = normalize_whitespace(node.text)
        next if text.empty?

        {
          text: text,
          lang: node['class'],
          length: text.length
        }
      end.compact.uniq { |entry| entry[:text] }
    end

    def self.extract_anchors(doc)
      doc.css('a[href]').map do |node|
        {
          text: normalize_whitespace(node.text),
          href: node['href']
        }
      end
    end

    def self.first_text(doc, selector)
      node = doc.at_css(selector)
      return node.text.strip if node&.name == 'title'

      node&.text&.strip
    end

    def self.absolutize(base_uri, href)
      return nil if href.nil? || href.strip.empty?
      return nil if href.start_with?('mailto:', 'javascript:', '#')

      base_uri.merge(href).to_s
    rescue URI::InvalidURIError
      nil
    end

    def self.normalize_whitespace(text)
      text.to_s.gsub(/\s+/, ' ').strip
    end
  end
end
