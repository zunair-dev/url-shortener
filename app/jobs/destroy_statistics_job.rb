class DestroyStatisticsJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: 5.minutes, attempts: 3

  # TODO: add sidekiq in future
  def perform(url_id)
    statistics = Statistic.where(url_id: url_id)
    statistics.delete_all
  rescue StandardError => e
    Rails.logger.error "Failed to delete statistics for URL #{url_id}: #{e.message}"
    raise e
  end
end
