class PostSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :comments

  def comments
    ActiveModel::Serializer::CollectionSerializer.new(object.comments, serializer: CommentSerializer)
  end
end
