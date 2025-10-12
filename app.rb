require 'feedjira'
require 'httparty'
require 'debug'
require 'readability'
require 'active_record'
require 'yaml'
require_relative 'models/feed'

# Load database configuration and establish connection
db_config = YAML.load_file('db/config.yml', aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])
ActiveSupport.to_time_preserves_timezone = :zone


Feed.find_or_create_by!(url: "https://caseyhandmer.wordpress.com/feed/", title: "Casey's Blog")

Feed.find_each do |feed|
  xml = HTTParty.get(feed.url).body
  feed = Feedjira.parse(xml)
  puts feed.entries[0].title
  html = HTTParty.get(feed.entries[0].url).body
  document = Readability::Document.new(html, tags: %w[div p img a ul li], attributes: %w[src href])
  puts document.content
end


