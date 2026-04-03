# frozen_string_literal: true

module PineDatasetPipeline
  class Config
    attr_reader :path, :data

    def initialize(path: File.expand_path("../../config/sources.yml", __dir__))
      @path = path
      @data = YAML.load_file(path)
    end

    def output_dir
      data.fetch("output_dir", "output")
    end

    def seed_urls
      Array(data["seed_urls"])
    end

    def crawl_max_pages
      data.fetch("crawl", {}).fetch("max_pages", 500)
    end

    def crawl_max_depth
      data.fetch("crawl", {}).fetch("max_depth", 4)
    end

    def allowed_hosts
      Array(data["allowed_hosts"])
    end

    def user_manual_root
      data.fetch("user_manual_root")
    end

    def reference_root
      data.fetch("reference_root")
    end
  end
end
