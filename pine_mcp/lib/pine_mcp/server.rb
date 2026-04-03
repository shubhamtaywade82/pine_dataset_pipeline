# frozen_string_literal: true

require 'mcp'
require_relative 'catalog'
require_relative 'tools'

module PineMcp
  VERSION = '1.0.0'

  module Server
    module_function

    def start(dataset_root:)
      Catalog.load!(dataset_root)

      server = MCP::Server.new(
        name: 'pine_dataset',
        version: PineMcp::VERSION,
        instructions: 'Tools read Pine dataset JSON produced by pine_dataset_pipeline (run bin/pine_docs_sync sync). Set PINE_DATASET_ROOT to the output directory.',
        tools: Tools.all
      )

      transport = MCP::Server::Transports::StdioTransport.new(server)
      transport.open
    end
  end
end
