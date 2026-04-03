# frozen_string_literal: true

module PineDatasetPipeline
  class Crawler
    DOC_PATHS = %r{\A/(pine-script-docs|pine-script-reference/v6)/}.freeze

    Result = Struct.new(:pages, :errors, keyword_init: true)

    def initialize(config:, fetcher:)
      @config = config
      @fetcher = fetcher
    end

    def crawl
      seen = {}
      queue = @config.seed_urls.map { |url| [url, 0] }
      pages = []
      errors = []

      until queue.empty? || pages.size >= @config.crawl_max_pages
        url, depth = queue.shift
        next if seen[url]
        seen[url] = true

        fetched = @fetcher.fetch(url)
        if fetched[:body].nil?
          errors << fetched.merge(depth: depth)
          next
        end

        page = Parser.parse(
          fetched[:body],
          source_url: fetched[:url],
          final_url: fetched[:final_url],
          status: fetched[:status],
          content_type: fetched[:content_type]
        )

        pages << page

        next if depth >= @config.crawl_max_depth

        Parser.internal_links(page[:html_doc], page[:final_url]).each do |link|
          next unless allowed_url?(link)
          next if seen[link]

          queue << [link, depth + 1]
        end
      end

      Result.new(pages: pages, errors: errors)
    end

    private

    def allowed_url?(url)
      uri = URI.parse(url)
      @config.allowed_hosts.include?(uri.host) && uri.path.match?(DOC_PATHS)
    rescue URI::InvalidURIError
      false
    end
  end
end
