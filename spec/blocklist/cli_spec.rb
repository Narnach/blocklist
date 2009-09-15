require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'blocklist/cli'
require 'fakefs/safe'

describe Blocklist::Cli do
  before(:each) do
    FakeFS.activate!
  end
  
  after(:each) do
    FakeFS.deactivate!
  end

  def fake_hosts(content='')
    File.open('/etc/hosts','w') {|f| f.puts content}
  end

  it 'should display help when no command is given' do
    fake_hosts
    cli = Blocklist::Cli.new([])
    cli.should_receive(:help)
    cli.run
  end

  describe 'list' do
    it 'should show all blocks in /etc/hosts' do
      fake_hosts <<-STR
# localhost

# blocked
      STR
      cli = Blocklist::Cli.new(%w[list])
      cli.should_receive(:puts).with("localhost\nblocked")
      cli.run
    end
  end

  describe 'add' do
    it "should add a domain and its www-subdomain to a block's lines" do
      fake_hosts <<-STR
# localhost
      STR
      cli = Blocklist::Cli.new(%w[add localhost example.org])
      cli.run
      File.read('/etc/hosts').should == <<-STR
# localhost
127.0.0.1       example.org www.example.org
      STR
    end
  end
end
