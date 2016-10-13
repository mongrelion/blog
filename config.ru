require "./deps"

Encoding.default_external = "utf-8"

# Preload articles and readings
Article.all
Reading.all

run App
