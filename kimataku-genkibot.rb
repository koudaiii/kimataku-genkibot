#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'logger'
require 'tweetstream'

log = Logger.new(STDOUT)
STDOUT.sync = true

# REST API
rest = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.access_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
end

# Streaming API
TweetStream.configure do |config|
  config.consumer_key       = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret    = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token        = ENV['TWITTER_ACCESS_TOKEN']
  config.oauth_token_secret = ENV['TWITTER_ACCESS_TOKEN_SECRET']
  config.auth_method        = :oauth
end
stream = TweetStream::Client.new

@context=""

log.info('Working up to save the world... %s' % ["#{Time.now}"])
log.info('Listening... %s' % ["#{Time.now}"])

stream.on_error do |message|
  log.info('Error: %s' % ["#{Time.now}"])
  raise message
end

stream.on_timeline_status do |status|
  log.info('timeline: %s' % ["#{Time.now}"])
  log.info('@%s said : %s' % [status.user.screen_name, status.text])
  next if status.retweet?
  next if status.user.screen_name == "kimataku_bot"
  if status.reply? && /kimataku_bot/ =~ status.text
    log.info('reply to @%s said : %s' % [status.user.screen_name, status.text])
    message = '@%s ' % status.user.screen_name
    message += reply_text(status.text)
    log.info('dialog to @%s : %s' % [status.user.screen_name, message])
  else
    shinpai = '@%s ' % status.user.screen_name
    case status.text
    when /https?:\/\//
      next
    when /疲(?!れ(?:様|さ(?:ま|ん)))/
      shinpai += '疲れてるの？'
    when /凹/
      shinpai += '凹んでるの？'
    when /心折/
      shinpai += '心折れてるの？'
    when /(?:寂|淋)し/
      shinpai += 'さびしいの？'
    when /弱っ/
      shinpai += '弱ってるの？'
    when /つらい/
      shinpai += 'つらくても、'
    when /死にたい/
      shinpai += '死なないで、'
    when /お腹痛い/
      shinpai += 'トイレ行って、'
    when /(?:。。。|orz)/
    when /テスト/
    else
      next
    end
    hagemashi = rand > 0.05 ? 'げんきだして！' : 'まぁげんきだせやｗｗｗｗｗ'
    message = shinpai + hagemashi
    if rand < (status.user.screen_name == 'kimataku' ? 0.01 : 0.0001)
      message = '@%s 社畜力がぐーんとアップしました' % status.user.screen_name
    end
  end

  begin
    tweet = rest.update("#{message}", in_reply_to_status_id: status.id)
    if tweet
      log.info('tweeted: %s' % tweet.text)
    end
  rescue => e
    log.error(e)
  end
end

def reply_text(text="")
  apikey = ENV['DOCOMO_API_KEY']
  uri = URI.parse("https://api.apigw.smt.docomo.ne.jp/dialogue/v1/dialogue?APIKEY=#{apikey}")
  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true

  body = {}
  body['utt'] = text
  body['t'] = 20
  body['context'] = @context

  request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
  request.body = body.to_json
  response = nil
  resp = http.request(request)
  response = JSON.parse(resp.body)

  @context = response['context']

  return response['utt']
end
stream.userstream
