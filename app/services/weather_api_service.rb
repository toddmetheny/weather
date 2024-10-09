class WeatherApiService
  def initialize(zip)
    @zip = zip
    @forecast = Rails.cache.read("forecast_for_#{@zip}")
  end

  def call
    return invalid_zip_response unless ZipCodeValidationService.valid?(@zip)
    return @forecast unless @forecast.blank?

    format_forecast(fetch_forecast)
    write_to_cache

    @forecast
  end

  private

  def fetch_forecast
    base_url = "http://api.weatherapi.com/v1/forecast.json?key=#{ENV["WEATHER_API_KEY"]}&q=#{@zip}&days=1&aqi=no&alerts=no"
    response = HTTParty.get(base_url)

    JSON.parse(response.body)
  end

  def format_forecast(forecast)
    return invalid_zip_response if forecast["error"]

    @forecast = {
      location: forecast["location"]["name"],
      current_temp: forecast["current"]["temp_f"].round,
      condition_text: forecast["current"]["condition"]["text"],
      condition_icon: forecast["current"]["condition"]["icon"],
      high: forecast["forecast"]["forecastday"][0]["day"]["maxtemp_f"].round,
      low: forecast["forecast"]["forecastday"][0]["day"]["mintemp_f"].round
    }
  end

  def invalid_zip_response
    { error: "Invalid zip code" }
  end

  def write_to_cache
    Rails.cache.write("forecast_for_#{@zip}", @forecast, expires_in: 30.minutes)
  end
end
