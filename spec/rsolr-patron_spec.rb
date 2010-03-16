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
        .should_receive(:get).with("/solr/search?q=foo", "Expect" => "") \
        .and_return mock("body", :body => "", :status => 200, :status_line => "OK")
      connection.request("/search", :q => "foo")
    end
  end

  describe "#post" do
    it "calls #post on the patron connection" do
      connection = RSolr::Patron::Connection.new
      connection.send(:connection).should_receive(:post) \
        .with("/solr/search", "q=query", {"Content-Type"=>"application/x-www-form-urlencoded", "Expect" => ""}) \
        .and_return mock("body", :body => "", :status => 200, :status_line => "OK")
      connection.request("/search", {:q => "query"}, :method => :post)
    end
  end

end
