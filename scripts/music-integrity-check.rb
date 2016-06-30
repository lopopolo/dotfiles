#!/usr/bin/env ruby

# This script looks through an iTunes music folder and performs several
# integrity checks. This script only uses the filesystem and thus,
# underestimates.
#
# # Integrity Checks
# ## Dupes
# Tracks are considered duplicates if they share an  (artist, album, disc
# number, track number) tuple.
#
# This definition of dupe is useful for cases where you may have two versions
# of an album mapped to the same folder (i.e., a US and Europe version) with
# different track names. (And also when you have actual duplicates.)
#
# Because the dupe checker ignores file extensions, it can also detect when you
# have multiple rips of the same album.
#
# ## Incomplete Albums
# Albums are considered incomplete if each disc's track numbers do not form a
# continuous range beginning at 1. This means the script cannot catch the case
# where you are missing tracks from the end of an album.
#
# # Library Maintenance
# Run this every once in a while to find tracks that iTunes hasn't moved to
# their rightful home:
# $ find ~/Music -name "* 2.mp3" | grep -iv "part" | grep -iv "pt" | less
#
# Run this to find tracks not tagged with featured artists at the end:
# $ find ~/Music -iname '*feat.*(*[a-z]*' | grep -v 'vs\.' | grep -v '_' |
# > grep -Ev 'feat[^\)]+\('
#
# Run this to find tracks missing the '.' after 'feat' in the featured artist
# list
# $ find ~/Music -name '*feat *'

require 'pathname'

# OS X only
MUSIC_DIR = File.expand_path '~/Music/iTunes/iTunes Media/Music'

unless Pathname.new(MUSIC_DIR).exist?
  abort 'Cannot find iTunes directory. This script only runs on OS X.'
end

TRACKS = Hash.new { |h, k| h[k] = [] }
NO_DISC = 'single disc album'.freeze

def metadata_from_path(path)
  album = File.basename(path)
  path = File.dirname(path)
  artist = File.basename(path)

  [artist, album]
end

def print_error(artist, album, disc, message)
  if disc == NO_DISC
    $stderr.puts "#{artist}/#{album}: #{message}"
  else
    $stderr.puts "#{artist}/#{album} (disc #{disc}): #{message}"
  end
end

(Dir.glob(File.join(MUSIC_DIR, '*', '*')) - %w(. ..)).each do |album_path|
  TRACKS.clear
  artist, album = metadata_from_path(album_path)

  (Dir.glob(File.join(album_path, '*')) - %w(. ..)).each do |song_path|
    song = Pathname.new(song_path).basename.to_path
    # assume tracks are numbered in the standard
    # iTunes way: optional_disk_number-track
    match = /^(?<disc>\d\d?-)?(?<track>\d\d)/.match(song)
    if match
      disc = match[:disc]
      disc = NO_DISC if disc.nil?
      TRACKS[disc.chomp('-')] << match[:track].to_i
    end
  end

  if TRACKS.key?(NO_DISC) && TRACKS.length > 1
    print_error(artist, album, NO_DISC, 'Album has no disc and disc number tracks')
  end
  TRACKS.each do |disc, track_numbers|
    # check for dupes
    if track_numbers.uniq != track_numbers
      print_error(artist, album, disc, 'Album contains duplicates')
    end
    # check that each disc in the album contains a continuous range of track
    # numbers that starts at 1
    track_num_range = (track_numbers.min..track_numbers.max).to_a
    if track_num_range.sort != track_numbers.uniq.sort || track_numbers.min > 1
      print_error(artist, album, disc, 'Incomplete album')
    end
  end
end
