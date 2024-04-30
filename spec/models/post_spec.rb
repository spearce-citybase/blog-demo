require 'rails_helper'

RSpec.describe Post, type: :model do
  describe "associations" do
    it { should belong_to(:profile) }
    it { should have_many(:tags).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:flagged_comments).class_name('Comment').conditions(flag: true) }
    it { should have_one(:post_metric) }
  end

  describe "validations" do
    it { should validate_presence_of(:profile) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
  end

  describe "nested attributes" do
    it { should accept_nested_attributes_for(:comments) }
    it { should accept_nested_attributes_for(:tags) }
  end

  describe "delegations" do
    it { should delegate_method(:views).to(:post_metric) }
  end
end