$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'mongrel'

module MongrelProxy
end

require 'mongrel_proxy/version'
require 'mongrel_proxy/proxy_plugin'
require 'mongrel_proxy/command'
