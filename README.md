# crest

[![Build Status][travis_badge]][travis]
[![Dependency Status](https://shards.rocks/badge/github/mamantoha/crest/status.svg)](https://shards.rocks/github/mamantoha/crest)
[![devDependency Status](https://shards.rocks/badge/github/mamantoha/crest/dev_status.svg)](https://shards.rocks/github/mamantoha/crest)
[![License](https://img.shields.io/github/license/mamantoha/crest.svg)](https://github.com/mamantoha/crest/blob/master/LICENSE)

Simple HTTP and REST client for Crystal, inspired by the Ruby's RestClient gem.
Support HTTP methods: get, post, put, patch, post, delete.

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
Crest.get("http://example.com/resource", params: {:lang => "ua"})
Crest.delete("http://example.com/resource/1")
Crest.post("http://example.com/resource", payload: {:params1 => "one", :nested => {:params2 => "two"}})
Crest.put("http://example.com/resource/1", payload: {:params1 => "one", :nested => {:params2 => "two"}})
```

In the high level helpers, only `POST`, `PATCH`, and `PUT` take a payload argument.

### Passing advanced options

```crystal
Crest::Request.new(:get, "http://example.com/resource", {"Content-Type" => "application/json"})
Crest::Request.new(:delete, "http://example.com/resource/1", params: {:lang => "ua"})
Crest::Request.new(:post, "http://example.com/resource", {"Content-Type" => "application/json"}, payload: {:foo => "bar"})
Crest::Request.new(:patch, "http://example.com/resource/1", {"Content-Type" => "application/json"}, payload: {:foo => "bar"})
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

### Exceptions

- for result codes between `200` and `207`, a `Crest::Response` will be returned
- for result codes `301`, `302`, `303` or `307`, the redirection will be followed and the request transformed into a `GET`
- for other cases, a `Crest::RequestFailed` holding the Response will be raised
- call `.response` on the exception to get the server's response

### Redirection

By default, `crest` will follow HTTP 30x redirection requests.

To disable automatic redirection, set `:max_redirects => 0`.

```crystal
Crest::Request.execute(method: :get, url: "http://httpbin.org/redirect/1", max_redirects: 0)
# Crest::RequestFailed: 302 Found
```

## Result handling

The result of a `Crest::Request` is a `Crest::Response` object.

Response objects have several useful methods.

- `Response#body`: The response body as a string
- `Response#status_code`: The HTTP response code
- `Response#headers`: A hash of HTTP response headers
- `Response#request`: The `Crest::Request` object used to make the request
- `Response#http_client_res`: The `HTTP::Client::Response` object

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
