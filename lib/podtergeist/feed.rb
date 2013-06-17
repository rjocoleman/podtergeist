require 'rss/2.0'
require 'rss/itunes'
require 'mime/types'
require 'taglib'
require 'uri'

module Podtergeist
  class Feed
    class << self

      def add(feed,params)
        create_channel(feed,params) unless feed_exists?(feed)
        append_item(feed,params)
      end
      
      def existing(feed,params)
        create_channel(feed,params) unless feed_exists?(feed)
        Dir.glob("#{params['local_directory']}/*.{m4a,mp3}").each do |file|
          append_item(feed,params,file)
        end
      end

      private

      # check to see if the destination exists
      def feed_exists?(path)
        File.exist?(path)
      end

      # create 
      def create_channel(path,params)
        rss = RSS::Rss.new('2.0')
        channel = RSS::Rss::Channel.new
      
        channel.title = params['show_title']
        channel.description = params['show_description']
        channel.link = params['show_link']

        rss.channel = channel

        file = File.new(path, 'w')
        file.write(rss.to_s)
        file.close
      end

      # add item
      def append_item(path,params,file=params['file_file'])
        remote = URI.escape("#{params['host']}/#{File.basename(file)}")

        TagLib::FileRef.open(file) do |fileref|
          unless fileref.null?
            tag = fileref.tag
            properties = fileref.audio_properties

            rss = RSS::Parser.parse(File.new(path))

            item = RSS::Rss::Channel::Item.new
            item.title = tag.title
            item.link = params['episode_link'] unless params['episode_link'].nil?

            item.pubDate = Date.parse(params['episode_pubdate']).rfc822 unless params['episode_pubdate'].nil?

            item.guid = RSS::Rss::Channel::Item::Guid.new
            item.guid.content = params['episode_link'] unless params['episode_link'].nil?
            item.guid.isPermaLink = true

            item.description = tag.title

            item.enclosure = RSS::Rss::Channel::Item::Enclosure.new(remote, properties.length, MIME::Types.type_for(file).first)

            rss.items << item

            file = File.new(path, 'w')
            file.write(rss.to_s)
            file.close
          end
        end 
      end

    end
  end
end