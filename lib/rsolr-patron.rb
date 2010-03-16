require "rsolr"
require "patron"

module RSolr::Patron

  module Connectable

    def connect *args
      if args.first == :patron
        args.shift
        RSolr::Client.new(RSolr::Patron::Connection.new(*args))
      else
        super
      end
    end

  end

  RSolr.extend Connectable

  # Can be instantiated with the :url option (as per RSolr's default implementation)
  # as well as any options that exist as attr_writers on a Patron::Session instance, e.g.
  #
  #   RSolr::Client.connect :patron,
  #     :base_url => "http://localhost:8983", :timeout => 300, :headers => {"Connection" => "close"}
  #
  class Connection

    include RSolr::Connection::Requestable

    protected

    def connection
      unless @connection
        @connection = ::Patron::Session.new
        @connection.base_url = base_url # host/port, no path
        @connection.proxy = opts[:proxy]
        opts.each do |key, value|
          next if [:url, :proxy].include? key
          if @connection.respond_to?("#{key}=".to_sym)
            @connection.send("#{key}=".to_sym, value)
          end
        end
      end
      @connection
    end

    def get(url)
      response = connection.get url, {"Expect" => ""}

      [response.body, response.status, response.status_line]
    end

    def post(url, data, headers={})
      response = connection.post url, data, headers.merge("Expect" => "")
      [response.body, response.status, response.status_line]
    end

  end

end
