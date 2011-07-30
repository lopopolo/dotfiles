#!/usr/bin/env ruby

# This script inits a repo and pushes it to github for the
# first time

USAGE <<-EOS
USAGE:
#{$0} repo-name ["true" if script should also call `git init`] [override username]
EOS

abort USAGE if ARGV.length < 1
repo_name = ARGV[0]

git_init = false
if ARGV.length > 1
  abort USAGE if ARGV[1] != "true"
  git_init = true
end

user_name = "lopopolo"
user_name = ARGV[2] if ARGV.length > 2

# git init
if git_init
  puts "$ git init"
  system "git init"
end

# add remote
puts "$ git remote add origin git@github.com:#{user_name}/#{repo_name}.git"
system "git remote add origin git@github.com:#{user_name}/#{repo_name}.git"

# push to master
puts "$ git push -u origin master"
system "git push -u origin master"
