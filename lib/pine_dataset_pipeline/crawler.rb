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
      log = PineDatasetPipeline.logger
      seen = {}
      queue = @config.seed_urls.map { |url| [url, 0] }
      pages = []
      errors = []

      log.info(
        "Crawl starting: seeds=#{queue.size} max_pages=#{@config.crawl_max_pages} max_depth=#{@config.crawl_max_depth}"
      )

      until queue.empty? || pages.size >= @config.crawl_max_pages
        url, depth = queue.shift
        next if seen[url]
        seen[url] = true

        log.debug { "GET #{url} (depth=#{depth}, queue=#{queue.size})" }

        fetched = @fetcher.fetch(url)
        if fetched[:body].nil?
          errors << fetched.merge(depth: depth)
          log.warn("Fetch failed: #{url} status=#{fetched[:status].inspect} #{fetched[:error]}".strip)
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

        discovered = 0
        if depth < @config.crawl_max_depth
          Parser.internal_links(page[:html_doc], page[:final_url]).each do |link|
            next unless allowed_url?(link)
            next if seen[link]

            queue << [link, depth + 1]
            discovered += 1
          end
        end

        log.info(
          "Page #{pages.size}/#{@config.crawl_max_pages}: #{page[:final_url]} " \
          "status=#{fetched[:status]} queued=#{queue.size} +links=#{discovered}"
        )
      end

      log.info("Crawl finished: pages=#{pages.size} errors=#{errors.size} seen=#{seen.size}")
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
