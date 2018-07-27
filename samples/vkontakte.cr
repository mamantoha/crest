require "../crest"
require "xml"
require "json"

module Vk
  API_VERSION = "5.67"

  class Error < Exception; end

  class Client
    @access_token : String? = nil
    @user_id : String? = nil

    getter access_token, client_id, user_id, cookies,
      display, scope, response_type, email, password

    REDIRECT_URI = "https://oauth.vk.com/blank.html"
    AUTH_URL     = "https://oauth.vk.com/authorize"

    def initialize(client_id : String)
      @client_id = client_id
      @cookies = {} of String => String
    end

    def login(
      @email : String,
      @password : String,
      *,
      @scope = "",
      @display = "mobile",
      @response_type = "token"
    )
      get_access_token(
        submit_form_with_captcha(
          submit_login_form(
            get_login_page
          )
        )
      )
    end

    private def get_login_page : Crest::Response
      query = {
        "client_id"     => client_id,
        "redirect_uri"  => REDIRECT_URI,
        "display"       => display,
        "scope"         => scope,
        "response_type" => response_type,
      }

      response = Crest.get(AUTH_URL, params: query)
      cookies.merge!(response.cookies)

      return response
    end

    private def submit_login_form(response : Crest::Response) : Crest::Response
      xml = XML.parse_html(response.body)

      form = xml.xpath_node("//*[contains(@class, 'form_item')]/form")

      if form
        login_url = form.[]("action")
      end

      form_inputs = xml.xpath("//*[contains(@class, 'form_item')]/form//input[@name]")

      form_params = {} of String => String
      if form_inputs.is_a?(XML::NodeSet)
        form_inputs.each do |input|
          form_params["#{input.[]("name")}"] = "#{input.[]?("value")}"
        end
      end

      form_params.merge!({"email" => email.not_nil!, "pass" => password.not_nil!})
      response = Crest.post(login_url.to_s, form: form_params, cookies: cookies)

      cookies.merge!(response.cookies)

      return response
    end

    private def submit_form_with_captcha(response : Crest::Response) : Crest::Response
      xml = XML.parse_html(response.body)
      img_captcha_node = xml.xpath_node("//img[@class='captcha_img']/@src")

      if img_captcha_node
        puts img_captcha_node.content
        print "Captcha: "
        captcha_key = gets(chomp: true).to_s

        form = xml.xpath_node("//*[contains(@class, 'form_item')]/form")

        if form
          login_url = form.["action"]
        end

        form_inputs = xml.xpath("//*[contains(@class, 'form_item')]/form//input[@name]")

        form_params = {} of String => String
        if form_inputs.is_a?(XML::NodeSet)
          form_inputs.each do |input|
            form_params["#{input.[]("name")}"] = "#{input.[]?("value")}"
          end
        end

        form_params.merge!({"email" => email.not_nil!, "pass" => password.not_nil!, "captcha_key" => captcha_key.to_s})

        response = Crest.post(login_url.to_s, form: form_params, cookies: cookies)
        check_captcha(response)
      end

      return response
    end

    private def check_captcha(response)
      query = URI.parse(response.url).query

      if query
        query = query_to_h(query)

        case query["m"]
        when "5"
          raise Error.new("Wrong captcha")
        when "4"
          raise Error.new("Wrong email or password")
        end
      end
    end

    def get_access_token(response : Crest::Response)
      fragment = URI.parse(response.url).fragment
      return if fragment.nil?
      params = query_to_h(fragment)

      @access_token = params["access_token"]
      @user_id = params["user_id"]

      return params
    end

    def api_request(method_name : String, params = {} of String => String)
      @access_token.try do |access_token|
        api = Crest::Resource.new(
          "https://api.vk.com/method/",
          params: {"access_token" => access_token, "v" => API_VERSION},
          logging: true
        )
        resp = api[method_name].post(params: params)
        JSON.parse(resp.body)
      end
    end

    private def query_to_h(str : String)
      str.split("&").map do |pairs|
        key, value = pairs.split('=', 2).map { |v| URI.unescape(v) }
        [key, value]
      end.to_h
    end
  end
end

client_id = "5987497"
scope = "friends"

begin
  email = ARGV[0]
  password = ARGV[1]
rescue e : IndexError
  puts "You should provider email and password as arguments"
  exit
end

client = Vk::Client.new(client_id)
client.login(email, password, scope: scope)
puts "Access token: #{client.access_token}"

fields = "photo_50,city,verified,counters"
resp = client.api_request("users.get", {"name_case" => "Nom", "fields" => fields})
puts resp
