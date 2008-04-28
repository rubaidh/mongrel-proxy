module MongrelProxy
  class ProxyPlugin < GemPlugin::Plugin "/handlers"
    include Mongrel::HttpHandlerPlugin

    # Logs a simple message to STDERR (or the mongrel log if in daemon mode).
    def log(msg)
      lines = msg.split(/\n/)

      STDERR.puts "** #{lines.first}"
      lines[1..-1].each do |line|
        STDERR.puts"   #{line}"
      end
    end

    def process(request, response)
      Net::HTTP.start(options[:remote_host], options[:remote_port]) do |http|

        request_uri = request.params[Mongrel::Const::REQUEST_URI]
        request_method = request.params[Mongrel::Const::REQUEST_METHOD]

        log "#{request_method}ing #{request_uri}..."


        params = {}
        request.params.each do |key, val|
          params[capitalify(key.gsub(/HTTP_/, ''))] = val if !key.grep(/^HTTP_/).empty?
        end

        proxy_response = case request_method
        when "GET"
          http.get request_uri, params
        when "HEAD"
          http.head request_uri, params
        when "POST"
          http.post request_uri, request.body.read, params
        end

        response.start(proxy_response.code, false, proxy_response.message) do |head, out|
          proxy_response.each do |key, value|
            head[capitalify(key)] = value.gsub(remote_uri_base, local_uri_base(request))
          end
          out << proxy_response.body
        end
      end
    end

    private
    def capitalify(str)
      str.split(/[-_]/).map { |s| s.capitalize }.join('-')
    end

    def remote_uri_base
      "http://#{options[:remote_host]}#{options[:remote_port] == 80 ? "" : ":#{options[:remote_port]}"}"
    end

    def local_uri_base(request)
      "http://#{request.params["HTTP_HOST"]}"
    end
  end
end
