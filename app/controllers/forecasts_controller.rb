class ForecastsController < ApplicationController
  def start
  end

  def search
    from_cache = Rails.cache.read("forecast_for_#{params["zip"]}").present?
    response = WeatherApiService.new(params["zip"]).call
    response.merge!(from_cache: from_cache)

    render json: response
  end
end
