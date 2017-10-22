require "../crest"
require "xml"
require "json"

module Vk
  API_VERSION = "5.67"

  class Error < Exception; end

  class Client
    @access_token : String? = nil
    @user_id : String? = nil

    getter access_token, client_id, user_id

    def initialize(client_id : String)
      @client_id = client_id
    end

    def login(email : String, password : String, scope = "")
      redirect_uri = "https://oauth.vk.com/blank.html"
      display = "mobile"
      response_type = "token"

      query = {
        "client_id"     => client_id,
        "redirect_uri"  => redirect_uri,
        "display"       => display,
        "scope"         => scope,
        "response_type" => response_type,
      }

      url = "https://oauth.vk.com/authorize"

      response = Crest.get(url, params: query)

      body = response.body
      cookies = response.cookies

      xml = XML.parse_html(body)

      # Submit login form
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

      form_params.merge!({"email" => email, "pass" => password})
      response = Crest.post(login_url.to_s, payload: form_params, cookies: cookies)

      body = response.body
      cookies = cookies.merge(response.cookies)

      # Submit form with captcha
      xml = XML.parse_html(body)
      img_captcha_node = xml.xpath_node("//img[@class='captcha_img']/@src")

      if img_captcha_node
        print "Captcha: "
        captcha_key = gets(chomp = true).to_s

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

        form_params.merge!({"email" => email, "pass" => password, "captcha_key" => captcha_key.to_s})

        response = Crest.post(login_url.to_s, payload: form_params, cookies: cookies)
      end

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

      fragment = URI.parse(response.url).fragment
      return if fragment.nil?
      params = query_to_h(fragment)

      @access_token = params["access_token"]
      @user_id = params["user_id"]

      return params
    end

    def api_request(method_name : String, params = {} of String => String)
      api_url = "https://api.vk.com"
      params = params.merge({"access_token" => @access_token, "v" => API_VERSION})
      resp = Crest.get("#{api_url}/method/#{method_name}", params: params)

      JSON.parse(resp.body)
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
client.login(email, password, scope)
puts "Access token: #{client.access_token}"

resp = client.api_request("users.get", {"name_case" => "Nom", "fields" => "photo_50,city,verified"})
puts resp
