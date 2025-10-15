require 'feedjira'
require 'httparty'
require 'nokogiri'
require 'active_record'
require 'yaml'
require_relative 'models/feed'
require_relative 'models/content'

# Load database configuration and establish connection
db_config = YAML.load_file('db/config.yml', aliases: true)
ActiveRecord::Base.establish_connection(db_config['development'])
ActiveSupport.to_time_preserves_timezone = :zone

Feed.find_or_create_by!(url: "https://caseyhandmer.wordpress.com/feed/", title: "Casey's Blog")
Feed.find_or_create_by!(url: "https://lubieniebieski.pl/feed.xml", title: "Lubię Niebieski")
Feed.find_or_create_by!(url: "https://world.hey.com/dhh/feed.atom", title: "David Heinemeier Hansson")

Feed.find_each do |feed_record|
  xml = HTTParty.get(feed_record.url).body
  parsed_feed = Feedjira.parse(xml)

  parsed_feed.entries.each do |entry|
    next if entry.published && entry.published < 3.months.ago
    next if Content.exists?(url: entry.url)

    puts "Fetching: #{entry.title}"
    html = HTTParty.get(entry.url).body
    doc = Nokogiri::HTML(html)

    # Try to find the main article content
    article = doc.at_css('article, .post, .entry-content, .article-content, main, [role="main"]')

    if article
      # Remove unwanted elements
      article.css('script, style, nav, header, footer, aside, .sidebar, .comments, .related, .share, .social').remove

      content_html = article.inner_html
    else
      # Fallback: try to find body content
      content_html = doc.at_css('body')&.inner_html || html
    end

    feed_record.contents.create!(
      url: entry.url,
      title: entry.title,
      content: content_html,
      summary: entry.summary,
      published_at: entry.published
    )
  end

  feed_record.update!(last_fetched_at: Time.current)
end
