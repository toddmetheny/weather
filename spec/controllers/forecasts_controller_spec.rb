require 'rails_helper'

RSpec.describe ForecastsController, type: :controller do
  describe 'GET #search' do
    let(:zip) { '33133' }
    let(:cached_forecast) do
      {
        location: "Miami",
        current_temp: 85,
        condition_text: "Sunny",
        condition_icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
        high: 89,
        low: 84
      }
    end

    before do
      allow(WeatherApiService).to receive(:new).with(zip).and_return(service_instance)
      allow(service_instance).to receive(:call).and_return(service_response)
    end

    context 'when forecast is cached' do
      let(:service_instance) { instance_double(WeatherApiService) }
      let(:service_response) { cached_forecast }

      before do
        allow(Rails.cache).to receive(:read).with("forecast_for_#{zip}").and_return(cached_forecast)
      end

      it 'returns forecast data with from_cache set to true' do
        get :search, params: { zip: zip }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body).deep_symbolize_keys
        expect(parsed_response).to include(cached_forecast.merge(from_cache: true))
      end
    end

    context 'when forecast is not cached' do
      let(:service_instance) { instance_double(WeatherApiService) }
      let(:service_response) { cached_forecast }

      before do
        allow(Rails.cache).to receive(:read).with("forecast_for_#{zip}").and_return(nil)
      end

      it 'returns forecast data with from_cache set to false' do
        get :search, params: { zip: zip }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body).deep_symbolize_keys
        expect(parsed_response).to include(cached_forecast.merge(from_cache: false))
      end
    end

    context 'when zip code is invalid' do
      let(:zip) { '00000' }
      let(:service_instance) { instance_double(WeatherApiService) }
      let(:service_response) { { error: 'Invalid zip code' } }

      before do
        allow(Rails.cache).to receive(:read).with("forecast_for_#{zip}").and_return(nil)
      end

      it 'returns an error message' do
        get :search, params: { zip: zip }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body).deep_symbolize_keys
        expect(parsed_response).to eq(service_response.merge(from_cache: false))
      end
    end
  end
end
