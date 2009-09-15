require File.join(File.dirname(__FILE__), %w[spec_helper])
require 'blocklist'

describe Blocklist do
  describe '#parse' do
    it 'should parse all blocks' do
      hosts = <<-STR
# localhost
127.0.0.1 localhost
255.255.255.255 broadcasthost

# blocked
127.0.0.1 news.ycombinator.com
      STR
      bl = Blocklist.new
      bl.parse(hosts)
      bl.blocks.map {|block| block.name}.should == %w[localhost blocked]
    end
  
    it 'should parse all domains on a line' do
      hosts = <<-STR
# blocked
127.0.0.1 news.ycombinator.com ycombinator.com
      STR
      bl = Blocklist.new
      bl.parse(hosts)
      bl.blocks.first.should == Blocklist::Block.new('blocked',
        Blocklist::Line.new('127.0.0.1', *%w[news.ycombinator.com ycombinator.com]))
    end
  end
end
