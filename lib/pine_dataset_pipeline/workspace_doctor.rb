# frozen_string_literal: true

require 'json'

module PineDatasetPipeline
  # Read-only checks for local dataset + MCP bundle (parity with a "workspace status" idea).
  class WorkspaceDoctor
    def self.run(config: Config.new, io: $stdout, repo_root: nil)
      new(config: config, io: io, repo_root: repo_root).run
    end

    def initialize(config:, io:, repo_root: nil)
      @config = config
      @io = io
      @repo_root = repo_root || File.expand_path('../..', __dir__)
    end

    def run
      out = @io
      out.puts 'pine_dataset_pipeline workspace'
      out.puts "  repo_root: #{@repo_root}"
      out.puts "  output_dir: #{output_dir}"
      out.puts ''

      report_file('normalized_pages.json', pages_hint)
      report_file('mcp_index.json', nil)
      report_file('reference/functions.json', functions_hint)
      out.puts ''

      report_pine_mcp
      out.puts ''
      out.puts 'Docs: docs/pinescript-agents-ruby-parity.md (vs pinescript-agents Python workspace)'
    end

    private

    def output_dir
      @output_dir ||= File.expand_path(@config.output_dir, @repo_root)
    end

    def report_file(rel, extra)
      path = File.join(output_dir, rel)
      if File.file?(path)
        size = File.size(path)
        suffix = extra ? " — #{extra}" : ''
        @io.puts "  OK #{rel} (#{size} bytes)#{suffix}"
      else
        @io.puts "  MISSING #{rel} — run: bin/pine_docs_sync sync"
      end
    end

    def pages_hint
      path = File.join(output_dir, 'normalized_pages.json')
      return nil unless File.file?(path)

      data = JSON.parse(File.read(path))
      n = data.is_a?(Array) ? data.size : 0
      "#{n} pages"
    rescue JSON::ParserError
      'invalid JSON'
    end

    def functions_hint
      path = File.join(output_dir, 'reference/functions.json')
      return nil unless File.file?(path)

      data = JSON.parse(File.read(path))
      n = data.is_a?(Hash) ? data.size : 0
      "#{n} function keys"
    rescue JSON::ParserError
      'invalid JSON'
    end

    def report_pine_mcp
      gemfile = File.join(@repo_root, 'pine_mcp', 'Gemfile')
      lock = File.join(@repo_root, 'pine_mcp', 'Gemfile.lock')
      if File.file?(gemfile)
        @io.puts '  pine_mcp/Gemfile: present'
        @io.puts "  pine_mcp/Gemfile.lock: #{File.file?(lock) ? 'present' : 'MISSING — cd pine_mcp && bundle install'}"
      else
        @io.puts '  pine_mcp/: MISSING'
      end
    end
  end
end
