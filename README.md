carlosleon.info
===============

[![Build Status](https://travis-ci.org/mongrelion/carlosleon.info.svg?branch=master)](https://travis-ci.org/mongrelion/carlosleon.info)

My personal website's source code, powered by [Hugo].

[Hugo]: https://gohugo.io/

# Development
The development process consists of:
1. Making changes to the website
2. Rendering the website (Hugo spits this out into `public/`)
3. Running a test server that serves the contents of that folder. For this we can
   be pragmatic and `python -m SimpleHTTPServer`. However, we do run Docker in
   production, so the best approach is to build the container image locally
   and run it as if we were in production.

### To generate the website
```
$ make site
```

This will output all the static content onto the `public/` folder.

### Building the container image
```
$ make image
```

### Development shortcut
```
$ make dev
```

will delete any previous version of the `public/` folder, generate the website
and run a test server on port `80`.
