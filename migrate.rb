require "./deps"
require "erb"

Encoding.default_external = "utf-8"

articles = Article.all
template = File.read("hugo_template.erb.md")
renderer = ERB.new(template)
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
