class FastPostSerializer
  def initialize(posts)
    @posts = posts
  end

  def call
    @posts.distinct.pluck_to_hash(:id, :title, :body).map do |post|
      post.merge({ 
        comments: comment_serializer.by_post_id[post[:id]],
        profile: profile_serializer.by_parent_id[post[:id]]
      })
    end
  end

  private def comment_serializer
    @comment_serializer ||= FastCommentSerializer.new(Comment.where(post_id: @posts.pluck(:id)))
  end

  private def profile_serializer
    @profile_serializer ||= FastProfileSerializer.new(@posts.joins(:profile), 'posts')
  end
end