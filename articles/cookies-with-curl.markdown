If want to consume an API that uses sessions using [cURL], then probably you will need to make use of cookies. Using cookies with [cURL] is pretty simple.

I'm going to create a simple web application using [Sinatra] for the example's sake:

<pre class="prettyprint">
  <code>
  require 'rubygems'
  require 'sinatra'

  enable :sessions

  get '/' do
    session[:user] # Return whatever stored in session[:user].
  end

  post '/' do
    session[:user] = params[:user] # Set session[:user] to whatever sent on param.
  end
  </code>
</pre>

Now, from console:

<pre class="prettyprint">
  <code>
  ~ $ curl -i -X POST -d 'name=Carlos' http://localhost:4567
  HTTP/1.1 200 OK
  Content-Type: text/html;charset=utf-8
  Content-Length: 10
  X-XSS-Protection: 1; mode=block
  X-Content-Type-Options: nosniff
  X-Frame-Options: SAMEORIGIN
  Set-Cookie: rack.session=BAh7CUkiD3Nlc3Npb25faWQGOgZF...; path=/; HttpOnly
  Connection: keep-alive
  Server: thin 1.5.1 codename Straight Razor
  </code>
</pre>

The ```-i``` flag tells [cURL] to include the HTTP-header in the output.  
The ```-X``` flag specifies the request method (It's **GET** by default but in our case it's **POST**).  
The ```-d``` flag sends the specified data in the request to the server.

Notice the **Set-Cookie** header that the server returned:  
```rack.session=BAh7CUkiD3Nlc3Npb25faWQGOgZF...```

We're now going to perform a **GET** request to the server and also we're going to send that cookie to the server so that the server knows we're keeping track of the session because we care (?)

<pre class="prettyprint">
  <code>
    ~ $ curl http://localhost:4567 -b "rack.session=BAh7CUkiD3Nlc3Npb25faWQGOgZF..."
    Carlos
  </code>
</pre>

If we performed the same request without passing along the cookie the server wouldn't recognise what session we're talking about, so the "name" session key is by default unset:

<pre class="prettyprint">
  <code>
    ~ $ curl http://localhost:4567
    ~ $
  </code>
</pre>

Pretty simple.

[cURL]: http://curl.haxx.se/
