class PostSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :comments, :profile

  def comments
    ActiveModel::Serializer::CollectionSerializer.new(object.comments, serializer: CommentSerializer)
  end

  def profile
    ProfileSerializer.new(object.profile)
  end
end
