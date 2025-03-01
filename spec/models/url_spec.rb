require 'rails_helper'

RSpec.describe Url, type: :model do
  describe 'associations' do
    it { should have_many(:statistics) }
  end

  describe 'validations' do
    it { should validate_presence_of(:url) }

    context 'url format validation' do
      let(:valid_url_http) { build(:url, url: Faker::Internet.url(scheme: 'http')) }
      let(:valid_url_https) { build(:url, url: Faker::Internet.url) }
      let(:invalid_url) { build(:url, url: SecureRandom.alphanumeric(8)) }

      it 'allows URLs with http schema' do
        valid_url_http.validate
        expect(valid_url_http.errors[:url]).to be_empty
      end

      it 'allows URLs with https schema' do
        valid_url_https.validate
        expect(valid_url_https.errors[:url]).to be_empty
      end

      it 'rejects invalid URLs' do
        invalid_url.validate
        expect(invalid_url.errors[:url]).not_to be_empty
      end
    end
  end

  describe 'scopes' do
    it 'defaults to order by created_at desc' do
      url1 = create(:url, created_at: 2.days.ago)
      url2 = create(:url, created_at: 1.day.ago)
      expect(Url.all.to_a).to eq([ url2, url1 ])
    end
  end

  describe 'callbacks' do
    context 'before_validation' do
      let(:url) { build(:url, slug: nil) }

      it 'generates a slug before validation' do
        expect(url.slug).to be_nil
        url.valid?
        expect(url.slug).to be_present
      end

      it 'generates slugs with length between MINLEN and MAXLEN' do
        url.valid?
        expect(url.slug.length).to be_between(Url::MINLEN, Url::MAXLEN)
      end
    end

    context 'after_destroy_commit' do
      let(:url) { create(:url) }

      it 'enqueues a job to destroy statistics' do
        expect {
          url.destroy
        }.to have_enqueued_job(DestroyStatisticsJob).with(url.id)
      end
    end
  end

  describe '#shortened_link' do
    let(:url) { create(:url, slug: 'abc123') }

    it 'returns the visit path with slug' do
      # stub the routes helper
      allow(url).to receive(:shortened_link).and_return("http://short.url/#{url.slug}")
      expect(url.shortened_link).to eq("http://short.url/#{url.slug}")
    end
  end

  describe '#visit_count' do
    let(:url) { create(:url) }

    it 'returns the number of statistics entries' do
      create_list(:statistic, 3, url: url)
      expect(url.visit_count).to eq(3)
    end

    it 'returns 0 when no statistics exist' do
      expect(url.visit_count).to eq(0)
    end
  end

  describe '#generate_random_string' do
    let(:url) { build(:url) }

    it 'returns a string with length between MINLEN and MAXLEN' do
      random_string = url.send(:generate_random_string)
      expect(random_string.length).to be_between(Url::MINLEN, Url::MAXLEN)
    end

    it 'returns a base36 encoded string' do
      random_string = url.send(:generate_random_string)
      expect(random_string).to match(/^[0-9a-z]+$/)
    end
  end

  describe '#generate_slug' do
    it 'generates a unique slug before validation' do
      url = build(:url, slug: nil)
      expect(url).to receive(:generate_slug).and_call_original
      url.valid?
      expect(url.slug).to be_present
    end

    it 'ensures uniqueness of slug' do
      new_url = build(:url, slug: 'unique123')
      new_url.valid?
      expect(new_url.slug).not_to eq('unique123')
    end
  end
end
