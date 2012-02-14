#!/usr/bin/env ruby

require "redcarpet"

markdown_options = { :fenced_code_blocks => true, :tables => true, :space_after_headers => true }
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new, markdown_options)

text = ""
while gets
  text += $_
end
puts markdown.render(text)

