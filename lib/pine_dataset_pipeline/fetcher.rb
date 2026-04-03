# frozen_string_literal: true

module PineDatasetPipeline
  class Fetcher
    DEFAULT_HEADERS = {
      'User-Agent' => 'Mozilla/5.0 (compatible; PineDatasetPipeline/1.0; +https://openai.com)'
    }.freeze

    def initialize(headers: DEFAULT_HEADERS, open_timeout: 20, read_timeout: 30)
      @headers = headers
      @open_timeout = open_timeout
      @read_timeout = read_timeout
    end

    def fetch(url)
      uri = URI.parse(url)

      response = uri.open(
        @headers.merge(
          open_timeout: @open_timeout,
          read_timeout: @read_timeout
        )
      )

      {
        url: url,
        final_url: response.base_uri.to_s,
        status: response.status&.first.to_i,
        content_type: response.content_type,
        body: response.read
      }
    rescue OpenURI::HTTPError => e
      {
        url: url,
        final_url: url,
        status: extract_status(e),
        content_type: nil,
        body: nil,
        error: e.message
      }
    end

    private

    def extract_status(error)
      match = error.message.match(/\A(\d{3})/)
      match ? match[1].to_i : nil
    end
  end
end
