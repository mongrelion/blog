+++
title = "<%= @article.title %>"
date = "<%= @article.date.rfc3339 %>"
description = "<%= @article.intro.gsub("\n", '') %>"
tags = <%= @article.tags.split(",") %>

+++

<%= File.read(File.join("hugo", "content", "articles", "#{@article.file}.md")) %>
