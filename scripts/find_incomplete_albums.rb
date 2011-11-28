#!/usr/bin/env ruby

# This script underestimates. It doesn't catch albums that are only
# missing tracks at the end.

# run this every once in a while to find tracks that iTunes hasn't moved
# to their rightful home
# ▶ find ~/Music -name "* 2.mp3" | grep -iv "part" | grep -iv "pt" | less

# yes, its hard-coded for macs. Get over it.
MUSIC_DIR = File.expand_path "~/Music/iTunes/iTunes Media/Music"

# let's not create 30k copies of this regex and another 30k hashes, mmkay?
IGNORE_REGEXP = Regexp.compile(/^\./)
TRACKS = Hash.new { Array.new }

num_incomplete_albums = 0
Dir.new(MUSIC_DIR).each do |artist|
  next if artist =~ IGNORE_REGEXP # ignore hidden/special files and directories
  Dir.new(artist_dir = File.join(MUSIC_DIR, artist)).each do |album|
    next if album =~ IGNORE_REGEXP
    TRACKS.clear # you mean we can reuse data structures?!?!
    Dir.new(File.join(artist_dir, album)).each do |song|
      # assume tracks are numbered in the standard
      # iTunes way: optional_disk_number-track
      TRACKS[$1] = TRACKS[$1] << $2.to_i if song =~ /^(\d\d?-)?(\d\d)/
    end

    bad = false
    TRACKS.each_key do |key|
      # check that the album
      track_num_range = (TRACKS[key].min..TRACKS[key].max).to_a
      bad = true if track_num_range.sort != TRACKS[key].sort || TRACKS[key].min > 1
    end
    # check to see if the bad designation is due to a multidisk album with
    # continuous track numbering
    if bad
      all = TRACKS.values.flatten
      track_num_range = *(all.min..all.max).to_a
      bad = false if track_num_range.sort == all.sort && all.min == 1
    end
    # if still bad, do the output
    if bad || TRACKS.length > 1 && TRACKS.has_key?(nil)
      puts "#{artist}/#{album}"
      num_incomplete_albums += 1
    end
  end
end
# by this point, we've looked at every file in MUSIC_DIR. Optimization say, what?

puts "\n#{num_incomplete_albums} incomplete albums"

