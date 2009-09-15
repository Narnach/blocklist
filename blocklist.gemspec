Gem::Specification.new do |s|
  # Project
  s.name         = 'blocklist'
  s.summary      = "Blocklist manages /etc/hosts"
  s.description  = "Blocklist manages /etc/hosts with the goal of routing distracting websites to localhost. It also works well as an ad blocker."
  s.version      = '0.1.0'
  s.date         = '2009-09-15'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Wes Oldenbeuving"]
  s.email        = "narnach@gmail.com"
  s.homepage     = "http://www.github.com/Narnach/blocklist"

  # Files
  root_files     = %w[MIT-LICENSE README.rdoc Rakefile blocklist.gemspec]
  bin_files      = %w[blocklist]
  lib_files      = %w[blocklist blocklist/cli]
  spec_files     = %w[blocklist blocklist/cli]
  other_files    = %w[spec/spec.opts spec/spec_helper.rb]
  s.bindir       = "bin"
  s.require_path = "lib"
  s.executables  = bin_files
  s.test_files   = spec_files.map {|f| 'spec/%s_spec.rb' % f}
  s.files        = root_files + s.test_files + other_files + bin_files.map {|f| 'bin/%s' % f} + lib_files.map {|f| 'lib/%s.rb' % f}

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README.rdoc MIT-LICENSE]
  s.rdoc_options << '--inline-source' << '--line-numbers' << '--main' << 'README.rdoc'

  # Requirements
  s.required_ruby_version = ">= 1.8.0"
end
