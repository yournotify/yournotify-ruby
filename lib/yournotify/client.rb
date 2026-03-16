require "json"
require "net/http"
require "uri"

module Yournotify
  class Client
    attr_reader :api_key, :api_url

    def initialize(api_key, api_url = "https://api.yournotify.com/")
      @api_key = api_key
      @api_url = api_url.sub(%r{/*$}, '/')
    end

    def set_api_url(api_url)
      @api_url = api_url.sub(%r{/*$}, '/')
      self
    end

    def request(endpoint, method = 'GET', data = nil)
      uri = URI.join(@api_url, endpoint.sub(%r{^/+}, ''))
      uri.query = URI.encode_www_form(data) if method == 'GET' && data && !data.empty?
      klass = { 'GET' => Net::HTTP::Get, 'POST' => Net::HTTP::Post, 'PUT' => Net::HTTP::Put, 'DELETE' => Net::HTTP::Delete }[method] || Net::HTTP::Get
      req = klass.new(uri)
      req['Authorization'] = "Bearer #{@api_key}"
      req['Content-Type'] = 'application/json'
      req.body = JSON.generate(data) if method != 'GET' && data
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https') { |http| http.request(req) }
      JSON.parse(res.body)
    end

    def send_email(name, subject, html, text = '', status = 'draft', from = '', to = [])
      request('campaigns/email', 'POST', { name: name, subject: subject, html: html, body: html, text: text, from: from, from_email: from, status: status, channel: 'email', lists: to })
    end

    def send_sms(name, from, text, status = 'draft', to = [])
      request('campaigns/sms', 'POST', { name: name, from: from, sender: from, text: text, body: text, status: status, channel: 'sms', lists: to })
    end

    def get_profile
      request('account/profile')
    end
  end
end
