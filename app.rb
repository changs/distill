require 'feedjira'
require 'httparty'
require 'debug'
require 'readability'
require 'active_record'
require 'yaml'
require_relative 'models/feed'
require_relative 'models/content'

# Load database configuration and establish connection
db_config = YAML.load_file('db/config.yml', aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])
ActiveSupport.to_time_preserves_timezone = :zone


Feed.find_or_create_by!(url: "https://caseyhandmer.wordpress.com/feed/", title: "Casey's Blog")

Feed.find_each do |feed_record|
  xml = HTTParty.get(feed_record.url).body
  parsed_feed = Feedjira.parse(xml)

  parsed_feed.entries.each do |entry|
    next if entry.published && entry.published < 3.months.ago
    next if Content.exists?(url: entry.url)

    puts "Fetching: #{entry.title}"
    html = HTTParty.get(entry.url).body
    document = Readability::Document.new(html, tags: %w[div p img a ul li], attributes: %w[src href])

    feed_record.contents.create!(
      url: entry.url,
      title: entry.title,
      content: document.content,
      summary: entry.summary,
      published_at: entry.published
    )
  end

  feed_record.update!(last_fetched_at: Time.current)
end
