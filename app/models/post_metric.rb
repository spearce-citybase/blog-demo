class PostMetric < ApplicationRecord
  belongs_to :post
  validates_uniqueness_of :post_id
end