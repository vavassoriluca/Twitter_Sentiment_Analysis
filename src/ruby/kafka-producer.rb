require 'tweetstream'
require 'ruby-kafka'

def start_tweet_stream tracks
  TweetStream.configure do |config|
    config.consumer_key       =  ENV['consumer_key']
    config.consumer_secret    =  ENV['consumer_secret']
    config.oauth_token        =  ENV['access_token']
    config.oauth_token_secret =  ENV['access_token_secret']
    config.auth_method        =  :oauth
  end

  logger = Logger.new($stderr)
  brokers = ["localhost:9092"]

  topic = "twitter"

  kafka = Kafka.new(brokers, client_id: "twitter-producer", logger: logger)

  producer = kafka.producer

  begin
    TweetStream::Client.new.track(tracks,  language: 'en') do |status|
      p "#{status.user.name}"
      p "#{status.text}"
      print "\n\n\n"
      message = tracks.join + "@B1A2R3R4I5E6R7@" + status.text
      producer.produce(message, topic: topic)
      producer.deliver_messages
  end
    
  ensure
    producer.deliver_messages
    producer.shutdown
  end
end