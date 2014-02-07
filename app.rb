#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'twitter'
require 'cgi'
require 'open-uri'

class AutoTweetDelete2
  def initialize(args = {})
    @stream_client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = args['consumer_key']
      config.consumer_secret     = args['consumer_secret']
      config.access_token        = args['access_token']
      config.access_token_secret = args['access_token_secret']
    end

    @rest_client = Twitter::REST::Client.new do |config|
      config.consumer_key        = args['consumer_key']
      config.consumer_secret     = args['consumer_secret']
      config.access_token        = args['access_token']
      config.access_token_secret = args['access_token_secret']
    end

    @me = @rest_client.user
  end

  def run
    Thread.start { rest_crawlar }
    streaming_crawlar
  end

  def rest_crawlar
    @rest_client.user_timeline(:me, :count => 200).each do |tweet|
      add tweet
    end
  end

  def streaming_crawlar
    begin
      @stream_client.user do |tweet|
        case tweet
        when Twitter::Tweet
          if @me.id == tweet.user.id
            add tweet
          end
        end
      end
    rescue JSON::ParserError, EOFError => e
      p e
      retry
    end
  end

  def yuueki?(tweet)
    url = "http://yuueki-api.s5r.jp/yuueki?q=#{CGI.escape(tweet.text)}"
    yuueki = false
    begin
      yuueki = ( open(url).read == 'true' )
    rescue => e
    end
    yuueki
  end

  def add(tweet)
    return if yuueki? tweet
    Thread.start(tweet) do
      wait = tweet.created_at.to_i - Time.now.to_i + 60 * 60
      sleep wait if wait > 0
      delete tweet
    end
  end

  def delete(tweet)
    @rest_client.destroy_status(tweet.id)
  end
end

atd = AutoTweetDelete2.new({
  'consumer_key'        => ENV['consumer_key'],
  'consumer_secret'     => ENV['consumer_secret'],
  'access_token'        => ENV['access_token'],
  'access_token_secret' => ENV['access_token_secret'],
})
atd.run
