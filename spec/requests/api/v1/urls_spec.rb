require 'rails_helper'

RSpec.describe "Api::V1::Urls", type: :request do
  describe 'GET /api/v1/urls' do
    let!(:urls) { create_list(:url, 3) }

    before { get '/api/v1/urls' }

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns all URLs in the expected format' do
      json_response = JSON.parse(response.body)
      expect(json_response['urls'].size).to eq(urls.count)
      expect(json_response['urls']).to all(include('url', 'slug', 'shortened_link'))
    end

    it 'includes the correct data for each URL' do
      json_response = JSON.parse(response.body)
      first_url = Url.order(created_at: :desc).first
      first_response_url = json_response['urls'].first

      expect(first_response_url['url']).to eq(first_url.url)
      expect(first_response_url['slug']).to eq(first_url.slug)
    end
  end

  describe 'GET /api/v1/urls/:id' do
    let(:url) { create(:url) }

    context 'when the URL exists' do
      before { get "/api/v1/urls/#{url.id}" }

      it 'returns the correct URL' do
        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['url']['id']).to eq(url.id)
        expect(json_response['url']['url']).to eq(url.url)
        expect(json_response['url']['slug']).to eq(url.slug)
      end
    end

    context 'when the URL does not exist' do
      before { get '/api/v1/urls/999' }

      it 'returns 404' do
        expect(response).to have_http_status(:not_found)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Record Not found')
      end
    end
  end

  describe 'POST /api/v1/urls' do
    context 'with valid parameters' do
      let(:valid_url) { Faker::Internet.url }
      let(:valid_params) { { url: { url: valid_url } } }

      it 'creates a new URL and returns a successful response' do
        expect {
          post '/api/v1/urls', params: valid_params
        }.to change(Url, :count).by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['url']['url']).to eq(valid_url)
        expect(json_response['url']['slug']).to be_present
      end

      it 'returns existing URL if already in database' do
        # create URL first
        existing_url = create(:url, url: valid_url)

        expect {
          post '/api/v1/urls', params: valid_params
        }.not_to change(Url, :count)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['url']['id']).to eq(existing_url.id)
        expect(json_response['url']['url']).to eq(valid_url)
      end
    end

    context 'with invalid parameters' do
      let(:invalid_params) { { url: { url: 'invalid-url' } } }

      it 'does not create a new URL and returns an error message' do
        expect {
          post '/api/v1/urls', params: invalid_params
        }.not_to change(Url, :count)

        expect(response).to have_http_status(:unprocessable_entity)

        json_response = JSON.parse(response.body)
        expect(json_response['errors']).to be_present
      end
    end

    context 'with empty URL' do
      it 'returns an error when URL is blank' do
        post '/api/v1/urls', params: { url: { url: '' } }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('URL cannot be blank')
      end

      it 'returns an error when URL parameter is missing' do
        post '/api/v1/urls', params: { url: {} }

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('URL cannot be blank')
      end
    end

    context 'slug generation' do
      let(:valid_url) { Faker::Internet.url }
      let(:valid_params) { { url: { url: valid_url } } }

      it 'generates a slug between MINLEN and MAXLEN characters' do
        post '/api/v1/urls', params: valid_params

        json_response = JSON.parse(response.body)
        slug = json_response['url']['slug']

        expect(slug.length).to be_between(Url::MINLEN, Url::MAXLEN)
      end

      it 'generates a unique slug for each URL' do
        first_url = Faker::Internet.url
        second_url = Faker::Internet.url

        post '/api/v1/urls', params: { url: { url: first_url } }
        first_response = JSON.parse(response.body)

        post '/api/v1/urls', params: { url: { url: second_url } }
        second_response = JSON.parse(response.body)

        expect(first_response['url']['slug']).not_to eq(second_response['url']['slug'])
      end
    end
  end
end
