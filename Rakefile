# frozen_string_literal: true

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = %w[
    --force-color
    --format progress
    --require ./spec/spec_helper.rb
  ]
  t.pattern = 'spec/**/*_spec.rb'
end

task default: [:spec]
