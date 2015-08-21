# -*- coding: utf-8 -*-
require 'twitter'

Plugin.create :tweet_with_signature do

  @clients = {}

  unless UserConfig[:twitter_secret] # mikutter >= 3.0.0
    @clients[Service.primary.idname] = Twitter::REST::Client.new do |c|
      c.consumer_key       = Service.primary.twitter.consumer_key
      c.consumer_secret    = Service.primary.twitter.consumer_secret
      c.oauth_token        = Service.primary.twitter.a_token
      c.oauth_token_secret = Service.primary.twitter.a_secret
    end
  else # mikutter < 3.0.0
    if defined? Twitter::REST
      @clients[Service.primary.idname] = Twitter::REST::Client.new do |c|
        c.consumer_key       = CHIConfig::TWITTER_CONSUMER_KEY
        c.consumer_secret    = CHIConfig::TWITTER_CONSUMER_SECRET
        c.oauth_token        = UserConfig[:twitter_token]
        c.oauth_token_secret = UserConfig[:twitter_secret]
      end
    else
      Twitter.configure do |c|
        c.consumer_key       = CHIConfig::TWITTER_CONSUMER_KEY
        c.consumer_secret    = CHIConfig::TWITTER_CONSUMER_SECRET
        c.oauth_token        = UserConfig[:twitter_token]
        c.oauth_token_secret = UserConfig[:twitter_secret]
      end
      @clients[Service.primary.idname] = Twitter.client
    end
  end

  command(:tweet_with_signature,
          name: '署名つきで投稿する',
          condition: lambda{ |opt| true },
          visible: true,
          role: :postbox) do |opt|
    begin
      message = Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text + " #shigemk2"
      Thread.new {
        Post.primary_service.update(:message => message)
      }
      Plugin.create(:gtk).widgetof(opt.widget).widget_post.buffer.text = ''
    rescue Exception => e
      puts e.to_s
      Plugin.call(:update, nil, [Message.new(message: e.to_s, system: true)])
    end
  end
end

