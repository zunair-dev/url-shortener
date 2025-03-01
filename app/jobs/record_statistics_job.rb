class RecordStatisticsJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3

  # TODO: add sidekiq in future
  def perform(url_id, remote_ip, user_agent, referrer)
    url = Url.find_by(id: url_id)
    return unless url

    url.statistics.create!(
      user_agent: user_agent,
      referrer: referrer,
      ip: remote_ip,
    )
  rescue StandardError => e
    Rails.logger.error "Failed to create statistics for URL #{url_id}: #{e.message}"
    raise e
  end
end
