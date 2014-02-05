#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'twitter'

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

    @me = @rest_client.user.id
  end

  def run
    crawlar
  end

  def crawlar
    begin
      @stream_client.user do |message|
        p message
        case message
        when Twitter::Tweet
          if @me == message.user.id
            add message
          end
        end
      end
    rescue JSON::ParserError, EOFError => e
      p e
      retry
    end
  end

  def add(message)
    Thread.start(message) do
      sleep 60 * 60
      delete message
    end
  end

  def delete(message)
    @rest_client.destroy_status(message.id)
  end
end

atd = AutoTweetDelete2.new({
  'consumer_key'        => ENV['consumer_key'],
  'consumer_secret'     => ENV['consumer_secret'],
  'access_token'        => ENV['access_token'],
  'access_token_secret' => ENV['access_token_secret'],
})
atd.run
