class LinksController < ApplicationController
  include ResponderConcern

  before_action :find_url, only: :visit

  def visit
    record_statistics

    # do the redirection
    redirect_to @url.url, allow_other_host: true
  end

  private

  def find_url
    redis = Redis.new
    # try to get the URL from Redis cache first
    redis_key = "url:#{params[:slug]}"
    cached_url = redis.get(redis_key)

    if cached_url
      # if found in cache, deserialize and return
      @url = JSON.parse(cached_url, symbolize_names: true)
      @url = Url.new(@url) unless @url.is_a?(Url)
    else
      # if not in cache, get from database
      @url = Url.find_by!(slug: params[:slug])

      redis.set(redis_key, @url.to_json, ex: 1.hour)
    end
  end

  def record_statistics
    RecordStatisticsJob.perform_later(
      @url.id,
      request.remote_ip,
      request.user_agent,
      request.referrer
    )
  end
end
