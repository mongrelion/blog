require "./deps"
require "erb"

Encoding.default_external = "utf-8"

# Open the file
# Prepend Hugo shit
# Append the original content

articles = Article.all
template = File.read("hugo_template.erb.md")
renderer = ERB.new(template, nil, ">")
articles.each do |_article|
  @article = _article
  b        = binding
  result   = renderer.result(b)

  File.open(File.join("hugo", "content", "articles", "#{@article.file}.md"), "w") do |f|
    f.puts result
  end

  puts "done migrating #{@article.title}"
end

puts "all done"
