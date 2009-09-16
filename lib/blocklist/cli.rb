require 'blocklist'

class Blocklist
  class Cli
    COMMANDS = %w[add list toggle help]
    def initialize(argv)
      @argv = argv
      @bl = Blocklist.new
      @bl.parse(File.read('/etc/hosts'))
      @dry_run = !@argv.delete('-d').nil?
      @quiet = !@argv.delete('-q').nil?
      @command = @argv.shift || 'help'
    end

    def run
      if COMMANDS.include? @command
        self.send(@command)
      else
        help "Command unknown: '#{@command}'"
      end
    end

    protected

    def list
      puts @bl.blocks.map {|block| block.name}.join("\n")
    end

    def add
      block_name = @argv.shift
      unless block = @bl.block(block_name)
        block = Blocklist::Block.new(block_name)
        @bl.blocks << block
      end
      
      commented_lines = block.lines.inject(0) {|sum, line| line.commented ? sum + 1 : sum}
      uncommented_lines = block.lines.size - commented_lines
      comment_new_lines = commented_lines > uncommented_lines

      domains = block.lines.map {|line| line.domains}.flatten
      saved_domains = @argv.map do |domain|
        dom_segments = domain.split(".")
        tld_size = 1
        tld_size = 2 if %w[uk].include? dom_segments.last
        tld = dom_segments[-tld_size..-1].join(".")
        dom_no_tld = dom_segments[0...-tld_size]
        domain_base = dom_no_tld.last
        subdomain = dom_no_tld.size == 1 ? nil : dom_no_tld[0...-1].join(".")
        new_domains = [nil, 'www', subdomain].uniq.map {|sub| [sub, domain_base, tld].compact.join(".")} - domains
        if new_domains.size > 0
          new_line = Blocklist::Line.new('127.0.0.1', *new_domains)
          new_line.commented = comment_new_lines
          block.lines << new_line
          domains.concat(new_domains)
        end
        new_domains
      end
      display_result
      save if saved_domains.flatten.size > 0
    end

    def toggle
      block_name = @argv.shift
      unless block = @bl.block(block_name)
        help "Could not toggle non-existing block '#{block_name}'"
        return
      end
      block.toggle_comments
      display_result
      save
    end

    def help(msg=nil)
      if msg
        $stderr.puts(msg)
        $stderr.puts('')
      end
      $stderr.puts <<-STR
Syntax: #{$0} [flags] <command>

Flags:
  -d
    Perform a dry-run. Does not modify /etc/hosts
  -q
    Quiet mode. Minimizes the output to STDOUT

Commands:
  add <block name> [domain1] .. [domainN]
    Add a number of domains to the specified block.
    Each domain will automatically be added with the www subdomain and without subdomain.
    Duplicate domains are skipped.
  list
    Shows a list of all blocks currently defined
  toggle <block name>
    Toggle the comment status of all lines in this block.
  help
    Show this page
  STR
    end

    private

    def display_result
      puts @bl unless @quiet
    end

    def save
      File.open('/etc/hosts','w') {|f| f.puts(@bl.to_s)} unless @dry_run
    end
  end
end