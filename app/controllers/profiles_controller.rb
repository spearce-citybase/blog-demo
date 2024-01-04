class ProfilesController < ApplicationController
  def index
    render json: { profiles: Profile.all }
  end

  def create
    @profile = Profile.new(profile_params)
    if @profile.save
      render json: { profile: @profile }, status: :ok
    else
      render json: { errors: @profile.errors }, status: :bad_request
    end
  end

  def destroy
    @profile = Profile.find(params[:id])
    @profile.destroy
  end

  def show
    @profile = Profile.find(params[:id])
    render json: { profile: @profile }
  end

  private def profile_params
    params.permit(:name)
  end
end
