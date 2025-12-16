class ApplicationController < ActionController::API
  rescue_from ActionController::ParameterMissing, with: :render_parameter_error

  private

  def render_parameter_error(error)
    render json: { errors: [error.message] }, status: :unprocessable_entity
  end
end
