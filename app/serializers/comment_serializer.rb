class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :post_id, :profile

  def profile
    ProfileSerializer.new(object.profile)
  end
end
