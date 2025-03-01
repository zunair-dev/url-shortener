class UrlSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :url, :slug, :shortened_link, :visit_count, :created_at

  attribute :shortened_link do
    visit_path(object.slug)
  end

  attribute :visit_count do
    object.visit_count
  end
end
