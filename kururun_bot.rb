require 'bundler/setup'
require 'rufus-scheduler'
scheduler = Rufus::Scheduler.new
ENV['TZ'] = 'GMT'
require 'twitter'
require 'yaml'
require 'json'
require 'x'

# Method to use the v1.1 endpoint to upload media without posting it (uses twitter gem's private utility method)
module Twitter
  module REST
    module API
      include Twitter::REST::UploadUtils

      def upload_without_post(media)
        upload(media)
      end
    end
  end
end

# Load config from file and initialize clients
loaded_config = YAML.load_file('config.yml')
v1_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = loaded_config['consumer_key']
  config.consumer_secret     = loaded_config['consumer_secret']
  config.access_token        = loaded_config['access_token']
  config.access_token_secret = loaded_config['access_token_secret']
end
v2_client = X::Client.new(
  api_key:             loaded_config['consumer_key'],
  api_key_secret:      loaded_config['consumer_secret'],
  access_token:        loaded_config['access_token'],
  access_token_secret: loaded_config['access_token_secret']
)

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
    media = v1_client.upload_without_post(File.new(filepath))
    body = {
      text: '',
      media: {media_ids: [media[:media_id_string]]}
    }.to_json
    v2_client.post('tweets', body)
    last_uploaded = File.basename(filepath)
  end
end

scheduler.join
