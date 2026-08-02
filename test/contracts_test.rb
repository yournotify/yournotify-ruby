require 'minitest/autorun';require_relative '../lib/yournotify'
class TestClient<Yournotify::Client
  attr_reader :calls
  def initialize;super('test');@calls=[];end
  def request(endpoint,method='GET',data=nil);@calls<<[method,endpoint,data];{};end
end
class ContractsTest<Minitest::Test
  def test_parity_routes;c=TestClient.new;c.send_voice(name:'Voice');c.export_list(4);c.track_batch([{event:'order.completed'}]);c.alias_contact(anonymous_id:'a',external_id:'c');assert_equal ['campaigns/voice','lists/export/4','sdk/events/batch','sdk/alias'],c.calls.map{|x|x[1]};event=c.calls[2][2][:events][0];refute_nil event[:event_id];refute_nil event[:occurred_at];end
end
