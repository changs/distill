require 'feedjira'
require 'httparty'
require 'debug'
require 'readability'

url = "https://caseyhandmer.wordpress.com/feed/"
xml = HTTParty.get(url).body
feed = Feedjira.parse(xml)

puts feed.entries[0].title

html = HTTParty.get(feed.entries[0].url).body
document = Readability::Document.new(html, tags: %w[div p img a ul li], attributes: %w[src href])
puts document.content

