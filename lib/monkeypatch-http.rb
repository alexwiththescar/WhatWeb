require 'net/protocol'
require 'uri'

# monkeypatched to return the real header block

module Net   #:nodoc:

  class HTTP < Protocol

    # Creates a new Net::HTTP object for the specified +address+.
    # This method does not open the TCP connection.
    def initialize(address, port = nil)
      @address = address
      @port    = (port || HTTP.default_port)
      @curr_http_version = HTTPVersion
      @seems_1_0_server = false
      @close_on_empty_response = false
      @socket  = nil
      @started = false
      @open_timeout = nil
      @read_timeout = 60
      @debug_output = nil
      @use_ssl = false
      @ssl_context = nil
      @raw = []
    end

    def raw
	@raw
    end

    def connect
      D "opening connection to #{conn_address()}..."
      s = timeout(@open_timeout) { TCPSocket.open(conn_address(), conn_port()) }
      D "opened"
      if use_ssl?
        unless @ssl_context.verify_mode
          warn "warning: peer certificate won't be verified in this SSL session"
          @ssl_context.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        s = OpenSSL::SSL::SSLSocket.new(s, @ssl_context)
        s.sync_close = true
      end
      @socket = BufferedIO.new(s)
      @socket.read_timeout = @read_timeout
      @socket.debug_output = @debug_output
      if use_ssl?
        if proxy?
          @socket.writeline sprintf('CONNECT %s:%s HTTP/%s',
                                    @address, @port, HTTPVersion)
          @socket.writeline "Host: #{@address}:#{@port}"
          if proxy_user
            credential = ["#{proxy_user}:#{proxy_pass}"].pack('m')
            credential.delete!("\r\n")
            @socket.writeline "Proxy-Authorization: Basic #{credential}"
          end
          @socket.writeline ''
          x,raw=HTTPResponse.read_new(@socket)
	  @raw << raw
	  res=x.value
        end
        s.connect
        if @ssl_context.verify_mode != OpenSSL::SSL::VERIFY_NONE
          s.post_connection_check(@address)
        end
      end
      on_connect
    end
    private :connect

 
    def request(req, body = nil, &block)  # :yield: +response+
      unless started?
        start {
          req['connection'] ||= 'close'
          return request(req, body, &block)
        }
      end
      if proxy_user()
        unless use_ssl?
          req.proxy_basic_auth proxy_user(), proxy_pass()
        end
      end

      req.set_body_internal body
      begin
        begin_transport req
        req.exec @socket, @curr_http_version, edit_path(req.path)
        begin
          res,y = HTTPResponse.read_new(@socket)
	  @raw << y
	  res
        end while res.kind_of?(HTTPContinue)
        res.reading_body(@socket, req.response_body_permitted?) {
          yield res if block_given?
        }
        end_transport req, res
      rescue => exception
        D "Conn close because of error #{exception}"
        @socket.close unless @socket.closed?
        raise exception
      end

      res
    end
end

  


  class HTTPResponse   # reopen

    class << HTTPResponse

      def read_new(sock)   #:nodoc: internal use only
	@rawlines=[]
        httpv, code, msg = read_status_line(sock)
        res = response_class(code).new(httpv, code, msg)
        each_response_header(sock) do |k,v|
          res.add_field k, v
        end
#	pp @rawlines
	real = @rawlines
        [res,real]
      end

      private


      def read_status_line(sock)
        str = sock.readline
	@rawlines << str
        m = /\AHTTP(?:\/(\d+\.\d+))?\s+(\d\d\d)\s*(.*)\z/in.match(str) or
          raise HTTPBadResponse, "wrong status line: #{str.dump}"
        m.captures
      end


      def each_response_header(sock)

        while true
          line = sock.readuntil("\n", true)
# headers are interpreted here
	  @rawlines << line unless line.nil?
	  line.sub!(/\s+\z/, '')
          break if line.empty?
          m = /\A([^:]+):\s*/.match(line) or
              raise HTTPBadResponse, 'wrong header line format'
          yield m[1], m.post_match
        end
      end
    end

    # next is to fix bug in RDoc, where the private inside class << self
    # spills out.
    public 

    include HTTPHeader

    def initialize(httpv, code, msg)   #:nodoc: internal use only
      @http_version = httpv
      @code         = code
      @message      = msg
      initialize_http_header nil
      @body = nil
      @read = false
      @realresponse=[]
    end
  

  end

end   # module Net
