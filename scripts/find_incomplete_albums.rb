#!/usr/bin/env ruby

# This script underestimates. It doesn't catch albums that are only
# missing tracks at the end.

# run this every once in a while to find tracks that iTunes hasn't moved
# to their rightful home
# ▶ find ~/Music -name "* 2.mp3" | grep -iv "part" | grep -iv "pt" | less

# run this to find tracks not tagged with featured artists at the end
# ▶ find ~/Music -iname "*feat.*mix*"
# ▶ find ~/Music -iname "*(feat.*(*"

require "pathname"

# OS X only
MUSIC_DIR = File.expand_path "~/Music/iTunes/iTunes Media/Music"

abort "Cannot find iTunes directory. This script only runs on OS X" if not Pathname.new(MUSIC_DIR).exist?

TRACKS = Hash.new { |h, k| h[k] = Array.new }
NO_DISC = "single disc album"

num_incomplete_albums = 0
(Dir.glob(File.join(MUSIC_DIR, "*")) - %w[. ..]).each do |artist_path|
  artist = Pathname.new(artist_path).basename.to_path

  (Dir.glob(File.join(artist_path, "*")) - %w[. ..]).each do |album_path|
    album = Pathname.new(album_path).basename.to_path
    TRACKS.clear

    (Dir.glob(File.join(album_path, "*")) - %w[. ..]).each do |song_path|
      song = Pathname.new(song_path).basename.to_path
      # assume tracks are numbered in the standard
      # iTunes way: optional_disk_number-track
      TRACKS[($1 || NO_DISC).chomp("-")] << $2.to_i if song =~ /^(\d\d?-)?(\d\d)/
    end

    TRACKS.each do |disc, track_numbers|
      # check that each disc in the album contains a continuous range of track numbers
      # that starts at 1
      track_num_range = (track_numbers.min..track_numbers.max).to_a
      if track_num_range.sort != track_numbers.sort || track_numbers.min > 1
        if disc.nil? || disc == NO_DISC
          $stderr.puts "#{artist}/#{album}"
        else
          $stderr.puts "#{artist}/#{album} (disc #{disc})"
        end
        $stderr.puts "=> #{TRACKS.inspect}"
        num_incomplete_albums += 1
      end
    end
  end
end
# by this point, we've looked at every file in MUSIC_DIR. Optimization say, what?

puts "#{num_incomplete_albums} incomplete albums"

