# Enable tab-completion.
require 'irb/completion'

# Enable prompt-less prompts
IRB.conf[:PROMPT][:XMP][:RETURN] = "\# => %s\n"
IRB.conf[:PROMPT][:XMP][:PROMPT_I] = ""
IRB.conf[:PROMPT_MODE] = :XMP

# Auto-indentation.
IRB.conf[:AUTO_INDENT] = true

# Readline-enable prompts.
require 'irb/ext/save-history'
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_PATH] = File::expand_path("~/.irb.history")

# local_methods shows methods that are only available for a given object.
class Object
  def local_methods
    self.methods.sort - self.class.superclass.methods
  end
end

# Dynamic method finding; e.g., "hello".what? == 5 #=> ["length", "size"]
begin
#  require File::expand_path("~/.irb_lib/method_finder")
  require 'rubygems'
  require 'what_methods'
rescue LoadError
  puts "Error loading method_finder. Run 'sudo gem install what_methods' to enable Object#what? method finding."
end

# Colorize results
begin
  require 'rubygems'
  require 'wirble'
  Wirble.init
  Wirble.colorize
rescue LoadError
  puts "Error loading Wirble. Run 'sudo gem install wirble' to enable colorized results."
end

# Inline colorized ri (override wirble's)
RIARGS = ['-f', 'ansi']
require 'rdoc/ri/ri_driver'
class MyStupidRiDriver < RiDriver
  def self.ri(*topics)
    topics.map! { |topic| topic.to_s }
    begin
      MyStupidRiDriver.new(*topics).process_args
    rescue => e
      puts "Error processing ri request: #{e}"
    end
  end

  def initialize(*topics)
    @options = RI::Options.instance
    args = RIARGS.dup + topics
    @options.parse(args)
    paths = RI::Paths::PATH
    @ri_reader = RI::RiReader.new(RI::RiCache.new(paths))
    @display   = @options.displayer
  end
end

def Kernel.ri(*args)
  less { MyStupidRiDriver.ri(*args) }
end

class Module
  def ri(*args)
    topics = args.map { |arg| arg = "#{self}##{arg}" }
    less { MyStupidRiDriver.ri(*topics) }
  end
end

# Copious output helper
def less
  spool_output('less')
end

def most
  spool_output('most')
end

def spool_output(spool_cmd)
  require 'stringio'
  $stdout, sout = StringIO.new, $stdout
  yield
  $stdout, str_io = sout, $stdout
   IO.popen(spool_cmd, 'w') do |f|
     f.write str_io.string
     f.flush
     f.close_write
   end
end

# Simple regular expression helper
# show_regexp - stolen from the pickaxe
def show_regexp(a, re)
   if a =~ re
      "#{$`}<<#{$&}>>#{$'}"
   else
      "no match"
   end
end

# Convenience method on Regexp so you can do
# /an/.show_match("banana")
class Regexp
   def show_match(a)
       show_regexp(a, self)
   end
end

# Textmate helper
def mate *args
  flattened_args = args.map {|arg| "\"#{arg.to_s}\""}.join ' '
  `mate #{flattened_args}`
  nil
end

# Vi helper
def vi *args
  flattened_args = args.map { |arg| "\"#{arg.to_s}\""}.join ' '
  `vi #{flattened_args}`
  nil
end  
