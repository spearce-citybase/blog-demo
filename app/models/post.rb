class Post < ApplicationRecord
  belongs_to :profile
  has_many :tags, dependent: :destroy
  has_many :comments, dependent: :destroy

  validates_presence_of :profile, :title, :body
  accepts_nested_attributes_for :comments, :tags
end
