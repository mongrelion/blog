require "yaml"
require "erb"

Encoding.default_external = "utf-8"

template = File.read("hugo_template.erb.md")
renderer = ERB.new(template, nil, ">")
readings = YAML.load_file("./db/readings.yml")
readings.each do |reading|
  @reading = reading
  filename = reading[:title].gsub(" ", "-").gsub(/[A-Z]/) { |m| m.downcase }
  puts "writing file #{filename}"
  path     = File.join("hugo", "content", "readings", "#{filename}.md")
  b        = binding
  File.open(path, "w") do |file|
    file.puts renderer.result(b)
  end
end
