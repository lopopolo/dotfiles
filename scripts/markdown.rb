#!/usr/bin/env ruby

require "redcarpet"

markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)

text = ""
while gets
  text += $_
end
puts markdown.render(text)

