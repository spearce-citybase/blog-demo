require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe "associations" do
    it { should have_many(:posts) }
    it { should have_many(:comments) }
  end
end