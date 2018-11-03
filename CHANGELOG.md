# Changelog

## [...]

## 0.16.0

* Tested with Crystal 0.27.0

## 0.15.0

* SSL/TLS support ([#100](https://github.com/mamantoha/crest/pull/100))
* Tested with Crystal 0.26.1

## 0.14.0

* Tested with Crystal 0.26.0

## 0.13.0

* Add `Crest::Request#to_curl` to convert request to cURL command ([#95](https://github.com/mamantoha/crest/pull/95))
* Bug fixes and other improvements

## 0.12.0

* **(breaking-change)** Rename `Request#payload` to `Request#form`
* Use `application/x-www-form-urlencoded` for forms by default. And `multipart/form-data` when a form includes any `<input type="file">` elements.
* Fix serialize query to string representation as http url-encoded

## 0.11.0

* Add `Logger#filter` method to filter sensitive information from logs with a regex matcher
* Allow to do request with `suburl` through `Request#http_verb(suburl)` method
* Bug fixes and other improvements

## 0.10.2

* Tested with Crystal 0.25.0

## 0.10.1

* Fix `Crest::Utils.flatten_params` method ([#85](https://github.com/mamantoha/crest/pull/85))
* Reduce the false positiveness in code as much as possible ([#83](https://github.com/mamantoha/crest/pull/83), thanks @veelenga)

## 0.10.0

* Add HTTP verb methods (`get`, `post`, etc) to `Crest::Request`
* `Crest` and `Crest::Request` verb methods(`get`, `post`, etc.) can yields the `Crest::Request` to the block
* `Crest::Request` and `Crest::Resource` initializer can accept block
* Access instance of `HTTP::Client` via `Crest::Request#http_client`
* Access instance of `HTTP::Client` via `Crest::Resource#http_client`
* `Crest::Request` and `Crest::Resource` initializer can accept `HTTP::Client` as `http_client`
* Add method `options` to `HTTP::Resource`

## 0.9.10

* Add option `:handle_errors` to don't raise exceptions but return the `Response`
* Add custom exceptions for each status code

## 0.9.9

* Add method `OPTIONS`
* Fix `Crest::Response#headers` method to return response headers

## 0.9.8

* Tested with Crystal 0.24.2
* Fix Basic Authentication

## 0.9.7

* Allow `Crest::Resource` to accept default `params` and `headers`
* Allow `Crest::Resource` to accept more parameters(proxy authentication credentials, logging setup)
* Refactor exceptions class
* Setup GitHub Pages branch to host docs

## 0.9.6

* Proxy on redirects
* Logger in redirects

## 0.9.5

* Bug fixes and performance improvements

## 0.9.4

* Tested with Crystal 0.24.1

## 0.9.3

* Add logging

## 0.9.2

* First release :tada:
