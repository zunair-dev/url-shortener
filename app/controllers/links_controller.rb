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
    @url = Url.find_by!(slug: params[:slug])
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
