require "./deps"

Encoding.default_external = "utf-8"

# Preload articles and readings
Article.all
Reading.all

use Rack::Deflater, if: ->(env, status, headers, body) { body.any? && body[0].length > 512 }
use Prometheus::Client::Rack::Collector
use Prometheus::Client::Rack::Exporter

run App
