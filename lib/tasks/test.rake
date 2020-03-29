# frozen_string_literal: true

namespace :test do
  desc 'Run tests'
  task run: :environment do
    abort 'InfluxDB is not running' unless influx_running?

    command = TTY::Command.new(printer: :quiet, color: true)
    command.run('rake ts:rebuild RAILS_ENV=test')
    start = Time.now
    # command.run('rspec')
    command.run('rake parallel:spec[4]')
    finish = Time.now

    TestDurationMetric.write(run_time_seconds: (finish - start).to_i)
  end

  def influx_running?
    influx_endpoint = 'http://localhost:8086'

    command = TTY::Command.new(printer: :null)
    command.run!("curl #{influx_endpoint}/ping").success?
  end
end
