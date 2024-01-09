class PostSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :comments, :profile, :metrics

  def comments
    ActiveModel::Serializer::CollectionSerializer.new(object.comments, serializer: CommentSerializer)
  end

  def profile
    ProfileSerializer.new(object.profile)
  end

  def metrics
    PostMetricSerializer.new(object.post_metric)
  end
end
