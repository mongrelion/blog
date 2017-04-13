+++
Categories = []
Description = '<%= @article.intro.gsub("\n", '') %>'
Tags = <%= @article.tags.split(",") %>
date = "<%= @article.date.rfc3339 %>"
title = "<%= @article.title %>"
+++

<%= File.read(File.join("articles", "#{@article.file}.markdown")) %>
