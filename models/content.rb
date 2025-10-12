class Content < ActiveRecord::Base
  belongs_to :feed

  validates :url, presence: true, uniqueness: true
  validates :feed_id, presence: true
end
