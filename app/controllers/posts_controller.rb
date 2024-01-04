class PostsController < ApplicationController
  def index
    limit = params[:limit] || 10
    offset = params[:offset] || 0
    posts = Post.limit(limit).offset(offset).includes(:profile)
    serialized = ActiveModel::Serializer::CollectionSerializer.new(posts, serializer: PostSerializer)
    render json: { posts: serialized }
  end

  def create
    @post = Post.new(post_params)
    if @post.save
      render json: { post: @post }, status: :ok
    else
      render json: { errors: @post.errors }, status: :bad_request
    end
  end

  def destroy
    @post.destroy
  end

  def show
    render json: { post: @post }
  end

  private def post_params
    params.permit(:title, :body, :profile_id)
  end
end
