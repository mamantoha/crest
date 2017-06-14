# crest

[![Build Status][travis_badge]][travis]

Simple HTTP and REST client for Crystal, inspired by the Ruby's RestClient gem.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  crest:
    github: mamantoha/crest
```

## Usage

```crystal
require "crest"
```

Basic usage:

```crystal
Crest.get("http://example.com/resource")
Crest.post("http://example.com/resource", payload: {:params1 => "one", :nested => {:params2 => "two"}})
```

### Passing advanced options

```crystal
Crest::Request.new(:get, "http://example.com/resource", {"Content-Type" => "application/json"})
Crest::Request.new(:post, "http://example.com/resource", {"Content-Type" => "application/json"}, {:foo => "bar"})
```

### Multipart

Yeah, that's right! This does multipart sends for you!

```crystal
file = File.open("#{__DIR__}/example.png")
Crest.post("http://example.com/upload", payload: {:image => file})
```


### Resource

```crystal
resource = Crest::Resource.new("http://localhost", {"Content-Type" => "application/json"})
resource.get({"X-Something" => "1"})
```

### Resource Nesting

```crystal
site = Crest::Resource.new('http://example.com')
response = site["/api/article"].post({:title => "Hello world", :body => "Crystal is awesome!"})
```

## Development

Install dependencies:

```
shards
```

To run test:

```
make test
```

## Contributing

1. Fork it ( https://github.com/mamantoha/crest/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer

## License

Copyright: 2017 Anton Maminov (anton.maminov@gmail.com)

This library is distributed under the MIT license. Please see the LICENSE file.

[travis_badge]: http://img.shields.io/travis/mamantoha/crest.svg?style=flat
[travis]: https://travis-ci.org/mamantoha/crest
