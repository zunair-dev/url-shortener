module ResponderConcern
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  end

  private

  def success_response(data, status: :ok)
    render json: data, status: status
  end

  def error_response(errors, status: :unprocessable_entity)
    render json: { errors: errors }, status: status
  end

  def not_found_response
    error_response("Record not found", status: :not_found)
  end
end
