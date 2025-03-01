class Api::V1::UrlsController < ApiController
  before_action :validate_url_params, only: :create

  def index
    # TODO:: add pagination in future
    urls = Url.includes(:statistics)

    success_response({
      urls: ActiveModel::Serializer::CollectionSerializer.new(
        urls, serializer: UrlSerializer
      )
    })
  end

  def create
    url = Url.find_or_create_by(url: url_params[:url])

    if url.valid?
      success_response({ url: UrlSerializer.new(url) }, status: :created)
    else
      Rails.logger.error url.errors.messages
      error_response(url.errors.messages)
    end
  end

  def show
    url = Url.find(params[:id])
    success_response({ url: UrlSerializer.new(url) })
  end

  private

  def url_params = params.require(:url).permit(:url)

  def validate_url_params
    return if params.dig(:url, :url).present?

    error_response("URL cannot be blank")
  end
end
