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
      result = Crawler.new(config: @config, fetcher: @fetcher).crawl
      puts JSON.pretty_generate(pages: result.pages, errors: result.errors)
    end

    def sync
      output_dir = File.expand_path("../../#{@config.output_dir}", __dir__)
      FileUtils.mkdir_p(output_dir)

      crawl_result = Crawler.new(config: @config, fetcher: @fetcher).crawl
      normalized_pages = Builders::PageCollector.build(crawl_result)
      split_pages = Builders::LayerSplitter.split(normalized_pages)
      reference = ReferenceExtractor.extract(normalized_pages)
      index = IndexBuilder.build(normalized_pages)

      Writers::JsonWriter.write("#{output_dir}/raw_pages.json", crawl_result.pages)
      Writers::JsonWriter.write("#{output_dir}/normalized_pages.json", normalized_pages)
      Writers::JsonWriter.write("#{output_dir}/reference/functions.json", reference[:functions])
      Writers::JsonWriter.write("#{output_dir}/reference/namespaces.json", reference[:namespaces])
      Writers::JsonWriter.write("#{output_dir}/language/pages.json", split_pages["language"] || [])
      Writers::JsonWriter.write("#{output_dir}/concepts/pages.json", split_pages["concepts"] || [])
      Writers::JsonWriter.write("#{output_dir}/writing/pages.json", split_pages["writing"] || [])
      Writers::JsonWriter.write("#{output_dir}/release_notes/pages.json", split_pages["release_notes"] || [])
      Writers::JsonWriter.write("#{output_dir}/primer/pages.json", split_pages["primer"] || [])
      Writers::JsonWriter.write("#{output_dir}/index.json", index)

      puts "Wrote dataset to #{output_dir}"
      puts "Pages: #{normalized_pages.size}"
      puts "Reference functions: #{reference[:functions].size}"
    end
  end
end
