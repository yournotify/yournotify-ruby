# Yournotify Ruby

Ruby client for the current Yournotify API.

## Install

```bash
gem install yournotify-ruby
```

## Quickstart

```ruby
require 'yournotify'

client = Yournotify::Client.new('YOURNOTIFY_API_KEY')

begin
	client.validate_auth
	client.send_email(
		'Welcome',
		'Welcome',
		'<p>Hello</p>',
		'Hello',
		'draft',
		'noreply@smtp.yournotify.net',
		[{ email: 'person@example.com', name: 'Person' }]
	)
rescue Yournotify::ApiError => e
	puts [e.status, e.body]
end
```

## Supported Surface

- Campaigns: `create_campaign`, `send_email`, `send_sms`, `send_whatsapp`, `send_push`, `send_inapp`, `test_campaign`, analytics helpers
- Contacts: `add_contact`, `get_contacts`
- Rewards: `get_rewards`, `create_reward`, `send_reward`, `get_reward_products`
- Automation: `identify`, `track`
- Auth: `validate_auth`, `get_profile`
