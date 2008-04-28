require 'optparse'

module MongrelProxy
  class Command

    attr_reader :interface, :port, :remote_host, :remote_port, :cwd, :log_file, :pid_file

    def initialize(args = [])
      # Set up some default arguments.
      @interface   = "127.0.0.1"
      @port        = 4037
      @remote_host = "localhost"
      @remote_port = 80
      @daemonize   = false
      @cwd         = "/"
      @log_file    = File.join(Dir.pwd, "mongrel_proxy.log")
      @pid_file    = File.join(Dir.pwd, "mongrel_proxy.pid")

      parse args
    end

    def daemonize?
      @daemonize
    end

    def run
      configurator = Mongrel::Configurator.new({
        :host        => interface,
        :port        => port,
        :remote_host => remote_host,
        :remote_port => remote_port,
        :cwd         => cwd,
        :log_file    => log_file,
        :pid_file    => pid_file
      })

      configurator.daemonize if daemonize?

      listener = configurator.listener do
        uri "/", :handler => plugin("/handlers/mongrelproxy::proxyplugin", :remote_host => defaults[:remote_host], :remote_port => defaults[:remote_port])
      end

      configurator.setup_signals
      configurator.run
      configurator.join
    end

    def parse(args)
      OptionParser.new do |opts|
        opts.banner = "Usage: mongrel_proxy [options]"

        opts.on('-i', '--interface',   "Local IP to listening on  (default: #{interface})")   { |v| @interface   = v }
        opts.on('-p', '--local-port',  "Local port to listen on   (default: #{port})")        { |v| @port        = v }
        opts.on('-h', '--remote-host', "Remote host to connect to (default: #{remote_host})") { |v| @remote_host = v }
        opts.on('-r', '--remote-port', "Remote port to connect to (default: #{remote_port})") { |v| @remote_port = v }
        opts.on('-d', '--daemonize',   "Run in the background?    (default: #{daemonize?})")  { |v| @daemonize   = v }
        opts.on('-c', '--cwd',         "Working directory         (default: #{cwd})")         { |v| @cwd         = v }
        opts.on('-l', '--log-file',    "Log file                  (default: #{log_file})")    { |v| @log_file    = v }
        opts.on('-f', '--pid-file',    "pid file                  (default: #{pid_file})")    { |v| @pid_file    = v }

        opts.parse!(args)
      end
    end
  end
end
