+++
title = "Generating JSON in Go"
date = "2013-09-13T00:00:00+00:00"
description = "Learn how to properly generate decent JSON in Go."
tags = ["go", "gonuts", "golang"]
+++

Say you have a custom type defined like this:

<pre class="prettyprint">
  <code>
  type User struct {
    id      int
    email   string
    age     int
    married bool
  }
  </code>
</pre>

Using the [encoding/json] package from the standard library to serialise an instance of a **User** would look something like this:

<pre class="prettyprint">
  <code>
  package main

  import (
    "encoding/json"
    "fmt"
  )

  func main() {
    u          := User{1, "john@doe.com", 33, true}
    uJSON, err := json.Marshal(u)
    if err != nil {
      fmt.Printf("Something went wrong: %s\n", err)
    } else {
      fmt.Printf("json: %s\n", uJSON)
    }
  }
  </code>
</pre>

If we run that in console we will get this output:

<pre class="prettyprint">
  <code>
  $ go run example.go
  json: {}
  </code>
</pre>

Why are we getting an empty JSON? The answer is simple: Go can't access the fields *id, email, age and married* because they are not accessible from outside of the current scope (a.k.a. they are private). To make them public, the fields must start with an uppercase letter. Let's see:

<pre class="prettyprint">
  <code>
  package main

  import (
    "encoding/json"
    "fmt"
  )

  type User struct {
    Id      int
    Email   string
    Age     int
    Married bool
  }

  func main() {
    u := User{1,"jenny@doe.com",27,true}
    uJSON, err := json.Marshal(u)
    if err != nil {
      fmt.Printf("Something went wrong: %s\n", err)
    } else {
      fmt.Printf("json: %s\n", uJSON)
    }
  }
  </code>
</pre>

If we run that again in console we would get now an output like this:

<pre class="prettyprint">
  <code>
  go run example.go
  json: {"Id":1,"Email":"jenny@doe.com","Age":27,"Married":true}
  </code>
</pre>

That looks more like it. But there is this thing that doesn't make me feel very comfortable: the key names in my JSON object start also with an uppercase letter :/  
Don't get me wrong: CamelCase is ok but not in my JSONs. Fortunately, Go offers a workaround for this:

<pre class="prettyprint">
  <code>
  package main

  import (
    "encoding/json"
    "fmt"
  )

  type User struct {
    Id      int    `json:"id"`
    Email   string `json:"email"`
    Age     int    `json:"age"`
    Married bool   `json:"married"`
  }

  func main() {
    u := User{1,"jenny@doe.com",27,true}
    uJSON, err := json.Marshal(u)
    if err != nil {
      fmt.Printf("Something went wrong: %s\n", err)
    } else {
      fmt.Printf("json: %s\n", uJSON)
    }
  }
  </code>
</pre>

Let's run that again in console to see what's up:

<pre class="prettyprint">
  <code>
  go run example.go
  json: {"id":1,"email":"jenny@doe.com","age":27,"married":true}
  </code>
</pre>

Daaaaaayyyummm, that's what I'm talking about (read that with robot accent).
You see? It's not as bad as we thought it would be. There are a couple more options that we can set for our fields when serialising them into JSON that they mention on the official documentation. You can check them out [here].

[encoding/json]: http://golang.org/pkg/encoding/json
[here]: http://golang.org/pkg/encoding/json/#Marshal
