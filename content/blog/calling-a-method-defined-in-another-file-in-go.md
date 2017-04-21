+++
title = "Calling a method defined in another file in Go"
date = "2015-09-03T00:00:00+00:00"
description = "Defining a method in Go in one file and calling it from another one can be a little tricky when running small experiments. This is how I fixed it."
tags = ["go", "gonuts", "golang"]
+++

If you have two files in Go that look like this:

**a.go**

```go
package main

func main() {
  println(foo())
}
```

**b.go**

```go
func foo() string {
  return "Hello, foo!"
}
```


If you `go build .` the project, it completes without errors and the binary file is generated:

```bash
$ ls -l
a.go
b.go
foo
```

And it works:

```bash
$ ./foo
Hello, foo!
```

But when you're developing you want to run the project right from Go instead of compiling and then running the binary. The tool for doing this is `run` and your gut will dictate you something like:

```bash
$ go run a.go
```

But the output rather than being what you expected is somewhat more like:

```bash
# command-line-arguments
./a.go:4: undefined: foo
```
:(

`go build` is smart enough to figure out by itself that the function `foo` is defined in one of the `.go` files in our directory/package but `go run` is not as smart.

#### THE FIX

Simply specify all the files involved in your "run" and it will just work:

```bash
$ go run a.go b.go
Hello, foo!
```
