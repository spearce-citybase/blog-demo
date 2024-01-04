class PostSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :profile, :is_first_post_by_profile

  def comments
    ActiveModel::Serializer::CollectionSerializer.new(object.comments, serializer: CommentSerializer)
  end
end
