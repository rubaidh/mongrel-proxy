module MongrelProxy
  class Command
    attr_accessor :args

    OPTIONS = {
      :host => "127.0.0.1",
      :port => 4037,
      :remote_host => "localhost",
      :remote_port => 80,
      :daemonize => false,
      :cwd => Dir.pwd,
      :log => File.join(Dir.pwd, "log/mongrel_proxy.log"),
      :pid => File.join(Dir.pwd, "tmp/pids/mongrel_proxy.pid")
    }

    def initialize(args = [])
      self.args = args
    end

    def run
      config = Mongrel::Configurator.new :host => OPTIONS[:host] do
        daemonize :cwd => OPTIONS[:cwd], :log_file => OPTIONS[:log], :pid_file => OPTIONS[:pid] if OPTIONS[:daemonize]

        log "Starting listener on http://#{OPTIONS[:host]}:#{OPTIONS[:port]}"
        listener :port => OPTIONS[:port] do
          uri "/", :handler => plugin("/handlers/mongrelproxy::proxyplugin", :remote_host => OPTIONS[:remote_host], :remote_port => OPTIONS[:remote_port])
        end

        trap("INT") { stop }
        run
      end

      config.join
    end
  end
end