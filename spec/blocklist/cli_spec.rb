require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'blocklist/cli'
begin
  require 'fakefs/safe'
rescue LoadError
  $stderr.puts "!! You need to install fakefs to run the CLI specs.\n!! Look on http://github/defunkt/fakefs or use gemcutter.org."
  exit 1
end

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
  
  def run(cmd, silent=true)
    cli = Blocklist::Cli.new(cmd.split(" "))
    cli.stub!(:puts) if silent
    cli.run
    cli
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
      run 'add localhost example.org'
      File.read('/etc/hosts').should == <<-STR
# localhost
127.0.0.1       example.org www.example.org
      STR
    end

    it 'should create a new block if it does not exist yet' do
      fake_hosts <<-STR
# localhost
127.0.0.1       localhost
      STR
      run 'add example example.org'
      File.read('/etc/hosts').should == <<-STR
# localhost
127.0.0.1       localhost

# example
127.0.0.1       example.org www.example.org
      STR
    end


    it 'should add a domain commented-out if there are more commented-out domains in the block' do
      fake_hosts <<-STR
# localhost
# 127.0.0.1       localhost
      STR
      run 'add localhost example.org'
      File.read('/etc/hosts').should == <<-STR
# localhost
# 127.0.0.1       localhost
# 127.0.0.1       example.org www.example.org
      STR
    end
  end
end
