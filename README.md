<p align="left"><img src="https://raw.githubusercontent.com/mamantoha/crest/master/logo/logotype_horizontal.png" alt="crest" height="150px"></p>

[![Build Status](http://img.shields.io/travis/mamantoha/crest.svg?style=flat)](https://travis-ci.org/mamantoha/crest)
[![GitHub release](https://img.shields.io/github/release/mamantoha/crest.svg)](https://github.com/mamantoha/crest/releases)
[![Commits Since Last Release](https://img.shields.io/github/commits-since/mamantoha/crest/latest.svg)](https://github.com/mamantoha/crest/pulse)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://mamantoha.github.io/crest/)
[![License](https://img.shields.io/github/license/mamantoha/crest.svg)](https://github.com/mamantoha/crest/blob/master/LICENSE)

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
Crest.get(
  "http://httpbin.org/get",
  params: {:lang => "en"}
)
# curl -L "http://httpbin.org/get?lang=en"

Crest.post(
  "http://httpbin.org/post",
  form: {:age => 27, :name => {:first => "Kurt", :last => "Cobain"}}
)
# curl -L --data "age=27&name[first]=Kurt&name[last]=Cobain" -X POST "http://httpbin.org/post"
```

### Request

`Crest::Request` accept next parameters:

Mandatory parameters:

* `:method` - HTTP method (`:get`. `:post`, `:put`, `:patch`,  `:delete`, `:options`)
* `:url` - URL (e.g.: `http://httpbin.org/ip`)

Optional parameters:

* `:headers` -  a hash containing the request headers
* `:cookies` -  a hash containing the request cookies
* `:form` -  a hash containing form params
* `:params` -  a hash that represent query-string separated from the preceding part by a question mark (`?`) a sequence of attribute–value pairs separated by a delimiter (`&`)
* `:user` and `:password` -  for Basic Authentication
* `:p_addr`, `:p_port`, `:p_user`, and `:p_pass` - specify a per-request proxy by passing these parameters
* `:max_redirects` -  maximum number of redirections (default to 10)
* `:logging` -  enable logging (default to `false`)
* `:logger` -  set logger (default to `Crest::CommonLogger`)
* `:handle_errors` - error handling (default to `true`)
* `:http_client` - instance of `HTTP::Client`

More detailed examples:

```crystal
request = Crest::Request.new(:post,
  "http://httpbin.org/post",
  headers: {"Content-Type" => "application/json"},
  form: {:width => 640, "height" => "480"}
)
request.execute
# curl -L --data "width=640&height=480" --header "Content-Type: application/json" -X POST "http://httpbin.org/post"
```

```crystal
Crest::Request.execute(:get,
  "http://httpbin.org/get",
  params: {:width => 640, "height" => "480"},
  headers: {"Content-Type" => "application/json"})
)
# curl -L --header "Content-Type: application/json" "http://httpbin.org/get?width=640&height=480"
```

```crystal
Crest::Request.get(
  "http://httpbin.org/get",
  p_addr: "127.0.0.1",
  p_port: 3128,
  p_user: "admin",
  p_pass: "1234"
)
# curl -L --proxy http://127.0.0.1:3128 --proxy-user admin:1234 "http://httpbin.org/get"
```

A block can be passed to the `Crest::Request` instance.

This block will then be called with the `Crest::Request`.

```crystal
request = Crest::Request.new(:get, "http://httpbin.org/headers") do |request|
  request.headers.add("foo", "bar")
end

request.execute
# curl -L --header "foo: bar" http://httpbin.org/headers
```

### Resource

A `Crest::Resource` class can be instantiated for access to a RESTful resource,
including authentication, proxy and logging.

Additionally, you can set default `params` and `headers` separately.
So can use `Crest::Resource` to share common `headers` and `params`.

The final `headers` and `params` consist of:

* default headers from initializer
* headers provided in call method (`get`, `post`, etc)

This is especially useful if you wish to define your site in one place and
call it in multiple locations.

```crystal
resource = Crest::Resource.new(
  "http://httpbin.org",
  params: {"key" => "value"},
  headers: {"Content-Type" => "application/json"}
)

response["/get"].get(
  headers: {"Auth-Token" => "secret"}
)

response["/post"].post(
  form: {:height => 100, "width" => "100"},
  params: {:secret => "secret"}
)
```

Use the `[]` syntax to allocate subresources:

```crystal
site = Crest::Resource.new("http://httpbin.org")

site["/post"].post({:param1 => "value1", :param2 => "value2"})
# curl -L --data "param1=value1&param2=value2" -X POST http://httpbin.org/post
```

You can pass `suburl` through `Request#http_verb` methods:

```crystal
site = Crest::Resource.new("http://httpbin.org")

site.post("/post", form: {:param1 => "value1", :param2 => "value2"})
# curl -L --data "param1=value1&param2=value2" -X POST http://httpbin.org/post

site.get("/get", params: {:status => "active"})
# curl -L http://httpbin.org/get?status=active
```

A block can be passed to the `Crest::Resource` instance.

This block will then be called with the `Crest::Resource`.

```crystal
resource = Crest::Resource.new("http://httpbin.org") do |resource|
  resource.headers.merge!({"foo" => "bar"})
end

resource["/headers"].get
```

With HTTP basic authentication:

```crystal
resource = Crest::Resource.new(
  "http://httpbin.org/basic-auth/user/passwd",
  user: "user",
  password: "passwd"
)
```

With Proxy authentication:

```crystal
resource = Crest::Resource.new(
  "http://httpbin.org/get",
  p_host: "localhost",
  p_port: 3128
)
```

### Result handling

The result of a `Crest::Request` and `Crest::Resource` is a `Crest::Response` object.

Response objects have several useful methods.

* `Response#body`: The response body as a string
* `Response#status_code`: The HTTP response code
* `Response#headers`: A hash of HTTP response headers
* `Response#cookies`: A hash of HTTP cookies set by the server
* `Response#request`: The `Crest::Request` object used to make the request
* `Response#http_client_res`: The `HTTP::Client::Response` object
* `Response#history`: A list of each response received in a redirection chain

### Exceptions

* for result codes between `200` and `207`, a `Crest::Response` will be returned
* for result codes `301`, `302`, `303` or `307`, the redirection will be followed and the request transformed into a `GET`
* for other cases, a `Crest::RequestFailed` holding the Response will be raised
* call `.response` on the exception to get the server's response

```crystal
Crest.get("http://httpbin.org/status/404")
# => HTTP status code 404: Not Found (Crest::NotFound)

begin
  Crest.get("http://httpbin.org/status/404")
rescue ex : Crest::NotFound
  puts ex.response
end
```

To not raise exceptions but return the `Crest::Response` you can set `:handle_errors => false`.

```crystal
response = Crest.get("http://httpbin.org/status/404", handle_errors: false)
response.status_code # => 404
```

### Advanced Usage

This section covers some of `crest` more advanced features.

#### Multipart

Yeah, that's right! This does multipart sends for you!

```crystal
file = File.open("#{__DIR__}/example.png")
Crest.post("http://httpbin.org/post", form: {:image => file})
```

```crystal
file = File.open("#{__DIR__}/example.png")
resource = Crest::Resource.new("https://httpbin.org")
response = resource["/post"].post(form: {:image => file})
```

#### JSON payload

`crest` does not speak JSON natively, so serialize your *form* to a string before passing it to `crest`.

```crystal
Crest.post(
  "http://httpbin.org/post",
  headers: {"Content-Type" => "application/json"},
  form: {:foo => "bar"}.to_json
)
```

#### Headers

Request headers can be set by passing a hash containing keys and values representing header names and values:

```crystal
response = Crest.get(
  "http://httpbin.org/bearer",
  headers: {"Authorization" => "Bearer cT0febFoD5lxAlNAXHo6g"}
)
response.headers
# => {"Authorization" => ["Bearer cT0febFoD5lxAlNAXHo6g"]}
```

#### Cookies

`Request` and `Response` objects know about HTTP cookies, and will automatically extract and set headers for them as needed:

```crystal
response = Crest.get(
  "http://httpbin.org/cookies/set",
  params: {"k1" => "v1", "k2" => "v2"}
)
response.cookies
# => {"k1" => "v1", "k2" => "v2"}
```

```crystal
response = Crest.get(
  "http://httpbin.org/cookies",
  cookies: {"k1" => "v1"}
)
response.cookies
# => {"k1" => "v1"}
```

#### Basic authentication

For basic access authentication for an HTTP user agent you should to provide a `user` name and `password` when making a request.

```crystal
Crest.get(
  "http://httpbin.org/basic-auth/user/passwd",
  user: "user",
  password: "passwd"
)
# curl -L --user user:passwd http://httpbin.org/basic-auth/user/passwd
```

#### SSL/TLS support

If `tls` is given it will be used:

```crystal
Crest.get("https://expired.badssl.com", tls: OpenSSL::SSL::Context::Client.insecure)
```

#### Proxy

If you need to use a proxy, you can configure individual requests with the proxy host and port arguments to any request method:

```crystal
Crest.get(
  "http://httpbin.org/ip",
  p_addr: "localhost",
  p_port: 3128
)
```

To use HTTP Basic Auth with your proxy, use next syntax:

```crystal
Crest.get(
  "http://httpbin.org/ip",
  p_addr: "localhost",
  p_port: 3128,
  p_user: "user",
  p_pass: "qwerty"
)
```

#### Logging

> `Logger` class is completely taken from [halite](https://github.com/icyleaf/halite) shard.
> Thanks [icyleaf](https://github.com/icyleaf)!

By default, the `Crest` does not enable logging. You can enable it per request by setting `logging: true`:

```crystal
Crest.get("http://httpbin.org/get", logging: true)
```

##### Filter sensitive information from logs with a regex matcher

```crystal
resource = Crest::Request.get("http://httpbin.org/get", params: {api_key => "secret"}, logging: true) do |request|
  request.logger.filter(/(api_key=)(\w+)/, "\\1[REMOVED]")
end

# => crest | 2018-07-04 14:49:49 | GET | http://httpbin.org/get?api_key=[REMOVED]
```

##### Customize logger

You can create the custom logger by integration `Crest::Logger` abstract class.
Here has two methods must be implement: `Crest::Logger.request` and `Crest::Logger.response`.

```crystal
class MyLogger < Crest::Logger
  def request(request)
    @logger.info ">> | %s | %s" % [request.method, request.url]
  end

  def response(response)
    @logger.info "<< | %s | %s" % [response.status_code, response.url]
  end
end

Crest.get("http://httpbin.org/get", logging: true, logger: MyLogger.new)
```

#### Redirection

By default, `crest` will follow HTTP 30x redirection requests.

To disable automatic redirection, set `:max_redirects => 0`.

```crystal
Crest::Request.execute(method: :get, url: "http://httpbin.org/redirect/1", max_redirects: 0)
# => Crest::Found: 302 Found
```

#### Access HTTP::Client

You can access `HTTP::Client` via the `http_client` instance method.

This is usually used to set additional options (e.g. read timeout, authorization header etc.)

```crystal
client = HTTP::Client.new("http://httpbin.org")
client.read_timeout = 1.second

begin
  Crest::Request.new(:get,
    "http://httpbin.org/delay/10",
    http_client: client
  )
rescue IO::Timeout
  puts "Timeout!"
end
```

```crystal
client = HTTP::Client.new("http://httpbin.org")
client.read_timeout = 1.second

begin
  resource = Crest::Resource.new("http://httpbin.org", http_client: client)
  resource.get("/delay/10")
rescue IO::Timeout
  puts "Timeout!"
end
```

#### Convert Request object to cURL command

Use `to_curl` method on instance of `Crest::Request` to convert request to cURL command.

```crystal
request = Crest::Request.new(
  :post,
  "http://httpbin.org/post",
  form: {"title" => "New Title", "author" => "admin"}
)
request.to_curl
# => curl -X POST http://httpbin.org/post -d 'title=New+Title&author=admin' -H 'Content-Type: application/x-www-form-urlencoded'
```

```crystal
request = Crest::Request.new(
  :get,
  "http://httpbin.org/basic-auth/user/passwd",
  user: "user",
  password: "passwd"
)
request.to_curl
# => curl -X GET http://httpbin.org/basic-auth/user/passwd --user user:passwd
```

Also you can directly use `Crest::Curlify` which accept instance of `Crest::Request`

```crystal
request = Crest::Request.new(:get, "http://httpbin.org")
Crest::Curlify.new(request).to_curl
# => curl -X GET http://httpbin.org
```

## Development

Install dependencies:

```console
shards
```

To run test:

```console
make test
```

### Workbook

```console
crystal play
open http://localhost:8080
```

Then select the Workbook -> Requests from the menu.

## Contributing

1. Fork it ( https://github.com/mamantoha/crest/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

* [mamantoha](https://github.com/mamantoha) Anton Maminov - creator, maintainer
* [icyleaf](https://github.com/icyleaf) Icyleaf Wang - logging support
* [psikoz](https://github.com/psikoz) Logo design

## License

Copyright: 2017-2018 Anton Maminov (anton.maminov@gmail.com)

This library is distributed under the MIT license. Please see the LICENSE file.
