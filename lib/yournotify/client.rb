require "json"
require "net/http"
require "uri"

module Yournotify
  class ApiError < StandardError
    attr_reader :status, :body

    def initialize(message, status, body)
      super(message)
      @status = status
      @body = body
    end
  end

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
      body = res.body && !res.body.empty? ? JSON.parse(res.body) : {}
      raise ApiError.new(body['message'] || "Yournotify API request failed with status #{res.code}.", res.code.to_i, body) unless res.is_a?(Net::HTTPSuccess)

      body
    end

    def validate_auth
      request('auth/me')
    end

    def create_campaign(data = {})
      request('campaigns', 'POST', data)
    end

    def send_email(name, subject, html, text = '', status = 'draft', from = '', to = [])
      create_campaign({ name: name, subject: subject, html: html, body: html, text: text, from: from, from_email: from, status: status, channel: 'email', lists: to })
    end

    def send_sms(name, from, text, status = 'draft', to = [])
      create_campaign({ name: name, from: from, sender: from, text: text, body: text, status: status, channel: 'sms', lists: to })
    end

    def send_whatsapp(data = {})
      create_campaign(data.merge(channel: 'whatsapp'))
    end

    def send_push(data = {})
      create_campaign(data.merge(channel: 'push'))
    end

    def send_inapp(data = {})
      create_campaign(data.merge(channel: 'inapp'))
    end

    def test_campaign(data = {})
      request('campaigns/test', 'POST', data)
    end

    def get_campaign(id)
      request("campaigns/#{id}")
    end

    def get_campaigns(channel = nil, params = {})
      request('campaigns', 'GET', channel ? params.merge(channel: channel) : params)
    end

    def update_campaign(id, data = {})
      request("campaigns/#{id}", 'PUT', data)
    end

    def delete_campaign(id)
      request("campaigns/#{id}", 'DELETE')
    end

    def get_campaign_stats(id, channel = 'email')
      request("campaigns/#{id}/analytics/stats", 'GET', { channel: channel })
    end

    def get_campaign_reports(id, channel = 'email')
      request("campaigns/#{id}/analytics/reports", 'GET', { channel: channel })
    end

    def add_contact(data = {})
      request('contacts', 'POST', data)
    end

    def get_contacts(params = {})
      request('contacts', 'GET', params)
    end

    def get_rewards(params = {})
      request('rewards', 'GET', params)
    end

    def create_reward(data = {})
      request('rewards', 'POST', data)
    end

    def send_reward(data = {})
      request('rewards/send', 'POST', data)
    end

    def get_reward_products(params = {})
      request('rewards/products', 'GET', params)
    end
    def get_reward_analytics(id); request("rewards/#{id}/analytics"); end
    def get_reward_submissions(id, params = {}); request("rewards/#{id}/submissions", 'GET', params); end
    def invite_to_reward(id, data = {}); request("rewards/#{id}/invite", 'POST', data); end
    def send_created_reward(id, data = {}); request("rewards/#{id}/send", 'POST', data); end
    def get_reward_bulk_job(id, job_id); request("rewards/#{id}/bulk-jobs/#{job_id}"); end
    def retry_reward_bulk_job(id, job_id); request("rewards/#{id}/bulk-jobs/#{job_id}/retry", 'POST', {}); end
    def bootstrap_reward_claim(data = {}); request('rewards/reward', 'POST', data); end
    def submit_reward_claim(data = {}); request('rewards/submit', 'POST', data); end

    def get_loyalty_programs(params = {}); request('loyalty/programs', 'GET', params); end
    def get_loyalty_program(id); request("loyalty/programs/#{id}"); end
    def create_loyalty_program(data = {}); request('loyalty/programs', 'POST', data); end
    def update_loyalty_program(id, data = {}); request("loyalty/programs/#{id}", 'PUT', data); end
    def get_loyalty_members(id, params = {}); request("loyalty/programs/#{id}/members", 'GET', params); end
    def get_loyalty_member(id, subscriber_id); request("loyalty/programs/#{id}/members/#{subscriber_id}"); end
    def adjust_loyalty_points(id, data = {}); request("loyalty/programs/#{id}/points", 'POST', data); end
    def track_loyalty_event(id, data = {}); request("loyalty/programs/#{id}/events", 'POST', data); end
    def add_loyalty_rule(id, data = {}); request("loyalty/programs/#{id}/rules", 'POST', data); end
    def connect_loyalty_reward(id, data = {}); request("loyalty/programs/#{id}/rewards", 'POST', data); end
    def redeem_loyalty_reward(id, data = {}); request("loyalty/programs/#{id}/redeem", 'POST', data); end
    def get_referral_programs(params = {}); request('referrals/programs', 'GET', params); end
    def get_referral_program(id); request("referrals/programs/#{id}"); end
    def create_referral_program(data = {}); request('referrals/programs', 'POST', data); end
    def update_referral_program(id, data = {}); request("referrals/programs/#{id}", 'PUT', data); end
    def delete_referral_program(id); request("referrals/programs/#{id}", 'DELETE'); end
    def add_referral_advocate(id, data = {}); request("referrals/programs/#{id}/advocates", 'POST', data); end
    def get_referral_advocates(id, params = {}); request("referrals/programs/#{id}/advocates", 'GET', params); end
    def add_referral_advocates_from_lists(id, data = {}); request("referrals/programs/#{id}/advocates/bulk", 'POST', data); end
    def remove_referral_advocate(id, advocate_id); request("referrals/programs/#{id}/advocates/#{advocate_id}", 'DELETE'); end
    def track_referral_event(id, data = {}); request("referrals/programs/#{id}/events", 'POST', data); end
    def get_referral_analytics(id, params = {}); request("referrals/programs/#{id}/analytics", 'GET', params); end
    def retry_referral_conversion(id, conversion_id); request("referrals/programs/#{id}/conversions/#{conversion_id}/retry", 'POST', {}); end
    def review_referral_conversion(id, conversion_id, data = {}); request("referrals/programs/#{id}/conversions/#{conversion_id}/review", 'POST', data); end
    def get_referral_risk(id); request("referrals/programs/#{id}/risk"); end
    def create_advocate_portal_session(id, advocate_id); request("referrals/programs/#{id}/advocates/#{advocate_id}/portal-session", 'POST', {}); end

    def identify(data = {})
      request('automations/identify', 'POST', data)
    end

    def track(data = {})
      request('automations/events', 'POST', data)
    end

    def get_profile
      validate_auth
    end
  end
end
