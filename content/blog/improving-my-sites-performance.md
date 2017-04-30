+++
title = "Improving (?) my site's performance: Part I"
date = "2013-03-24T00:00:00+00:00"
description = "Journey into tweaking my website written in Ruby"
tags = ["ruby"]
+++

When I decided to finally come up with a blog, I gave [Jekyll] and [Octopress]
a try. Nice plugins, "easy" deployment strategies and what not, but somehow
I could not cope with them. That's why I decided to write my own. At last I
am a software developer and building a semi-static website shouldn't be that
complicated.  
The solution I came up with is inspired by [@cyx]'s personal website, although
now I seriously am thinking about refactoring a couple stuff here and there.

First thing first: I am not a talented designer. Even though I felt quite satisfied
with the last design I came up with, I still felt like something was wrong.
[Twitter Bootstrap] to the rescue. It's been on the market for a while. I have used
it before in a couple projects. I am used to it. The design is quite fancy. It's
responsive, blah blah blah. There are a couple shadow effects that I added to the
site to make it a little bit fancier and a little bit more "original".

I also gave a try to [Mina] to deploy my website to my VPS. As with [Capistrano],
you can run remote commands on the server side plus the ruby on your scripts
doing any kind of magic you can spell. It even has [built-in support] for [Bundler],
[Foreman], [Git], [Rails], [Rake], [rbenv], [rvm] and [Whenever].  
Because [Capistrano] has been on the market for more time, there is a lot more
documentation to read, although the [Mina] documentation is very fancy, which
makes it easier to start than with [Capistrano], which in my opinion is a little
bit scary to start with [#hatersgonnahate]. Also, [Capistrano](https://github.com/capistrano/capistrano/commits/master)
development seems to be a little more active than [Mina](https://github.com/nadarei/mina/commits/master).

Another change I made to my site was to switch from [Thin] to [Puma]. I skipped
the benchmarks so I apologize for that. The good thing is that this change is
already in production. Yes, this site is being served with [Nginx] + [Puma]
with [ruby 2.0.0-p0]

I'm also thinking about serving my site with SSL but I'm not sure if it is completely
necessary but should be fun and entertaining. If you have any suggestions for
a good **free** SSL certificate provider, leave me a comment below.

Last but not least, the biggest change I have in mind is to pre-load all the articles
in memory.  
When I started building my website, somebody in IRC made me realize that what we
write in these blogs is plain text (that's obvious - duh!) but going beyond the
obvious, this is not something that I don't do on a daily basis, and it's not
something that I think is going to reach the first TB in the next couple decades.  
With that in mind, I now need to decide whether or not to load in memory the
pre-compiled version of the articles (I write these things using markdown and
parse them using [RDiscount]), as the HTML tags and extra spaces can use some more
space in memory or compile "en caliente", but pre-compiling them sounds like a
good approach as I can get better performance out of it because I wouldn't need
to compile/parse the articles for every single request.

Again, if you have any suggestion, I'm all ears (eyes in this case).

I will publish another post with some more updates that I do to this site of mine.

[Jekyll]: http://jekyllrb.com
[Octopress]: http://octopress.org
[@cyx]: https://github.com/cyx/cyrildavid.com
[Twitter Bootstrap]: http://twitter.github.com/bootstrap
[Mina]: http://nadarei.co/mina
[Capistrano]: http://capify.org
[#hatersgonnahate]: https://twitter.com/search?q=%23hatersgonnahate&src=typd
[built-in support]: https://github.com/nadarei/mina/tree/master/lib/mina
[Bundler]: http://gembundler.com
[Foreman]: http://ddollar.github.com/foreman
[Git]: http://git-scm.com
[Rake]: http://rake.rubyforge.org
[Rails]: http://rubyonrails.org
[rbenv]: https://github.com/sstephenson/rbenv
[rvm]: https://rvm.io
[Whenever]: https://github.com/javan/whenever
[Thin]: http://code.macournoyer.com/thin/
[Puma]: http://puma.io
[Nginx]: http://wiki.nginx.org
[ruby 2.0.0-p0]: http://www.ruby-lang.org/en/news/2013/02/24/ruby-2-0-0-p0-is-released/
[RDiscount]: https://github.com/rtomayko/rdiscount
