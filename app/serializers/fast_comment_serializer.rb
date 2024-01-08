class FastCommentSerializer
  def initialize(comments)
    @comments = comments
  end

  def call
    @comments.pluck_to_hash(:post_id, :id, :body).map do |comment|
      comment.merge({ 
        profile: profile_serializer.by_parent_id[comment[:id]]
      })
    end
  end

  def by_post_id
    @by_post_id ||= call.each_with_object({}) do |serialized_comment, acc|
      acc[serialized_comment[:post_id]] ||= []
      acc[serialized_comment[:post_id]].push(serialized_comment)
    end
  end

  private def profile_serializer
    @profile_serializer ||= FastProfileSerializer.new(@comments.joins(:profile), 'comments')
  end
end