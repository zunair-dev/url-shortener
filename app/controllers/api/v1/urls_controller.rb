class Api::V1::UrlsController < ApiController
  include ResponderConcern

  before_action :validate_url_params, only: :create


  def index
    # TODO:: add pagination in future
    urls = Url.includes(:statistics)

    render json: {
      urls: ActiveModel::Serializer::CollectionSerializer.new(
        urls,
        serializer: UrlSerializer
      )
    }, status: :ok
  end

  def create
    # return existing shortened url if already existing
    url = Url.find_by(url: url_params[:url]) || Url.create(url_params)

    if url.valid?
      render json: { url: UrlSerializer.new(url) }, status: :created
    else
      Rails.logger.error url.errors.messages
      render json: { errors: url.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    url = Url.find(params[:id])

    if url
      render json: { url: UrlSerializer.new(url) }
    else
      render json: { error: "URL not found" }, status: :not_found
    end
  end

  private

  def url_params = params.require(:url).permit(:url)

  def validate_url_params
    if params.dig(:url, :url).blank?
      render json: { error: "URL cannot be blank" }, status: :unprocessable_entity and return
    end
  end
end
