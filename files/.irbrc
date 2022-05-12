# frozen_string_literal: true

require 'rubygems'

# print ruby version at every prompt
PROMPT_RUBY_VERSION = "[#{RUBY_VERSION}]".freeze
IRB.conf[:PROMPT][:CUSTOM] = {
  PROMPT_N: "#{PROMPT_RUBY_VERSION} | ",
  PROMPT_I: "#{PROMPT_RUBY_VERSION} > ",
  PROMPT_S: nil,
  PROMPT_C: "#{PROMPT_RUBY_VERSION} * ",
  RETURN: "=> %s\n"
}
IRB.conf[:PROMPT_MODE] = :CUSTOM

IRB.conf[:SAVE_HISTORY] = 1000
