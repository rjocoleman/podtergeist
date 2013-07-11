require 'rss/2.0'
require 'rss/itunes'
require 'mime/types'
require 'taglib'
require 'uri'
require 'fileutils'

module Podtergeist
  class Feed
    class << self

      def add(feed,params)
        create_channel(feed,params) unless feed_exists?(feed)
        append_item(feed,params)
      end

      def existing(feed,params)
        shows = Dir.glob("#{params['local_directory']}/*.{m4a,mp3}")
        create_channel(feed,params,shows.first)
        shows.each do |file|
          append_item(feed,params,file)
        end
      end

      private

      # check to see if the destination exists
      def feed_exists?(path)
        File.exist?(path)
      end

      # create
      def create_channel(path,params,local_file=params['local_file'])
        rss = RSS::Rss.new('2.0')
        channel = RSS::Rss::Channel.new

        # If we have an existing file we prefer it to improperly escaped supplied data.
        metadata = retrieve_file_metadata(local_file)
        channel.title = metadata['episode_title'] || params['show_title']
        channel.description = metadata['show_description'] || params['show_description']
        channel.link = metadata['show_link'] || params['show_link']

        rss.channel = channel
        write_rss_file!(path, rss)
      end

      # add item
      def append_item(path,params,local_file=params['local_file'])
        rss = RSS::Parser.parse(File.new(path))
        rss.items << rss_channel_item(local_file, params)
        write_rss_file!(path, rss)
      end

      protected
      def retrieve_file_metadata(file)
        metadata = {}
        if file
          TagLib::FileRef.open(file) do |fileref|
            tag = fileref.tag
            metadata.update({
              'episode_title' => tag.album,
              'show_description' => "#{tag.album} on #{tag.artist}"
            })
          end
        end
        metadata
      end

      def rss_channel_item(local_file, params)
        TagLib::FileRef.open(local_file) do |fileref|
          unless fileref.null?
            tag = fileref.tag
            properties = fileref.audio_properties

            item = RSS::Rss::Channel::Item.new
            item.title = tag.title
            item.link = params['episode_link'] unless params['episode_link'].nil?
            if pub_date = params['episode_pubdate'] || pub_date = File.ctime(local_file).to_s
              item.pubDate = Date.parse(pub_date).rfc822
            end

            item.guid = RSS::Rss::Channel::Item::Guid.new
            item.guid.content = params['episode_link'] unless params['episode_link'].nil?
            item.guid.isPermaLink = true

            item.description = tag.comment

            remote = URI.escape("#{params['host']}/#{File.basename(local_file)}")
            item.enclosure = RSS::Rss::Channel::Item::Enclosure.new(
              remote, properties.length, MIME::Types.type_for(local_file).first
            )

            return item
          end
        end
      end

      def write_rss_file!(path, rss, mode = 'w')
        File.open(path, mode) { |file| file.write(rss.to_s) }
      end

    end
  end
end
