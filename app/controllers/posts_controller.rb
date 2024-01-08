class PostsController < ApplicationController
  def index
    @posts = posts.includes(comments: [:profile]).includes(:profile)
    if params[:fast] == "1"
      serialized = FastPostSerializer.new(@posts).call
    else
      serialized = ActiveModel::Serializer::CollectionSerializer.new(@posts, serializer: PostSerializer)
    end
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

  private def posts
    limit = params[:limit] || 100
    offset = params[:offset] || 0
    posts = Post.limit(limit).offset(offset)
  end
end
