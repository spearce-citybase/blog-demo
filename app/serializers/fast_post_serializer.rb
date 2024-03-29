class FastPostSerializer
  def initialize(posts)
    @posts = posts
  end

  def call
    @posts.pluck_to_hash(:id, :title, :body).map do |post|
      post.merge({ 
        comments: comment_serializer.by_post_id[post[:id]],
        profile: profile_serializer.by_parent_id[post[:id]],
        metrics: post_metric_serializer.by_post_id[post[:id]]
      })
    end
  end

  private def comment_serializer
    @comment_serializer ||= FastCommentSerializer.new(Comment.where(post: @posts))
  end

  private def profile_serializer
    @profile_serializer ||= FastProfileSerializer.new(Profile.joins(:posts).where(posts: @posts), 'posts')
  end

  private def post_metric_serializer
    @post_metric_serializer ||= FastPostMetricSerializer.new(PostMetric.where(post: @posts))
  end
end