class StatisticSerializer < ActiveModel::Serializer
  attributes :ip, :user_agent, :referrer, :created_at
end
