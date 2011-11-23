#!/usr/bin/env ruby

# This script underestimates. It doesn't catch albums that are only
# missing tracks at the end.

# yes, its hard-coded for macs. Get over it.
MUSIC_DIR = File.expand_path "~/Music/iTunes/iTunes Media/Music"

# let's not create 30k copies of this regex and another 30k hashes, mmkay?
IGNORE_REGEXP = Regexp.compile(/^\./)
TRACKS = []

num_incomplete_albums = 0
Dir.new(MUSIC_DIR).each do |artist|
  next if artist =~ IGNORE_REGEXP # ignore hidden/special files and directories
  Dir.new(artist_dir = File.join(MUSIC_DIR, artist)).each do |album|
    next if album =~ IGNORE_REGEXP
    TRACKS.clear # you mean we can reuse data structures?!?!
    Dir.new(File.join(artist_dir, album)).each do |song|
      # assume tracks are numbered in the standard
      # iTunes way: optional_disk_number-track
      TRACKS << $2.to_i if song =~ /^(\d\d?-)?(\d\d)/
    end
    if TRACKS.max > TRACKS.length
      puts "#{artist}/#{album}"
      num_incomplete_albums += 1
    end
  end
end
# by this point, we've looked at every file in MUSIC_DIR. Optimization say, what?

puts "#{num_incomplete_albums} incomplete albums"

