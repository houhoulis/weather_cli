import Config

config :weather,
  gov_url: "https://w1.weather.gov/xml/current_obs",
  short_report_fields: ~w(observation_time_rfc822 station_id location weather temp_f relative_humidity wind_dir wind_mph),
  longer_report_fields: ~w(observation_time_rfc822 station_id location latitude longitude weather temperature_string relative_humidity wind_string windchill_string visibility_mi)

# Logger level below which logging code won't even be compiled.
config :logger, compile_time_purge_matching: [[level_lower_than: :info]]
