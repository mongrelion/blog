+++
title = "Method stub with MiniTest"
date = "2012-05-24T00:00:00+00:00"
description = "MiniTest's batteries include method stubbing!"
tags = ["ruby", " test", " testing", " minitest"]
+++

[MiniTest] is a testing tool that provides the necessary resources to make your
test suite a complete stack, supporting TDD, BDD, mocking and benchmarking. It
comes by default with Ruby 1.9.x and is also available for Ruby 1.8.7.

It provides two styles of testing: Unit tests and Specs. I personally prefer
Specs since they are easier to read. Find out more about this on the
[documentation] site.
If you're not yet using it, I suggest you to give it a try. I have used it for
writing unit, functional and integration tests and the results are amazing.

But that's enough for the introduction of [MiniTest] since this is more to talk
about how to stub methods using this tool.

So we basically have two options. The first approach is to do something like
[Aaron Patterson] (a.k.a. [@tenderlove]) does on his [PeepCode]'s [screencast].
It's something like this:
```ruby
klass = Class.new User do
  define_method(:confirmed?) { true }
end
user = klass.new
user.confirmed?.must_equal true
```

What he basically is doing here is redifining the `User` class and assigning that
redefinition to the variable `klass`. Within the definition block, he is also
redifininig the `confirmed?` instance method for that class, so that when it is
called, it returns whatever it is inside the block given to the `define_method`
method, which in this case is a `true` value.

The second way to do this, which is cleaner, niftier, fancier and less complex
is by using the MiniTest's stub method:
```ruby
User.stub :confirmed?, true do
  user = User.first
  user.confirmed?.must_equal true
end
```

Clear, precise and concise. This magic was not available until version 3.0.0
when they added support to this on this [commit]. Once again MiniTest impresses
me by its incredible super cow powers.

[MiniTest]: http://github.com/seattlerb/minitest
[documentation]: http://docs.seattlerb.org/minitest/
[Aaron Patterson]: http://tenderlovemaking.com/
[@tenderlove]: http://twitter.com/tenderlove
[PeepCode]: http://peepcode.com
[screencast]: https://peepcode.com/products/play-by-play-tenderlove-ruby-on-rails
[commit]: https://github.com/seattlerb/minitest/commit/37e1a04573f1047a1772a21cbfe48823d2c27d7e
