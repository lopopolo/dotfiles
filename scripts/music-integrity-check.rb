#!/usr/bin/env ruby
# frozen_string_literal: true

# This script looks through an iTunes music folder and performs several
# integrity checks. This script only uses the filesystem and thus,
# underestimates.
#
# # Integrity Checks
# ## Dupes
# Tracks are considered duplicates if they share an (artist, album, disc
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
require 'set'

module Hyper
  module MusicIntegrity
    Album = Struct.new(:artist, :title, :database)

    class Runner
      SOURCE = File.expand_path('~/Music/iTunes/iTunes Media/Music')
      NO_DISC_SENTINEL = 'no-disc'

      def self.main
        source = LibrarySource.new(SOURCE, NO_DISC_SENTINEL)
        checks = [
          Checks::InconsistentDiscNumbering.new(NO_DISC_SENTINEL),
          Checks::DuplicateTracks.new,
          Checks::MissingTracks.new
        ]
        source.scan do |database|
          checks.each do |check|
            next if check.valid?(database)

            warn("#{database.artist}/#{database.title}: #{check}")
          end
        end
      end
    end

    class LibrarySource
      EXT = Set.new(%w[.alac .flac .m4a .mp3]).freeze

      def initialize(path, no_disc_sentinel)
        @root = Pathname.new(path)
        @no_disc_sentinel = no_disc_sentinel
      end

      def scan
        database = Hash.new { |h, k| h[k] = [] }
        @root.children.each do |artistp|
          next if artistp.file?

          artist = artistp.basename.to_path
          artistp.children.each do |albump|
            next if albump.file?

            album = albump.basename.to_path
            albump.children.each do |songp|
              next unless EXT.include?(songp.extname.downcase)
              next unless songp.file?

              song = songp.basename.to_path
              match = /^(?:(?<disc>\d\d?)-)?(?<track>\d\d)/.match(song)
              next unless match

              disc = match[:disc] || @no_disc_sentinel
              database[disc] << match[:track].to_i
            end
            yield Album.new(artist, album, database)
            database.clear
          end
        end
      end
    end

    module Checks
      class Check
        # @abstract Subclass is expected to implement #valid?
        # @!method valid?
      end

      class InconsistentDiscNumbering < Check
        def initialize(no_disc_sentinel)
          @no_disc_sentinel = no_disc_sentinel
        end

        def valid?(album)
          !(album.database.key?(@no_disc_sentinel) && album.database.length > 1)
        end

        def to_s
          'inconsistent disc numbering'
        end
      end

      class DuplicateTracks < Check
        def valid?(album)
          album.database.all? { |_, tracks| tracks.uniq.length == tracks.length }
        end

        def to_s
          'duplicate track numbers'
        end
      end

      class MissingTracks < Check
        def valid?(album)
          album.database.each do |_, tracks|
            tracks = tracks.sort
            return false unless tracks.first == 1

            tracks.each_cons(2) do |a, b|
              return false unless a + 1 == b
            end
          end
          true
        end

        def to_s
          'missing tracks'
        end
      end
    end
  end
end

Hyper::MusicIntegrity::Runner.main if $PROGRAM_NAME == __FILE__
