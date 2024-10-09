require 'rails_helper'

RSpec.describe WeatherApiService, type: :service do
  let(:valid_zip) { '33133' }
  let(:invalid_zip) { '00000' }
  let(:service) { described_class.new(zip) }

  describe '#call' do
    context 'when the zip code is valid' do
      let(:zip) { valid_zip }

      before do
        allow(ZipCodeValidationService).to receive(:valid?).with(zip).and_return(true)
        allow(Rails.cache).to receive(:read).with("forecast_for_#{zip}").and_return(nil)
      end

      it 'should return formatted forecast data' do
        response_body = {
          "location" => { "name" => "Miami" },
          "current" => { "temp_f" => 85, "condition" => { "text" => "Sunny", "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png" } },
          "forecast" => { "forecastday" => [ { "day" => { "maxtemp_f" => 89.0, "mintemp_f" => 84.0 } } ] }
        }.to_json

        stub_request(:get, /api.weatherapi.com/).to_return(status: 200, body: response_body)

        result = service.call

        expect(result).to eq({
          location: "Miami",
          current_temp: 85,
          condition_text: "Sunny",
          condition_icon: "//cdn.weatherapi.com/weather/64x64/day/113.png",
          high: 89,
          low: 84
        })
      end

      it 'caches the forecast data' do
        response_body = {
          "location" => { "name" => "Miami" },
          "current" => { "temp_f" => 85, "condition" => { "text" => "Sunny", "icon" => "//cdn.weatherapi.com/weather/64x64/day/113.png" } },
          "forecast" => { "forecastday" => [ { "day" => { "maxtemp_f" => 89.0, "mintemp_f" => 84.0 } } ] }
        }.to_json

        stub_request(:get, /api.weatherapi.com/).to_return(status: 200, body: response_body)

        expect(Rails.cache).to receive(:write).with("forecast_for_#{zip}", anything, expires_in: 30.minutes)

        service.call
      end
    end

    context 'when the zip code is invalid' do
      let(:zip) { invalid_zip }

      before do
        allow(ZipCodeValidationService).to receive(:valid?).with(zip).and_return(false)
      end

      it 'should return an error message' do
        result = service.call

        expect(result).to eq({ error: 'Invalid zip code' })
      end
    end

    context 'when forecast data is already cached' do
      let(:zip) { valid_zip }
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
        allow(ZipCodeValidationService).to receive(:valid?).with(zip).and_return(true)
        allow(Rails.cache).to receive(:read).with("forecast_for_#{zip}").and_return(cached_forecast)
      end

      it 'should return the cached forecast data' do
        result = service.call

        expect(result).to eq(cached_forecast)
      end
    end
  end
end
