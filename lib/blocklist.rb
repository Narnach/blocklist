class Blocklist
  attr_accessor :blocks

  def initialize
    self.blocks = []
  end

  def parse(content)
    block = Block.new
    content.each_line do |line|
      parsed_line = Line.parse(line)
      case parsed_line
      when nil
        self.blocks << block
        block = Block.new
      when String
        block.name ||= parsed_line
      when Line
        block.lines << parsed_line
      else
        raise "Unexpected line: #{line}"
      end
    end
    if block.name or block.lines.size > 0
      self.blocks << block
    end
    nil
  end

  def to_s
    blocks.join("\n\n")
  end

  class Block
    attr_accessor :name, :lines

    def initialize(name=nil, *lines)
      self.name = name
      self.lines = lines
    end

    def ==(other)
      return false unless other.class == self.class
      return false unless other.name == self.name
      return false unless other.lines == self.lines
      true
    end

    def toggle_comments
      lines.each {|line| line.toggle_comment}
    end

    def to_s
      "# #{name}\n" + lines.join("\n")
    end
  end

  class Line
    COMMENT_PREFIX = /\A#+\s+/
    IPV4 = /\A\d{1,3}(\.\d{1,3}){3}\s+/
    IPV6 = /\A[0-9a-fA-F]{0,4}(::?\A[0-9a-fA-F]{0,4}){1,7}\s+/

    attr_accessor :ip, :domains, :commented

    def initialize(ip, *domains)
      self.ip = ip
      self.domains = domains
      self.commented = false
    end

    def ==(other)
      return false unless other.class == self.class
      return false unless other.ip == self.ip
      return false unless other.domains == self.domains
      true
    end

    def toggle_comment
      self.commented = !commented
    end

    def to_s
      prefix = commented ? "# " : ""
      "%s%s%s%s" % [prefix, ip, " " * (16 - ip.size), domains.join(" ")]
    end

    def self.parse(line)
      stripped_line = line.strip
      return nil if stripped_line == ''
      return Line.new(*stripped_line.split(" ")) unless stripped_line =~ COMMENT_PREFIX
      uncommented_line = stripped_line.gsub(COMMENT_PREFIX, '')
      if uncommented_line =~ IPV4
        parsed_line = Line.new(*uncommented_line.split(" "))
        parsed_line.commented = true
        parsed_line
      elsif uncommented_line =~ IPV6
        parsed_line = Line.new(*uncommented_line.split(" "))
        parsed_line.commented = true
        parsed_line
      else # comment or title
        uncommented_line
      end
    end
  end
end
