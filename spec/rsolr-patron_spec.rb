require "spec_helper"

describe RSolr::Patron do

  it "modifies RSolr" do
    RSolr.should be_a(RSolr::Patron::Connectable)
  end

  it "does not modify the default connection behavior" do
    RSolr.connect.connection.should be_a(RSolr::Connection::NetHttp)
  end

  it "creates an instance of RSolr::Patron::Connection with the :patron argument" do
    RSolr.connect(:patron).connection.should be_a(RSolr::Patron::Connection)
  end

  it "assigns additional options as allowed by the patron session" do
    # whee black-box testing!
    connection = RSolr::Patron::Connection.new(
      :url => "http://foo", :timeout => 1234, :connect_timeout => 7)
    connection.send(:connection).timeout.should == 1234
    connection.send(:connection).connect_timeout.should == 7
  end

  it "sets the patron base url and proxy" do
    connection = RSolr::Patron::Connection.new(
      :url => "http://foo:3456/path/to/things", :proxy => "http://proxy:8080")
    connection.send(:connection).base_url.should == "http://foo:3456"
    connection.send(:connection).proxy.should == "http://proxy:8080"
  end

  describe "#get" do
    it "calls #get on the patron connection with the appropriate data" do
      connection = RSolr::Patron::Connection.new
      connection.send(:connection) \
        .should_receive(:get).with("/solr/search?q=foo") \
        .and_return mock("body", :body => "", :status => 200, :status_line => "OK")
      connection.request("/search", :q => "foo")
    end
  end

  describe "#post" do
    it "calls #post on the patron connection" do
      connection = RSolr::Patron::Connection.new
      connection.send(:connection).should_receive(:post) \
        .with("/solr/search", "q=query", {"Content-Type"=>"application/x-www-form-urlencoded"}) \
        .and_return mock("body", :body => "", :status => 200, :status_line => "OK")
      connection.request("/search", {:q => "query"}, :method => :post)
    end
  end

#   context '#request' do
#     it 'should forward simple, non-data calls to #get' do

#       EM.run do

#         EM.add_timer(1) do
#           EM.stop
#         end

#         EM::MockHttpRequest.pass_through_requests = false
#         body = <<-EOM
# HTTP/1.1 200 OK
# Date: Mon, 16 Nov 2009 20:39:15 GMT
# Expires: -1
# Cache-Control: private, max-age=0
# Content-Type: text/xml; charset=utf-8
# Connection: close

# <?xml version="1.0" encoding="UTF-8"?>
# <response>
# <lst name="responseHeader"><int name="status">0</int><int name="QTime">1</int><lst name="params"><str name="q">a</str></lst></lst><result name="response" numFound="0" start="0"/>
# </response>
# EOM
#         EM::MockHttpRequest.register 'http://127.0.0.1:8983/solr/select?q=a', :get, body

#         Fiber.new do
#           begin
#             http = new_connection
#             resp = http.request('/select', :q=>'a')
#             resp[:status_code].should == 200
#           rescue Exception => ex
#             puts ex.message
#             puts ex.backtrace.join("\n")
#           end
#           EM.stop
#         end.resume
#       end

#     end
#   end

end
