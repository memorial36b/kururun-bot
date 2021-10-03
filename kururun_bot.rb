require 'bundler/setup'
require_relative 'db/database_init'
require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
ENV['TZ'] = 'GMT'
require 'twitter'
require 'yaml'

# Possible responses to reply with when user replies to or mentions bot
RESPONSES = YAML.load_file('responses.yml')

# Load config from file and initialize client
loaded_config = YAML.load_file('config.yml')
client = Twitter::REST::Client.new do |config|
  config.consumer_key        = loaded_config[:consumer_key]
  config.consumer_secret     = loaded_config[:consumer_secret]
  config.access_token        = loaded_config[:access_token]
  config.access_token_secret = loaded_config[:access_token_secret]
end

# Variable that tracks the last uploaded image/GIF so there are no repeats
last_uploaded = ''

# Send a random image every hour from the media/ folder, prioritizing files in
# the media/priority/ folder
scheduler.cron '0 * * * *' do
  if Dir.empty?('media/priority')
    files = Dir.glob('media/*.*')
  else
    files = Dir.glob('media/priority/*.*')
  end

  if files.size <= 1 # Skip the last_uploaded check if there are no files or only one file
    filepath = files[0]
  else
    filepath = files.select { |f| File.basename(f) != last_uploaded }.sample
  end

  if filepath
    client.update_with_media('', File.open(filepath))
    last_uploaded = File.basename(filepath)
  end
end

# Check for new mentions every 30 seconds, reply to them, and add tweet id to
# the database to ensure replies only occur once
scheduler.every '30s' do
  if ReplyLog.last
    opts = {since_id: ReplyLog.last[:tweet_id]}
  else
    opts = {}
  end
  client.mentions(opts).each do |to_reply|
    client.update("@#{to_reply.user.screen_name} #{RESPONSES.sample}", in_reply_to_status: to_reply)
    ReplyLog.create(tweet_id: to_reply.id)
  end
end

scheduler.join
