Calling a method defined in another file in Go with `go run`
---

If you have two files in Go that look like this:

**a.go**

```
package main

func main() {
  println(foo())
}
```

**b.go**

```
func foo() string {
  return "Hello, foo!"
}
```


If you `go build .` the project, it completes without errors and the binary file is generated:

```
$ ls -l
a.go
b.go
foo
```

And it works:

```
./foo
Hello, foo!
```

But when you're developing you want to run the project right from Go instead of compiling and then running the binary. The tool for doing this is `run` and your gut will dictate you something like:

```
go run a.go
```

But the output rather than being what you expected is somewhat more like:

```
# command-line-arguments
./a.go:4: undefined: foo
```
:(

`go build` is smart enough to figure out by itself that the function `foo` is defined in one of the `.go` files in our directory/package but `go run` is not as smart.

THE FIX

Simply specify all the files involved in your "run" and it will just work:

```
go run a.go b.go
Hello, foo!
```
