class PostSerializer < ActiveModel::Serializer
  attributes :id, :body, :title, :comments, :profile, :metrics

  def comments
    ActiveModel::Serializer::CollectionSerializer.new(object.comments, serializer: CommentSerializer)
  end

  def profile
    ProfileSerializer.new(object.profile)
  end

  def metrics
    object.post_metric ? PostMetricSerializer.new(object.post_metric) : nil
  end
end
