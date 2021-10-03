require 'sqlite3'
require 'sequel'
db = Sequel.sqlite(File.expand_path('db/data.db'))

# Create table to log tweets that have been replied to if it doesn't already exist
db.create_table?(:reply_log) do
  primary_key :id
  Integer :tweet_id
end

# ActiveRecord model class for reply log for minor convenience
class ReplyLog < Sequel::Model(db[:reply_log].order(:tweet_id))
end
