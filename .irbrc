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

