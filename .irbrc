require 'rubygems'
require 'wirble'
Wirble.init
Wirble.colorize

# stolen from github:cespare/dotfiles
class Object
  def cool_methods
    (self.methods - Object.new.methods).sort
  end
end

# print ruby version at every prompt
PROMPT_RUBY_VERSION = "[#{RUBY_VERSION}]"
IRB.conf[:PROMPT][:CUSTOM] = {
  :PROMPT_N => "#{PROMPT_RUBY_VERSION} #{'|'} ",
  :PROMPT_I => "#{PROMPT_RUBY_VERSION} #{'>'} ",
  :PROMPT_S => nil,
  :PROMPT_C => "#{PROMPT_RUBY_VERSION} #{'*'} ",
  :RETURN => "=> %s\n"
}
IRB.conf[:PROMPT_MODE] = :CUSTOM

IRB.conf[:SAVE_HISTORY] = 100

