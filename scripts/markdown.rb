#!/usr/bin/env ruby
# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'redcarpet'

HEADER = <<~PREAMBLE
  <html>
    <head>
      <!-- https://github.com/sindresorhus/github-markdown-css -->
      <link rel="stylesheet" href="https://sindresorhus.com/github-markdown-css/github-markdown.css">
      <style>
        .markdown-body {
          box-sizing: border-box;
          min-width: 200px;
          max-width: 980px;
          margin: 0 auto;
          padding: 45px;
        }

        @media (max-width: 767px) {
          .markdown-body {
            padding: 15px;
          }
        }
      </style>
    </head>
    <body>
      <article class="markdown-body">
PREAMBLE

FOOTER = <<~FOOTER
      </article>
    </body>
  </html>
FOOTER

options = { fenced_code_blocks: true, tables: true, space_after_headers: true }
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)

puts HEADER
puts markdown.render(ARGF.read)
puts FOOTER
