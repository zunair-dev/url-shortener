module ResponderConcern
  extend ActiveSupport::Concern
  included do
    rescue_from ActiveRecord::RecordNotFound, with: :not_found_response
  end

  private

  def not_found_response
    render json: { error: "Record Not found" }, status: :not_found
  end
end
