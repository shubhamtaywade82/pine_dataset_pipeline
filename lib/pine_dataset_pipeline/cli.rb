# frozen_string_literal: true

module PineDatasetPipeline
  class CLI
    def self.start(argv)
      command = argv.shift || "sync"

      case command
      when "sync"
        new.sync
      when "crawl"
        new.crawl
      else
        warn "Unknown command: #{command}"
        exit 1
      end
    end

    def initialize
      @config = Config.new
      @fetcher = Fetcher.new
    end

    def crawl
      PineDatasetPipeline.logger.info("Crawl (JSON to stdout)")
      result = Crawler.new(config: @config, fetcher: @fetcher).crawl
      puts JSON.pretty_generate(pages: result.pages, errors: result.errors)
    end

    def sync
      log = PineDatasetPipeline.logger
      output_dir = File.expand_path("../../#{@config.output_dir}", __dir__)
      FileUtils.mkdir_p(output_dir)

      log.info("Sync: output_dir=#{output_dir}")
      log.info("Seeds: #{@config.seed_urls.join(', ')}")

      crawl_result = Crawler.new(config: @config, fetcher: @fetcher).crawl

      log.info("Normalizing #{crawl_result.pages.size} pages")
      normalized_pages = Builders::PageCollector.build(crawl_result)

      log.info("Splitting by layer")
      split_pages = Builders::LayerSplitter.split(normalized_pages)

      log.info("Extracting reference (functions, namespaces)")
      reference = ReferenceExtractor.extract(
        crawl_result.pages,
        seed_path: @config.reference_seed_path
      )

      log.info("Building index")
      index = IndexBuilder.build(normalized_pages)

      log.info("Building MCP index")
      mcp_index = McpIndexBuilder.build(normalized_pages, reference[:functions])

      log.info("Writing JSON outputs under #{output_dir}")
      raw_for_json = crawl_result.pages.map { |p| CrawlPageSerializer.for_json(p) }
      Writers::JsonWriter.write("#{output_dir}/raw_pages.json", raw_for_json)
      Writers::JsonWriter.write("#{output_dir}/normalized_pages.json", normalized_pages)
      Writers::JsonWriter.write("#{output_dir}/reference/functions.json", reference[:functions])
      Writers::JsonWriter.write("#{output_dir}/reference/namespaces.json", reference[:namespaces])
      Writers::JsonWriter.write("#{output_dir}/language/pages.json", split_pages["language"] || [])
      Writers::JsonWriter.write("#{output_dir}/concepts/pages.json", split_pages["concepts"] || [])
      Writers::JsonWriter.write("#{output_dir}/writing/pages.json", split_pages["writing"] || [])
      Writers::JsonWriter.write("#{output_dir}/release_notes/pages.json", split_pages["release_notes"] || [])
      Writers::JsonWriter.write("#{output_dir}/primer/pages.json", split_pages["primer"] || [])
      Writers::JsonWriter.write("#{output_dir}/index.json", index)
      Writers::JsonWriter.write("#{output_dir}/mcp_index.json", mcp_index)

      log.info("Done. pages=#{normalized_pages.size} reference_functions=#{reference[:functions].size}")

      puts "Wrote dataset to #{output_dir}"
      puts "Pages: #{normalized_pages.size}"
      puts "Reference functions: #{reference[:functions].size}"
    end
  end
end
