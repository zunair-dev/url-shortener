class Statistic < ApplicationRecord
  belongs_to :url

  default_scope -> { order(created_at: :desc) }
end
