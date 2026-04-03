# frozen_string_literal: true

require 'spec_helper'
require 'stringio'
require 'tmpdir'

RSpec.describe PineDatasetPipeline::WorkspaceDoctor do
  describe '.run' do
    it 'reports OK for present dataset files and counts' do
      Dir.mktmpdir do |root|
        out = File.join(root, 'output')
        FileUtils.mkdir_p(File.join(out, 'reference'))
        File.write(File.join(out, 'normalized_pages.json'), [{ 'url' => 'x' }].to_json)
        File.write(File.join(out, 'mcp_index.json'), {}.to_json)
        File.write(File.join(out, 'reference/functions.json'), { 'ta.rsi' => {} }.to_json)

        FileUtils.mkdir_p(File.join(root, 'pine_mcp'))
        File.write(File.join(root, 'pine_mcp', 'Gemfile'), "source 'https://rubygems.org'\n")
        File.write(File.join(root, 'pine_mcp', 'Gemfile.lock'), "GEM\n")

        config = instance_double(PineDatasetPipeline::Config, output_dir: 'output')
        io = StringIO.new

        described_class.run(config: config, io: io, repo_root: root)

        text = io.string
        expect(text).to include('normalized_pages.json')
        expect(text).to include('1 pages')
        expect(text).to include('1 function keys')
        expect(text).to include('pine_mcp/Gemfile.lock: present')
      end
    end

    it 'reports MISSING when output files are absent' do
      Dir.mktmpdir do |root|
        config = instance_double(PineDatasetPipeline::Config, output_dir: 'output')
        io = StringIO.new

        described_class.run(config: config, io: io, repo_root: root)

        expect(io.string).to include('MISSING normalized_pages.json')
      end
    end
  end
end
