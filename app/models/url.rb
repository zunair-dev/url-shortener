class Url < ApplicationRecord
  include Rails.application.routes.url_helpers

  MAXLEN = 10
  MINLEN = 8

  has_many :statistics

  validates :url, presence: true, url: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  after_destroy_commit :destroy_statistics

  default_scope -> { order(created_at: :desc) }

  def shortened_link = visit_path(slug)

  def visit_count = statistics.size

  private

  def generate_random_string = rand(36**(rand(MINLEN..MAXLEN))).to_s(36)

  # generate a slug
  def generate_slug(random_string = nil)
    random_string = generate_random_string

    while Url.where(slug: random_string).exists?
      random_string = generate_random_string
    end

    self.slug = random_string
  end

  def destroy_statistics
    DestroyStatisticsJob.perform_later(id)
  end
end
