class FastPostMetricSerializer
  def initialize(post_metrics)
    @post_metrics = post_metrics
  end

  def call
    @post_metrics.pluck_to_hash(:post_id, :views)
  end

  def by_post_id
    @by_post_id ||= call.each_with_object({}) do |serialized, acc|
      acc[serialized[:post_id]] ||= []
      acc[serialized[:post_id]].push(serialized)
    end
  end
end