#!/usr/bin/env ruby

# This (stupid) script looks through an iTunes library and finds
# "duplicate" tracks. Tracks are considered duplicates if they share
# an (artist, album, track number) tuple.
#
# This definition of dupe is useful for cases where you may have two versions
# of an album mapped to the same folder (i.e., a US and Europe version) with
# different track names. (And also when you have actual duplicates.)

# TODO: suggest which version to delete by detecting bitrates

# yes, its hard-coded for macs. Get over it.
MUSIC_DIR = File.expand_path "~/Music/iTunes/iTunes Media/Music"

# let's not create 30k copies of this regex and another 30k hashes, mmkay?
IGNORE_REGEXP = Regexp.compile(/^\./)
TRACK_COUNTS = Hash.new(0)

num_dupe_albums = 0
Dir.new(MUSIC_DIR).each do |artist|
  next if artist =~ IGNORE_REGEXP # ignore hidden/special files and directories
  Dir.new(artist_dir = File.join(MUSIC_DIR, artist)).each do |album|
    next if album =~ IGNORE_REGEXP
    TRACK_COUNTS.clear # you mean we can reuse data structures?!?!
    Dir.new(File.join(artist_dir, album)).each do |song|
      # assume tracks are numbered in the standard
      # iTunes way: optional_disk_number-track
      TRACK_COUNTS[$2] += 1 if song =~ /^(\d\d?-)?(\d\d)/
    end
    if TRACK_COUNTS.values.max > 1
      puts "#{artist}/#{album}"
      num_dupe_albums += 1
    end
  end
end
# by this point, we've looked at every file in MUSIC_DIR. Optimization say, what?
# It is hard to avoid scannin every file because we can't assume that all albums
# are complete.

puts "#{num_dupe_albums} dupe albums"
