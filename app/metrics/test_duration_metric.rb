# frozen_string_literal: true

class TestDurationMetric < Influxer::Metrics
  set_series :test

  attributes :run_time_seconds

  validates :run_time_seconds, presence: true
  validates :run_time_seconds, numericality: true
end
