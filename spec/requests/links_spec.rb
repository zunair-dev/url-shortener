require 'rails_helper'

RSpec.describe "Links", type: :request do
  describe 'GET /:slug' do
    let(:url) { create(:url, url: Faker::Internet.url) }
    let(:request) { create(:statistic) }

    let(:mock_redis) { instance_double(Redis) }

    before do
      allow(Redis).to receive(:new).and_return(mock_redis)
    end

    context 'when URL is found in the database' do
      before do
        allow(mock_redis).to receive(:get).with("url:#{url.slug}").and_return(nil)
        allow(mock_redis).to receive(:set)

        allow(RecordStatisticsJob).to receive(:perform_later)
      end

      it 'redirects to the original URL' do
        get "/#{url.slug}"
        expect(response).to redirect_to(url.url)
      end

      it 'stores the URL in Redis cache' do
        expect(mock_redis).to receive(:set).with(
          "url:#{url.slug}",
          anything,
          hash_including(ex: 1.hour)
        )

        get "/#{url.slug}"
      end
    end

    context 'when URL is found in Redis cache' do
      before do
        serialized_url = url.to_json

        allow(mock_redis).to receive(:get).with("url:#{url.slug}").and_return(serialized_url)

        allow(RecordStatisticsJob).to receive(:perform_later)
      end

      it 'redirects to the original URL' do
        get "/#{url.slug}"
        expect(response).to redirect_to(url.url)
      end

      it 'does not query the database' do
        expect(Url).not_to receive(:find_by!)
        get "/#{url.slug}"
      end

      it 'still records statistics' do
        expect(RecordStatisticsJob).to receive(:perform_later)
        get "/#{url.slug}"
      end
    end

    context 'when URL is not found' do
      before do
        allow(mock_redis).to receive(:get).with("url:nonexistent").and_return(nil)

        allow(Url).to receive(:find_by!).with(slug: 'nonexistent').and_raise(ActiveRecord::RecordNotFound)
      end

      it 'returns 404 for non-existent slug' do
        get "/nonexistent"

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'Redis connection issues' do
      before do
        allow(mock_redis).to receive(:get).and_raise(Redis::CannotConnectError)

        allow(Url).to receive(:find_by!).with(slug: url.slug).and_return(url)

        allow(RecordStatisticsJob).to receive(:perform_later)
      end

      it 'falls back to database lookup when Redis fails' do
        allow_any_instance_of(LinksController).to receive(:find_url) do |controller|
          controller.instance_variable_set(:@url, url)
        end

        get "/#{url.slug}"
        expect(response).to redirect_to(url.url)
      end
    end
  end
end
