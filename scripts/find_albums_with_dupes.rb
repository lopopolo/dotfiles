#!/usr/bin/env ruby

# This script looks through an iTunes library and finds duplicate tracks.
# Tracks are considered duplicates if they share an
# (artist, album, disc number, track number) tuple.
#
# This definition of dupe is useful for cases where you may have two versions
# of an album mapped to the same folder (i.e., a US and Europe version) with
# different track names. (And also when you have actual duplicates.)

require "pathname"

# OS X only
MUSIC_DIR = File.expand_path "~/Music/iTunes/iTunes Media/Music"

abort "Cannot find iTunes directory. This script only runs on OS X" if not Pathname.new(MUSIC_DIR).exist?

TRACK_COUNTS = Hash.new { |h, k| h[k] = Hash.new(0) }
NO_DISC = "single disc album"

num_dupe_albums = 0
(Dir.glob(File.join(MUSIC_DIR, "*")) - %w[. ..]).each do |artist_path|
  artist = Pathname.new(artist_path).basename.to_path

  (Dir.glob(artist_dir = File.join(artist_path, "*")) - %w[. ..]).each do |album_path|
    album = Pathname.new(album_path).basename.to_path
    TRACK_COUNTS.clear

    (Dir.glob(File.join(album_path, "*")) - %w[. ..]).each do |song_path|
      song = Pathname.new(song_path).basename.to_path
      # assume tracks are numbered in the standard
      # iTunes way: optional_disk_number-track
      TRACK_COUNTS[$1 || NO_DISC][$2] += 1 if song =~ /^(\d\d?-)?(\d\d)/
    end

    TRACK_COUNTS.each do |disc, tracks|
      if tracks.values.max.nil?
        if disc.nil? || disc == NO_DISC
          $stderr.puts "No tracks found for #{artist}/#{album}"
        else
          $stderr.puts "No tracks found for #{artist}/#{album} (disc #{disc})"
        end
        $stderr.puts TRACK_COUNTS.inspect
      elsif tracks.values.max > 1
        if disc.nil? || disc == NO_DISC
          $stderr.puts "#{artist}/#{album}"
        else
          $stderr.puts "#{artist}/#{album} (disc #{disc})"
        end
        $stderr.puts TRACK_COUNTS.inspect
        num_dupe_albums += 1
      end
    end
  end
end

puts "#{num_dupe_albums} dupe albums"
