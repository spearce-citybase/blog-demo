class ApplicationController < ActionController::API
  class NotFound < StandardError; end

  before_action :load_resource, only: [:show, :destroy]

  rescue_from NotFound, with: :not_found

  def not_found
    render status: :not_found
  end

  def load_resource
    resource = controller_name.classify.constantize.find_by(id: params[:id])
    raise NotFound unless resource.present?

    instance_variable_set("@#{controller_name}", resource)
  end
end
