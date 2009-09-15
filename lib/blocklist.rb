class Blocklist
  attr_accessor :blocks

  def initialize
    self.blocks = []
  end

  def parse(content)
    block = Block.new
    content.each_line do |line|
      line = line.strip
      case line
      when ''     # empty line
        if block.name or block.lines.size > 0
          self.blocks << block
          block = Block.new
        end
      when /\A#/  # comment
        block.name ||= line.gsub(/\A#+\s+/,'')
      else        # domain
        block.lines << Line.new(*line.split(" "))
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

    def to_s
      "# #{name}\n" + lines.join("\n")
    end
  end

  class Line
    attr_accessor :ip, :domains

    def initialize(ip, *domains)
      self.ip = ip
      self.domains = domains
    end

    def ==(other)
      return false unless other.class == self.class
      return false unless other.ip == self.ip
      return false unless other.domains == self.domains
      true
    end

    def to_s
      "%s%s%s" % [ip, " " * (16 - ip.size), domains.join(" ")]
    end
  end
end
