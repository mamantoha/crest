# <img src="https://stars.medv.io/mamantoha/crest.svg" align="right"/>
<p align="left"><img src="https://raw.githubusercontent.com/mamantoha/crest/master/logo/logotype_horizontal_dark.png" alt="crest" height="150px"></p>

[![Codacy Badge](https://api.codacy.com/project/badge/Grade/16e439ef2706472988306ef13da91a51)](https://app.codacy.com/app/mamantoha/crest?utm_source=github.com&utm_medium=referral&utm_content=mamantoha/crest&utm_campaign=Badge_Grade_Dashboard)
![Crystal CI](https://github.com/mamantoha/crest/workflows/Crystal%20CI/badge.svg)
[![GitHub release](https://img.shields.io/github/release/mamantoha/crest.svg)](https://github.com/mamantoha/crest/releases)
[![Commits Since Last Release](https://img.shields.io/github/commits-since/mamantoha/crest/latest.svg)](https://github.com/mamantoha/crest/pulse)
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://mamantoha.github.io/crest/)
[![License](https://img.shields.io/github/license/mamantoha/crest.svg)](https://github.com/mamantoha/crest/blob/master/LICENSE)
<!-- ALL-CONTRIBUTORS-BADGE:START - Do not remove or modify this section -->
[![All Contributors](https://img.shields.io/badge/all_contributors-4-orange.svg?style=flat-square)](#contributors-)
<!-- ALL-CONTRIBUTORS-BADGE:END -->

[![Visitors](https://api.visitorbadge.io/api/visitors?path=https%3A%2F%2Fgithub.com%2Fmamantoha%2Fcrest&countColor=%23263759&style=plastic)](https://visitorbadge.io/status?path=https%3A%2F%2Fgithub.com%2Fmamantoha%2Fcrest)

HTTP and REST client for Crystal, inspired by the Ruby's RestClient gem.

Beloved features:

- Redirects support.
- HTTP(S) proxy support.
- Elegant Key/Value headers, cookies, query params, and form data.
- Multipart file uploads.
- JSON request with the appropriate HTTP headers.
- Streaming requests.
- International Domain Names.
- Digest access authentication.
- Logging.

Hopefully, someday I can remove this shard though. Ideally, Crystal's standard library would do all this already.

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
  params: {:lang => "en"},
  user_agent: "Mozilla/5.0"
)
# curl -L http://httpbin.org/get?lang=en -H 'User-Agent: Mozilla/5.0'

Crest.post(
  "http://httpbin.org/post",
  {:age => 27, :name => {:first => "Kurt", :last => "Cobain"}}
)
# curl -L --data "age=27&name[first]=Kurt&name[last]=Cobain" -X POST "http://httpbin.org/post"

Crest.post(
  "http://httpbin.org/post",
  {"file" => File.open("avatar.png"), "name" => "John"}
)
# curl -X POST http://httpbin.org/post -F 'file=@/path/to/avatar.png' -F 'name=John' -H 'Content-Type: multipart/form-data'

response = Crest.post(
  "http://httpbin.org/post",
  {:age => 27, :name => {:first => "Kurt", :last => "Cobain"}},
  json: true
)
# curl -X POST http://httpbin.org/post -d '{"age":27,"name":{"first":"Kurt","last":"Cobain"}}' -H 'Content-Type: application/json'
```

### Request

`Crest::Request` accept next parameters:

Mandatory parameters:

- `:method` - HTTP method (`:get`. `:post`, `:put`, `:patch`, `:delete`, `:options`, `head`)
- `:url` - URL (e.g.: `http://httpbin.org/ip`)

Optional parameters:

- `:form` - a hash containing form data (or a raw string or IO or Bytes)
- `:headers` - a hash containing the request headers
- `:cookies` - a hash containing the request cookies
- `:params` - a hash that represent query params (or a raw string) - a string separated from the preceding part by a question mark (`?`) and a sequence of attribute–value pairs separated by a delimiter (`&`)
- `:params_encoder` params encoder (default to `Crest::FlatParamsEncoder`)
- `:auth` - access authentication method `basic` or `digest` (default to `basic`)
- `:user` and `:password` - for authentication
- `:tls` - client certificates, you can pass in a custom `OpenSSL::SSL::Context::Client` (default to `nil`)
- `:p_addr`, `:p_port`, `:p_user`, and `:p_pass` - specify a per-request proxy by passing these parameters
- `:json` - make a JSON request with the appropriate HTTP headers (default to `false`)
- `:multipart` make a multipart request with the appropriate HTTP headers even if not sending a file (default to `false`)
- `:user_agent` - set "User-Agent" HTTP header (default to `Crest::USER_AGENT`)
- `:max_redirects` - maximum number of redirects (default to 10)
- `:logging` - enable logging (default to `false`)
- `:logger` - set logger (default to `Crest::CommonLogger`)
- `:handle_errors` - error handling (default to `true`)
- `:close_connection` - close the connection after request is completed (default to `true`)
- `:http_client` - instance of `HTTP::Client`
- `:read_timeout` - read timeout (default to `nil`)
- `:write_timeout` - write timeout (default to `nil`)
- `:connect_timeout` - connect timeout (default to `nil`)

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
  headers: {"Content-Type" => "application/json"}
)
# curl -L --header "Content-Type: application/json" "http://httpbin.org/get?width=640&height=480"
```

```crystal
Crest::Request.new(:post, "http://httpbin.org/post", {:foo => "bar"}, json: true)

# curl -X POST http://httpbin.org/post -d '{\"foo\":\"bar\"}' -H 'Content-Type: application/json'"
```

```crystal
Crest::Request.get(
  "http://httpbin.org/get",
  p_addr: "127.0.0.1",
  p_port: 3128,
  p_user: "admin",
  p_pass: "1234"
)
# curl -L --proxy admin:1234@127.0.0.1:3128 "http://httpbin.org/get"
```

A block can be passed to the `Crest::Request` initializer.

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

Additionally, you can set default `params`, `headers`, and `cookies` separately.
So you can use `Crest::Resource` to share common `params`, `headers`, and `cookies`.

The final parameters consist of:

- default parameters from initializer
- parameters provided in call method (`get`, `post`, etc)

This is especially useful if you wish to define your site in one place and
call it in multiple locations.

```crystal
resource = Crest::Resource.new(
  "http://httpbin.org",
  params: {"key" => "value"},
  headers: {"Content-Type" => "application/json"},
  cookies: {"lang" => "uk"}
)

resource["/get"].get(
  headers: {"Auth-Token" => "secret"}
)

resource["/post"].post(
  {:height => 100, "width" => "100"},
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

site.post("/post", {:param1 => "value1", :param2 => "value2"})
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

With Proxy:

```crystal
resource = Crest::Resource.new(
  "http://httpbin.org/get",
  p_addr: "localhost",
  p_port: 3128
)
```

### Result handling

The result of a `Crest::Request` and `Crest::Resource` is a `Crest::Response` object.

Response objects have several useful methods:

- `Response#body`: The response body as a `String`
- `Response#body_io`: The response body as a `IO`
- `Response#status`: The response status as a `HTTP::Status`
- `Response#status_code`: The HTTP response code
- `Response#headers`: A hash of HTTP response headers
- `Response#cookies`: A hash of HTTP cookies set by the server
- `Response#request`: The `Crest::Request` object used to make the request
- `Response#http_client_res`: The `HTTP::Client::Response` object
- `Response#history`: A list of each response received in a redirection chain

### Exceptions

- for status codes between `200` and `207`, a `Crest::Response` will be returned
- for status codes `301`, `302`, `303` or `307`, the redirection will be followed and the request transformed into a `GET`
- for other cases, a `Crest::RequestFailed` holding the `Crest::Response` will be raised
- call `.response` on the exception to get the server's response

```crystal
Crest.get("http://httpbin.org/status/404")
# => HTTP status code 404: Not Found (Crest::NotFound)

begin
  Crest.get("http://httpbin.org/status/404")
rescue ex : Crest::NotFound
  puts ex.response
end
```

To not raise exceptions but return the `Crest::Response` you can set `handle_errors` to `false`.

```crystal
response = Crest.get("http://httpbin.org/status/404", handle_errors: false) do |resp|
  case resp
  when .success?
    puts resp.body_io.gets_to_end
  when .client_error?
    puts "Client error"
  when .server_error?
    puts "Server error"
  end
end
# => Client error

response.status_code # => 404
```

But note that it may be more straightforward to use exceptions to handle different HTTP error response cases:

```crystal
response = begin
  Crest.get("http://httpbin.org/status/404")
rescue ex : Crest::NotFound
  puts "Not found"
  ex.response
rescue ex : Crest::InternalServerError
  puts "Internal server error"
  ex.response
end
# => Not found

response.status_code # => 404
```

### Parameters serializer

`Crest::ParamsEncoder` class is used to encode parameters.

The encoder affect both how `crest` processes query strings and how it serializes POST bodies.

The default encoder is `Crest::FlatParamsEncoder`.

It provides `#encode` method, which converts the given params into a URI query string:

```crystal
Crest::FlatParamsEncoder.encode({"a" => ["one", "two", "three"], "b" => true, "c" => "C", "d" => 1})
# => 'a[]=one&a[]=two&a[]=three&b=true&c=C&d=1'
```

### Custom parameters serializers

You can build a custom params encoder.

The value of Crest `params_encoder` can be any subclass of `Crest::ParamsEncoder` that implement `#encode(Hash) #=> String`

Also Crest include other encoders.

#### `Crest::NestedParamsEncoder`

```crystal
response = Crest.post(
  "http://httpbin.org/post",
  {"size" => "small", "topping" => ["bacon", "onion"]},
  params_encoder: Crest::NestedParamsEncoder
)

# => curl -X POST http://httpbin.org/post -d 'size=small&topping=bacon&topping=onion' -H 'Content-Type: application/x-www-form-urlencoded'
```

#### `Crest::EnumeratedFlatParamsEncoder`

```crystal
response = Crest.post(
  "http://httpbin.org/post",
  {"size" => "small", "topping" => ["bacon", "onion"]},
  params_encoder: Crest::EnumeratedFlatParamsEncoder
)

# => curl -X POST http://httpbin.org/post -d 'size=small&topping[1]=bacon&topping[2]=onion' -H 'Content-Type: application/x-www-form-urlencoded'
```

#### `Crest::ZeroEnumeratedFlatParamsEncoder`

```crystal
response = Crest.post(
  "http://httpbin.org/post",
  {"size" => "small", "topping" => ["bacon", "onion"]},
  params_encoder: Crest::ZeroEnumeratedFlatParamsEncoder
)

# => curl -X POST http://httpbin.org/post -d 'size=small&topping[0]=bacon&topping[1]=onion' -H 'Content-Type: application/x-www-form-urlencoded'
```

### Streaming responses

Normally, when you use `Crest`, `Crest::Request` or `Crest::Resource` methods to retrieve data, the entire response is buffered in memory and returned as the response to the call.

However, if you are retrieving a large amount of data, for example, an iso, or any other large file, you may want to stream the response directly to disk rather than loading it into memory. If you have a very large file, it may become impossible to load it into memory.

If you want to stream the data from the response to a file as it comes, rather than entirely in memory, you can pass a block to which you pass a additional logic, which you can use to stream directly to a file as each chunk is received.

With a block, an `Crest::Response` body is returned and the response's body is available as an `IO` by invoking `Crest::Response#body_io`.

The following is an example:

```crystal
Crest.get("https://github.com/crystal-lang/crystal/archive/1.0.0.zip") do |resp|
  filename = resp.filename || "crystal.zip"

  File.open(filename, "w") do |file|
    IO.copy(resp.body_io, file)
  end
end
```

### Advanced Usage

This section covers some of `crest` more advanced features.

#### Multipart

Yeah, that's right! This does multipart sends for you!

```crystal
file = File.open("#{__DIR__}/example.png")
Crest.post("http://httpbin.org/post", {:image => file})
```

```crystal
file_content = "id,name\n1,test"
file = IO::Memory.new(file_content)
Crest.post("http://httpbin.org/post", {"data.csv" => file})
```

```crystal
file = File.open("#{__DIR__}/example.png")
resource = Crest::Resource.new("https://httpbin.org")
response = resource["/post"].post({:image => file})
```

#### JSON payload

`crest` speaks JSON natively by passing `json: true` argument to `crest`.

```crystal
Crest.post("http://httpbin.org/post", {:foo => "bar"}, json: true)
```

As well you can serialize your _form_ to a string by itself before passing it to `crest`.

```crystal
Crest.post(
  "http://httpbin.org/post",
  {:foo => "bar"}.to_json
  headers: {"Accept" => "application/json", "Content-Type" => "application/json"},
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
  cookies: {"k1" => "v1", "k2" => {"kk2" => "vv2"}}
)
response.cookies
# => {"k1" => "v1", "k2[kk2]" => "vv2"}
```

#### Basic access authentication

For basic access authentication for an HTTP user agent you should to provide a `user` name and `password` when making a request.

```crystal
Crest.get(
  "http://httpbin.org/basic-auth/user/passwd",
  user: "user",
  password: "passwd"
)
# curl -L --user user:passwd http://httpbin.org/basic-auth/user/passwd
```

#### Digest access authentication

For digest access authentication for an HTTP user agent you should to provide a `user` name and `password` when making a request.

```crystal
Crest.get(
  "https://httpbin.org/digest-auth/auth/user/passwd/MD5",
  auth: "digest",
  user: "user",
  password: "passwd"
)
# curl -L --digest --user user:passwd https://httpbin.org/digest-auth/auth/user/passwd/MD5
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

To use authentication with your proxy, use next syntax:

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
    @logger.info { ">> | %s | %s" % [request.method, request.url] }
  end

  def response(response)
    @logger.info { "<< | %s | %s" % [response.status_code, response.url] }
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
client = HTTP::Client.new("httpbin.org")
client.read_timeout = 1.second

begin
  Crest::Request.new(:get,
    "http://httpbin.org/delay/10",
    http_client: client
  )
rescue IO::TimeoutError
  puts "Timeout!"
end
```

```crystal
client = HTTP::Client.new("httpbin.org")
client.read_timeout = 1.second

begin
  resource = Crest::Resource.new("http://httpbin.org", http_client: client)
  resource.get("/delay/10")
rescue IO::TimeoutError
  puts "Timeout!"
end
```

#### Convert Request object to cURL command

Use `to_curl` method on instance of `Crest::Request` to convert request to cURL command.

```crystal
request = Crest::Request.new(
  :post,
  "http://httpbin.org/post",
  {"title" => "New Title", "author" => "admin"}
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

#### Params decoder

`Crest::ParamsDecoder` is a module for decoding query-string into parameters.

```crystal
query = "size=small&topping[1]=bacon&topping[2]=onion"
Crest::ParamsDecoder.decode(query)
# => {"size" => "small", "topping" => ["bacon", "onion"]}
```

## Development

Install dependencies:

```console
shards
```

To run test:

```console
crystal spec
```

### Workbook

```console
crystal play
open http://localhost:8080
```

Then select the Workbook -> Requests from the menu.

## Contributing

1. Fork it (<https://github.com/mamantoha/crest/fork>)
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/mamantoha"><img src="https://avatars.githubusercontent.com/u/61285?v=4?s=100" width="100px;" alt="Anton Maminov"/><br /><sub><b>Anton Maminov</b></sub></a><br /><a href="https://github.com/mamantoha/crest/commits?author=mamantoha" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://www.linkedin.com/in/chao-yang-r/"><img src="https://avatars.githubusercontent.com/u/15083254?v=4?s=100" width="100px;" alt="Chao Yang"/><br /><sub><b>Chao Yang</b></sub></a><br /><a href="https://github.com/mamantoha/crest/commits?author=cyangle" title="Code">💻</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/psikoz"><img src="https://avatars.githubusercontent.com/u/40601249?v=4?s=100" width="100px;" alt="psikoz"/><br /><sub><b>psikoz</b></sub></a><br /><a href="#design-psikoz" title="Design">🎨</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/jphaward"><img src="https://avatars.githubusercontent.com/u/52081790?v=4?s=100" width="100px;" alt="jphaward"/><br /><sub><b>jphaward</b></sub></a><br /><a href="https://github.com/mamantoha/crest/commits?author=jphaward" title="Code">💻</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## License

Copyright: 2017-2025 Anton Maminov (anton.maminov@gmail.com)

This library is distributed under the MIT license. Please see the LICENSE file.
