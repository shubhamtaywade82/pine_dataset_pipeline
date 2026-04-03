# frozen_string_literal: true

require "json"
require "mcp"
require_relative "catalog"

module PineMcp
  module Tools
    module_function

    def all
      [search_functions, get_function, list_namespace, search_docs, get_doc_page, validate_code]
    end

    def search_functions
      MCP::Tool.define(
        name: "search_functions",
        description: "Search Pine Script v6 function names by substring (from reference/functions.json).",
        input_schema: {
          type: "object",
          properties: {
            query: { type: "string", description: "Substring to match against full names e.g. rsi" }
          },
          required: ["query"]
        }
      ) do |query:, server_context:|
        q = query.to_s.downcase
        names = Catalog.functions.keys.select { |k| k.to_s.downcase.include?(q) }.take(100)
        MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(names) }])
      end
    end

    def get_function
      MCP::Tool.define(
        name: "get_function",
        description: "Return one Pine v6 function entry (signature, description, URLs) by exact name.",
        input_schema: {
          type: "object",
          properties: {
            name: { type: "string", description: "Exact name e.g. ta.rsi" }
          },
          required: ["name"]
        }
      ) do |name:, server_context:|
        fn = Catalog.functions[name.to_s]
        unless fn
          return MCP::Tool::Response.new(
            [{ type: "text", text: JSON.pretty_generate({ error: "not_found", name: name }) }],
            error: true
          )
        end

        MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(fn) }])
      end
    end

    def list_namespace
      MCP::Tool.define(
        name: "list_namespace",
        description: "List function names in a namespace prefix (e.g. ta, math, strategy).",
        input_schema: {
          type: "object",
          properties: {
            namespace: { type: "string", description: "Namespace e.g. ta" }
          },
          required: ["namespace"]
        }
      ) do |namespace:, server_context:|
        ns = namespace.to_s
        names = Catalog.functions.keys.select { |k| k.to_s.start_with?("#{ns}.") }.take(500)
        MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(names) }])
      end
    end

    def search_docs
      MCP::Tool.define(
        name: "search_docs",
        description: "Search normalized Pine docs pages by keyword in title or description.",
        input_schema: {
          type: "object",
          properties: {
            query: { type: "string", description: "Keyword or phrase" },
            limit: { type: "integer", description: "Max results (default 20)" }
          },
          required: ["query"]
        }
      ) do |query:, limit: 20, server_context:|
        q = query.to_s.downcase
        max = [limit.to_i, 1].max
        max = [max, 50].min
        hits = []
        Catalog.normalized_pages.each do |p|
          next unless p.is_a?(Hash)

          title = (p["title"] || p[:title]).to_s.downcase
          desc = (p["description"] || p[:description]).to_s.downcase
          next unless title.include?(q) || desc.include?(q)

          hits << {
            url: p["final_url"] || p[:final_url],
            title: p["title"] || p[:title],
            layer: p["layer"] || p[:layer]
          }
          break if hits.size >= max
        end
        MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(hits) }])
      end
    end

    def get_doc_page
      MCP::Tool.define(
        name: "get_doc_page",
        description: "Return normalized metadata and excerpt for a docs URL if present.",
        input_schema: {
          type: "object",
          properties: {
            url: { type: "string", description: "final_url from dataset" }
          },
          required: ["url"]
        }
      ) do |url:, server_context:|
        page = Catalog.normalized_pages.find do |p|
          next false unless p.is_a?(Hash)

          (p["final_url"] || p[:final_url]).to_s == url.to_s
        end
        unless page
          return MCP::Tool::Response.new(
            [{ type: "text", text: JSON.pretty_generate({ error: "not_found", url: url }) }],
            error: true
          )
        end

        slim = page.transform_keys(&:to_s).slice("title", "description", "layer", "topic", "final_url", "raw_excerpt")
        MCP::Tool::Response.new([{ type: "text", text: JSON.pretty_generate(slim) }])
      end
    end

    def validate_code
      MCP::Tool.define(
        name: "validate_code",
        description: "Lightweight checks: //@version=6 and unknown ta/math/strategy/request.* identifiers vs local function registry.",
        input_schema: {
          type: "object",
          properties: {
            code: { type: "string", description: "Full or partial Pine script" }
          },
          required: ["code"]
        }
      ) do |code:, server_context:|
        errors = []
        errors << "Missing //@version=6" unless code.include?("//@version=6")

        known = Catalog.functions
        if known.any?
          scan_namespaces(code).each do |fname|
            next if known.key?(fname)

            errors << "Unknown in local registry: #{fname}"
          end
        end

        MCP::Tool::Response.new(
          [{ type: "text", text: JSON.pretty_generate({ valid: errors.empty?, errors: errors }) }]
        )
      end
    end

    def scan_namespaces(code)
      pattern = /\b(ta|math|str|array|matrix|map|strategy|request|syminfo|ticker)\.([a-zA-Z_][a-zA-Z0-9_.]*)\b/
      code.scan(pattern).map { |ns, rest| "#{ns}.#{rest}" }.uniq
    end
  end
end
