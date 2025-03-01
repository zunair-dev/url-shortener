class UrlSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :url, :short_url, :visit_count, :created_at

  attribute :short_url do
    visit_path(object.slug)
  end

  attribute :visit_count do
    object.visit_count
  end
end
