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

  describe '#to_s' do
    it 'should display a Blocklist in the /etc/hosts format' do
      block1 = Blocklist::Block.new('localhost')
      block1.lines << Blocklist::Line.new('127.0.0.1', 'localhost')
      block2 = Blocklist::Block.new('blocked')
      block2.lines << Blocklist::Line.new('127.0.0.1', 'news.ycombinator.com', 'ycombinator.com')
      bl = Blocklist.new
      bl.blocks << block1
      bl.blocks << block2
      bl.to_s.should == <<-STR.strip
# localhost
127.0.0.1       localhost

# blocked
127.0.0.1       news.ycombinator.com ycombinator.com
      STR
    end
  end

  describe '#toggle_comments' do
    it 'should toggle lines between commented-out and not commented' do
      hosts = <<-STR.strip
# blocked
127.0.0.1       news.ycombinator.com ycombinator.com
      STR
      bl = Blocklist.new
      bl.parse(hosts)
      bl.blocks.first.toggle_comments
      bl.to_s.should_not == hosts
      bl2 = Blocklist.new
      bl2.parse(bl.to_s)
      bl2.blocks.first.toggle_comments
      bl2.to_s.should == hosts
    end
  end
end
