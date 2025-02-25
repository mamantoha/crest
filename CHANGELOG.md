# Changelog

## [...]

## [1.5.1][] (2025-02-25)

- Support Crystal 1.16.0-dev [#233](https://github.com/mamantoha/crest/pull/233)

## [1.5.0][] (2025-01-27)

- **(breaking-change)** Refactor timeout ivars to `Time::Span` [#232](https://github.com/mamantoha/crest/pull/232)

## [1.4.1][] (2024-08-29)

- Fix Crest::Resource#concat_urls [#229](https://github.com/mamantoha/crest/pull/229)

## [1.4.0][] (2024-08-26)

- Fix typo in README.md by @kojix2 in [#223](https://github.com/mamantoha/crest/pull/223)
- Fix to changes in `HTTP::Client` by @mamantoha in [#224](https://github.com/mamantoha/crest/pull/224)
- Rewrite specs without Kemal and enable Windows CI @mamantoha in [#226](https://github.com/mamantoha/crest/pull/226)

## [1.3.13][] (2024-03-21)

- Use `http_proxy` >= 0.10.2

## [1.3.12][] (2023-07-26)

- Add multipart parameter to request by @jphaward in [#214](https://github.com/mamantoha/crest/pull/214)

## [1.3.11][] (2023-05-09)

- Fixes `Response#content_length` to be Int64 by @mamantoha in [#212](https://github.com/mamantoha/crest/pull/212)

## [1.3.10][] (2023-05-09)

- Add `Response#content_length` by @mamantoha in [#211](https://github.com/mamantoha/crest/pull/211)

## [1.3.9][] (2023-05-06)

* Fixes the issue of retrieving the filename from the response header by @mamantoha in [#210](https://github.com/mamantoha/crest/pull/210)

## [1.3.8][] (2023-01-22)

- Do not merge request headers into the response in [#203](https://github.com/mamantoha/crest/pull/203). Fixes [#201](https://github.com/mamantoha/crest/pull/201)

## [1.3.7][] (2023-01-10)

- Fixes for Crystal 1.7.0
- Add `closed?` method to `Crest::Request`
- **chore**: reverted VCR by @mamantoha in https://github.com/mamantoha/crest/pull/193
- **chore**: use actions/checkout@v3 by @mamantoha in https://github.com/mamantoha/crest/pull/196
- **chore**: use Crystal Ameba GitHub Action by @mamantoha in https://github.com/mamantoha/crest/pull/197

## [1.3.6][] (2022-10-04)

- Support encoding array of arrays by @cyangle in https://github.com/mamantoha/crest/pull/190
- remove vcr by @mamantoha in https://github.com/mamantoha/crest/pull/192

## [1.3.5][] (2022-09-27)

- Use specified `Crest::ParamsEncoder` for `Crest::DataForm` by @mamantoha in https://github.com/mamantoha/crest/pull/189

## [1.3.4][] (2022-09-26)

- Extract `Crest::ParamsEncoder#flatten_params(object : JSON::Any, parent_key : String? = nil)` by @mamantoha in https://github.com/mamantoha/crest/pull/188

## [1.3.3][] (2022-09-26)

- Allow `JSON::Any` in `FlatParamsEncoder` and `NestedParamsEncoder` by @mamantoha in https://github.com/mamantoha/crest/pull/187

## [1.3.2][] (2022-09-26)

- Support encoding `JSON::Any` as hash values with `Crest::EnumeratedFlatParamsEncoder` by @cyangle in https://github.com/mamantoha/crest/pull/181
- back VCR by @mamantoha in https://github.com/mamantoha/crest/pull/180

## [1.3.1][] (2022-05-30)

- Multipart form with IO as hash value instead of just File by @cyangle in [#179](https://github.com/mamantoha/crest/pull/179)

## [1.3.0][] (2022-05-28)

- Set default MIME type to application/octet-stream by @cyangle in [#174](https://github.com/mamantoha/crest/pull/174)
- Support IO and Bytes as form data by @cyangle in [#175](https://github.com/mamantoha/crest/pull/176). This allow direct file upload.

  ```crystal
  file = File.open("#{__DIR__}/avatar.png")
  response = Crest::Request.post("https://httpbin.org/upload", form: file)
  ```

## [1.2.1][] (2022-02-17)

- Bug fixes and stability improvements for `Crest::Requests` [#172](https://github.com/mamantoha/crest/pull/172)
- Pass `tsl` parameter in redirects
- Set `HTTP::Client#tsl` only for https requests

## [1.2.0][] (2022-02-14)

- **(breaking-change)** `#decode` method extracted from `Crest::ParamsEncoder` to `Crest::ParamsDecoder` by @mamantoha in https://github.com/mamantoha/crest/pull/170

  ```crystal
  query = "size=small&topping[1]=bacon&topping[2]=onion"
  Crest::ParamsDecoder.decode(query)
  # => {"size" => "small", "topping" => ["bacon", "onion"]}

  ```

- Add `Crest::EnumeratedFlatParamsEncoder` by @mamantoha in https://github.com/mamantoha/crest/pull/170

  ```crystal
  response = Crest.post(
    "http://httpbin.org/post",
    {"size" => "small", "topping" => ["bacon", "onion"]},
    params_encoder: Crest::EnumeratedFlatParamsEncoder
  )
  # => curl -X POST http://httpbin.org/post -d 'size=small&topping[1]=bacon&topping[2]=onion' -H 'Content-Type: application/x-www-form-urlencoded'
  ```

- Expose timeout options by @mamantoha in https://github.com/mamantoha/crest/pull/171

## [1.1.0][] (2022-01-23)

- Tested with Crystal 1.3.0
- Accept `Float32` and `Float64` as params value by @mamantoha in https://github.com/mamantoha/crest/pull/166
- Add `read_timeout` support by @kates in https://github.com/mamantoha/crest/pull/169
- Add custom params encoders by @mamantoha in https://github.com/mamantoha/crest/pull/167
  (thanks @cyangle for the idea in https://github.com/mamantoha/crest/pull/162)

  It is now possible to use a custom params encoder. For example `Crest::NestedParamsEncoder`:

  ```crystal
  response = Crest.post(
    "http://httpbin.org/post",
    {"size" => "small", "topping" => ["bacon", "onion"]},
    params_encoder: Crest::NestedParamsEncoder
  )
  # => curl -X POST http://httpbin.org/post -d 'size=small&topping=bacon&topping=onion' -H 'Content-Type: application/x-www-form-urlencoded'
  ```

  By defaulf `Crest::FlatParamsEncoder` is used:

  ```crystal
  response = Crest.post(
    "http://httpbin.org/post",
    {"size" => "small", "topping" => ["bacon", "onion"]}
  )
  # => curl -X POST http://httpbin.org/post -d 'size=small&topping[]=bacon&topping[]=onion' -H 'Content-Type: application/x-www-form-urlencoded'
  ```

## [1.0.1][] (2021-12-21)

- Support raw string query params by @cyangle in https://github.com/mamantoha/crest/pull/162
- Accept `Int64` as params value by @mamantoha in https://github.com/mamantoha/crest/pull/164

## [1.0.0][] (2021-10-14)

- **(breaking-change)** Default request headers: Crest sets `Accept: */*`
- Added the ability to not explicitly specify `form` argument for `Crest` methods

  It is now possible to use

  ```crystal
  Crest.post("http://httpbin.org/post", {"token" => "my-secret-token"}, headers: {"Accept" => "application/json"})
  ```

  just as well as

  ```crystal
  Crest.post("http://httpbin.org/post", headers: {"Accept" => "application/json"}, form: {"token" => "my-secret-token"})
  ```

- Added the ability to not explicitly specify `form` argument for `Crest::Request#execute`, `Crest::Request#post`, etc

  ```crystal
  Crest::Request.post(
    "http://httpbin.org/post",
    {"token" => "my-secret-token"},
    headers: {"Accept" => "application/json"}
  )
  ```

- Added the ability to not explicitly specify `form` argument for `Crest::Resource` verb method

  ```crystal
  resource = Crest::Resource.new("http://httpbin.org")
  resource["post"].post({"token" => "my-secret-token"})
  ```

- Add `json` argument to make request with JSON payload and the appropriate HTTP headers

  ```crystal
  Crest.post("http://httpbin.org/post", {:foo => "bar"}, json: true)
  # curl -X POST http://httpbin.org/post -d '{\"foo\":\"bar\"}' -H 'Content-Type: application/json'"
  ```

- Allow to set `cookies` for `Crest::Resource` initializer
- Allow to set `cookies` for `Crest::Resource` verb methods
- Fix `Crest::Response#to_curl` for requests with "multipart/form-data" ([#153](https://github.com/mamantoha/crest/pull/153))
- Allow to set "User-Agent" header with `user_agent` argument ([#154](https://github.com/mamantoha/crest/pull/154))

## [0.27.1][] (2021-07-22)

- Allow to use nested `Hash` as `cookies` ([#149](https://github.com/mamantoha/crest/pull/149))
- Fix proxy in `Curlify`

## [0.27.0][] (2021-03-23)

- Close HTTP connection after `Request#execute` by default
- Add `close_connection` (`true` by default) option for `Crest::Request` initializer
- Add `close_connection` (`false` by default) option for `Crest::Resource` initializer
- Add `close` method to `Crest::Request`
- Add `close`, `closed?` methods to `Crest::Resource`

## [0.26.7][] (2021-02-08)

- Temporary workaround for [memory leak](https://github.com/crystal-lang/crystal/issues/10373) in Crystal

## [0.26.6][] (2021-01-27)

- Bump dependencies

## [0.26.5][] (2021-01-27)

- Require Crystal >= 0.36.0

## [0.26.4][] (2021-01-16)

- Bump [http_proxy](https://github.com/mamantoha/http_proxy) shard

## [0.26.3][] (2021-01-12)

- Fix compatibility with Crystal nightly

## [0.26.2][] (2021-01-05)

- Support for International Domain Names ([#143](https://github.com/mamantoha/crest/pull/143))

## [0.26.1][] (2020-07-07)

- Fixed compatibility with Crystal nightly

## [0.26.0][] (2020-06-18)

- Crystal 0.35.0 required
- Use [http_proxy](https://github.com/mamantoha/http_proxy) shard instead of built-in implementation

## [0.25.1][] (2020-06-02)

- Bug fixes and other improvements

## [0.25.0][] (2020-04-07)

- Crystal 0.34.0 required
- Rewrite `Crest::Logger` class
- Fix redirects when "Location" header is downcased

## [0.24.1][] (2020-03-29)

- Fix `handle_errors` is ignored for redirect errors ([#132](https://github.com/mamantoha/crest/issues/132))

## [0.24.0][] (2020-03-13)

- Add `Crest#ParamsEncoder` module to encode/decode URI query string
- Replace `Crest::Utils#encode_query_string` `with Crest::ParamsEncoder#encode`
- Allow `Boolean` in params

## [0.23.2][] (2020-01-03)

- Fix an issue with wrong "Content-Type" header

## [0.23.1][] (2019-12-14)

- Add a more descriptive crest user agent

## [0.23.0][] (2019-12-12)

- Add methods `to_s` and `inspect` to `Crest::Response`
- Support Crystal 0.32.0

## [0.22.0][] (2019-09-17)

- Support Crystal 0.31.0
- Digest access authentication support ([#127](https://github.com/mamantoha/crest/pull/127))
- Add proxy to `to_curl` method

## [0.21.1][] (2019-08-13)

- **(breaking-change)** Require Crystal 0.30.1

## [0.21.0][] (2019-08-02)

- **(breaking-change)** Require Crystal 0.30.0
- **(breaking-change)** Rename `Crest::Response#successful?` to `Crest::Response#success?`
- Add method `Crest::Response#status` as `HTTP::Status`

## [0.20.0][] (2019-06-14)

- Tested with Crystal 0.29.0
- Improve testing process ([#120](https://github.com/mamantoha/crest/pull/120))

## [0.19.1][] (2019-05-09)

- Delegate method `to_curl` to `Crest::Response` instance
- Fix an issue in `Resource` when base url ends with `/`

## [0.19.0][] (2019-04-18)

- Add method `head` ([#116](https://github.com/mamantoha/crest/pull/116))
- Tested with Crystal 0.28.0

## [0.18.3][] (2019-02-06)

- Tested with Crystal 0.27.2

## [0.18.2][] (2019-02-03)

- Tested with Crystal 0.27.1

## [0.18.1][] (2019-01-16)

- Fix extracting filename from Content-Disposition header

## [0.18.0][] (2019-01-06)

- **(breaking-change)** Streaming support. `Crest`, `Crest::Request` and `Crest::Resource` verb methods(`get`, `post`, etc.) yields the `Crest::Response` as stream to the block ([#110](https://github.com/mamantoha/crest/pull/110))
- **(breaking-change)** Needs to specify `form`, `headers` and `params` arguments for `Crest::Resource` methods ([#112](https://github.com/mamantoha/crest/pull/112))
- Add `Crest::Response#filename` method ([#111](https://github.com/mamantoha/crest/pull/111))
- Add response helper methods (`successful?`, `redirection?`, etc) ([#107](https://github.com/mamantoha/crest/pull/107))
- Extract redirection logic into `Crest::Redirector` class ([#109](https://github.com/mamantoha/crest/pull/109))

## [0.17.0][] (2018-11-17)

- **(breaking-change)** `Crest` and `Crest::Request` verb methods(`get`, `post`, etc.) yields the `Crest::Response` to the block
- Refactor proxy client

## [0.16.1][] (2018-11-05)

- Update to Kemal 0.25.1

## [0.16.0][] (2018-11-03)

- Tested with Crystal 0.27.0

## [0.15.0][] (2018-10-12)

- SSL/TLS support ([#100](https://github.com/mamantoha/crest/pull/100))
- Tested with Crystal 0.26.1

## [0.14.0][] (2018-08-14)

- Tested with Crystal 0.26.0

## [0.13.0][] (2018-08-13)

- Add `Crest::Request#to_curl` to convert request to cURL command ([#95](https://github.com/mamantoha/crest/pull/95))
- Bug fixes and other improvements

## [0.12.0][] (2018-07-17)

- **(breaking-change)** Rename `Request#payload` to `Request#form`
- Use `application/x-www-form-urlencoded` for forms by default. And `multipart/form-data` when a form includes any `<input type="file">` elements.
- Fix serialize query to string representation as http url-encoded

## [0.11.0][] (2018-07-14)

- Add `Logger#filter` method to filter sensitive information from logs with a regex matcher
- Allow to do request with `suburl` through `Request#http_verb(suburl)` method
- Bug fixes and other improvements

## [0.10.2][] (2018-06-15)

- Tested with Crystal 0.25.0

## [0.10.1][] (2018-05-14)

- Fix `Crest::Utils.flatten_params` method ([#85](https://github.com/mamantoha/crest/pull/85))
- Reduce the false positiveness in code as much as possible ([#83](https://github.com/mamantoha/crest/pull/83), thanks @veelenga)

## [0.10.0][] (2018-04-24)

- Add HTTP verb methods (`get`, `post`, etc) to `Crest::Request`
- `Crest` and `Crest::Request` verb methods(`get`, `post`, etc.) can yields the `Crest::Request` to the block
- `Crest::Request` and `Crest::Resource` initializer can accept block
- Access instance of `HTTP::Client` via `Crest::Request#http_client`
- Access instance of `HTTP::Client` via `Crest::Resource#http_client`
- `Crest::Request` and `Crest::Resource` initializer can accept `HTTP::Client` as `http_client`
- Add method `options` to `HTTP::Resource`

## [0.9.10][] (2018-04-08)

- Add option `:handle_errors` to don't raise exceptions but return the `Response`
- Add custom exceptions for each status code

## [0.9.9][] (2018-04-03)

- Add method `OPTIONS`
- Fix `Crest::Response#headers` method to return response headers

## [0.9.8][] (2018-03-18)

- Tested with Crystal 0.24.2
- Fix Basic Authentication

## [0.9.7][] (2018-03-05)

- Allow `Crest::Resource` to accept default `params` and `headers`
- Allow `Crest::Resource` to accept more parameters(proxy authentication credentials, logging setup)
- Refactor exceptions class
- Setup GitHub Pages branch to host docs

## [0.9.6][] (2018-01-05)

- Proxy on redirects
- Logger in redirects

## [0.9.5][] (2017-12-30)

- Bug fixes and performance improvements

## [0.9.4][] (2017-12-25)

- Tested with Crystal 0.24.1

## [0.9.3][] (2017-12-19)

- Add logging

## 0.9.2 (2017-11-01)

- First release :tada:

[...]: https://github.com/mamantoha/crest/compare/v1.5.1...HEAD
[1.5.1]: https://github.com/mamantoha/crest/compare/v1.5.0...v1.5.1
[1.5.0]: https://github.com/mamantoha/crest/compare/v1.4.1...v1.5.0
[1.4.1]: https://github.com/mamantoha/crest/compare/v1.4.0...v1.4.1
[1.4.0]: https://github.com/mamantoha/crest/compare/v1.3.13...v1.4.0
[1.3.13]: https://github.com/mamantoha/crest/compare/v1.3.12...v1.3.13
[1.3.12]: https://github.com/mamantoha/crest/compare/v1.3.11...v1.3.12
[1.3.11]: https://github.com/mamantoha/crest/compare/v1.3.10...v1.3.11
[1.3.10]: https://github.com/mamantoha/crest/compare/v1.3.9...v1.3.10
[1.3.9]: https://github.com/mamantoha/crest/compare/v1.3.8...v1.3.9
[1.3.8]: https://github.com/mamantoha/crest/compare/v1.3.7...v1.3.8
[1.3.7]: https://github.com/mamantoha/crest/compare/v1.3.6...v1.3.7
[1.3.6]: https://github.com/mamantoha/crest/compare/v1.3.5...v1.3.6
[1.3.5]: https://github.com/mamantoha/crest/compare/v1.3.4...v1.3.5
[1.3.4]: https://github.com/mamantoha/crest/compare/v1.3.3...v1.3.4
[1.3.3]: https://github.com/mamantoha/crest/compare/v1.3.2...v1.3.3
[1.3.2]: https://github.com/mamantoha/crest/compare/v1.3.1...v1.3.2
[1.3.1]: https://github.com/mamantoha/crest/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/mamantoha/crest/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/mamantoha/crest/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/mamantoha/crest/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/mamantoha/crest/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/mamantoha/crest/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/mamantoha/crest/compare/v0.27.1...v1.0.0
[0.27.1]: https://github.com/mamantoha/crest/compare/v0.27.0...v0.27.1
[0.27.0]: https://github.com/mamantoha/crest/compare/v0.26.7...v0.27.0
[0.26.7]: https://github.com/mamantoha/crest/compare/v0.26.6...v0.26.7
[0.26.6]: https://github.com/mamantoha/crest/compare/v0.26.5...v0.26.6
[0.26.5]: https://github.com/mamantoha/crest/compare/v0.26.4...v0.26.5
[0.26.4]: https://github.com/mamantoha/crest/compare/v0.26.3...v0.26.4
[0.26.3]: https://github.com/mamantoha/crest/compare/v0.26.2...v0.26.3
[0.26.2]: https://github.com/mamantoha/crest/compare/v0.26.1...v0.26.2
[0.26.1]: https://github.com/mamantoha/crest/compare/v0.26.0...v0.26.1
[0.26.0]: https://github.com/mamantoha/crest/compare/v0.25.1...v0.26.0
[0.25.1]: https://github.com/mamantoha/crest/compare/v0.25.0...v0.25.1
[0.25.0]: https://github.com/mamantoha/crest/compare/v0.24.1...v0.25.0
[0.24.1]: https://github.com/mamantoha/crest/compare/v0.24.0...v0.24.1
[0.24.0]: https://github.com/mamantoha/crest/compare/v0.23.2...v0.24.0
[0.23.2]: https://github.com/mamantoha/crest/compare/v0.23.1...v0.23.2
[0.23.1]: https://github.com/mamantoha/crest/compare/v0.23.0...v0.23.1
[0.23.0]: https://github.com/mamantoha/crest/compare/v0.22.0...v0.23.0
[0.22.0]: https://github.com/mamantoha/crest/compare/v0.21.1...v0.22.0
[0.21.1]: https://github.com/mamantoha/crest/compare/v0.21.0...v0.21.1
[0.21.0]: https://github.com/mamantoha/crest/compare/v0.20.0...v0.21.0
[0.20.0]: https://github.com/mamantoha/crest/compare/v0.19.1...v0.20.0
[0.19.1]: https://github.com/mamantoha/crest/compare/v0.19.0...v0.19.1
[0.19.0]: https://github.com/mamantoha/crest/compare/v0.18.3...v0.19.0
[0.18.3]: https://github.com/mamantoha/crest/compare/v0.18.2...v0.18.3
[0.18.2]: https://github.com/mamantoha/crest/compare/v0.18.1...v0.18.2
[0.18.1]: https://github.com/mamantoha/crest/compare/v0.18.0...v0.18.1
[0.18.0]: https://github.com/mamantoha/crest/compare/v0.17.0...v0.18.0
[0.17.0]: https://github.com/mamantoha/crest/compare/v0.16.1...v0.17.0
[0.16.1]: https://github.com/mamantoha/crest/compare/v0.16.0...v0.16.1
[0.16.0]: https://github.com/mamantoha/crest/compare/v0.15.0...v0.16.0
[0.15.0]: https://github.com/mamantoha/crest/compare/v0.14.0...v0.15.0
[0.14.0]: https://github.com/mamantoha/crest/compare/v0.13.0...v0.14.0
[0.13.0]: https://github.com/mamantoha/crest/compare/v0.12.0...v0.13.0
[0.12.0]: https://github.com/mamantoha/crest/compare/v0.11.0...v0.12.0
[0.11.0]: https://github.com/mamantoha/crest/compare/v0.10.2...v0.11.0
[0.10.2]: https://github.com/mamantoha/crest/compare/v0.10.1...v0.10.2
[0.10.1]: https://github.com/mamantoha/crest/compare/v0.10.0...v0.10.1
[0.10.0]: https://github.com/mamantoha/crest/compare/v0.9.10...v0.10.0
[0.9.10]: https://github.com/mamantoha/crest/compare/v0.9.9...v0.9.10
[0.9.9]: https://github.com/mamantoha/crest/compare/v0.9.8...v0.9.9
[0.9.8]: https://github.com/mamantoha/crest/compare/v0.9.7...v0.9.8
[0.9.7]: https://github.com/mamantoha/crest/compare/v0.9.6...v0.9.7
[0.9.6]: https://github.com/mamantoha/crest/compare/v0.9.5...v0.9.6
[0.9.5]: https://github.com/mamantoha/crest/compare/v0.9.4...v0.9.5
[0.9.4]: https://github.com/mamantoha/crest/compare/v0.9.3...v0.9.4
[0.9.3]: https://github.com/mamantoha/crest/compare/v0.9.2...v0.9.3
