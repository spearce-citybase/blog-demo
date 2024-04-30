require 'rails_helper'

RSpec.describe PostMetric, type: :model do
  describe "associations" do
    it { should belong_to(:post) }
  end

  describe "validations" do
    it { should validate_uniqueness_of(:post_id) }
  end
end