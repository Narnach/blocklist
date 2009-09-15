require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require 'blocklist/cli'
require 'fakefs'

describe Blocklist::Cli do
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
      cli.should_receive(:puts).with("\nlocalhost\nblocked")
      cli.run
    end
  end
end
