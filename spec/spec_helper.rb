require "simplecov"
require "simplecov-console"

if ENV["COVERAGE"]
  SimpleCov.start {
    enable_coverage :branch
  }
end

require_relative "../lib/mongoid_mapper"

Mongoid.configure { |config|
  config.clients.default = { uri: ENV.fetch("MONGODB_URL", "mongodb://localhost/test") }
}

Mongo::Logger.logger.level = Logger::ERROR
Mongoid.logger.level = Logger::ERROR

RSpec.configure { |config|
  config.before { Mongoid.purge! }
}
