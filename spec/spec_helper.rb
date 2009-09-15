begin
  require 'spec'
rescue LoadError
  $stderr.puts "!! You need to install rspec to run the specs.\n!!   sudo gem install rspec"
  exit 1
end

lib_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(lib_dir)
