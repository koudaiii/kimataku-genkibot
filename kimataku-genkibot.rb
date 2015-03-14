#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'logger'
require 'tweetstream'

log = Logger.new(STDOUT)
STDOUT.sync = true

# REST API
rest = Twitter::Client.new(
  :consumer_key       => ENV['TWITTER_CONSUMER_KEY'],
  :consumer_secret    => ENV['TWITTER_CONSUMER_SECRET'],
  :oauth_token        => ENV['TWITTER_ACCESS_TOKEN'],
  :oauth_token_secret => ENV['TWITTER_ACCESS_TOKEN_SECRET'],
)
# Streaming API
TweetStream.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  config.auth_method        = :oauth
end
#stream = TweetStream::Client.new
TweetStream::Client.new.userstream do |status|
  puts "#{status.user.screen_name}: #{status.text}"
end

#EM.error_handler do |e|
#  raise e.message
#end
#EM.run do
#  stream.on_inited do
#    log.info('init')
#  end
#  stream.userstream do |status|
#    next if status.retweet?
#    next if status.reply?
#
#    log.info('status from @%s: %s' % [status.from_user, status.text])
#    shinpai = '@%s ' % status.from_user
#    case status.text
#    when /https?:\/\//
#      next
#    when /疲(?!れ(?:様|さ(?:ま|ん)))/
#      shinpai += '疲れてるの？'
#    when /凹/
#      shinpai += '凹んでるの？'
#    when /心折/
#      shinpai += '心折れてるの？'
#    when /(?:寂|淋)し/
#      shinpai += 'さびしいの？'
#    when /弱っ/
#      shinpai += '弱ってるの？'
#    when /つらい/
#      shinpai += 'つらくても、'
#    when /死にたい/
#      shinpai += '死なないで、'
#    when /お腹痛い/
#      shinpai += 'トイレ行って、'
#    when /(?:。。。|orz)/
#    when /テスト/
#    else
#      next
#    end
#
#    # 適当に間隔あける
#    EM.add_timer(rand(5) + 5) do
#      hagemashi = rand > 0.05 ? 'げんきだして！' : 'まぁげんきだせやｗｗｗｗｗ'
#      message = shinpai + hagemashi
#      if rand < (status.from_user == 'kimataku' ? 0.01 : 0.0001)
#        message = '@%s 社畜力がぐーんとアップしました' % status.from_user
#      end
#      begin
#        tweet = rest.update(message, {
#          :in_reply_to_status_id => status.id,
#        })
#        if tweet
#          log.info('tweeted: %s' % tweet.text)
#        end
#      rescue => e
#        log.error(e)
#      end
#    end
#  end
#end
