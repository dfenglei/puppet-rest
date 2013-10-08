require 'faraday'
require 'multi_json'

require_relative 'puppetdb-rest/core_ext/mash'
require_relative 'puppetdb-rest/core_ext/hash'
require_relative 'puppetdb-rest/core_ext/array'
require_relative 'puppetdb-rest/core_ext/enumerable'

require_relative 'puppetdb-rest/version'
require_relative 'puppetdb-rest/config'
require_relative 'puppetdb-rest/error'

require_relative 'puppetdb-rest/identity_map'
require_relative 'puppetdb-rest/entities/base'
require_relative 'puppetdb-rest/entities/node'
require_relative 'puppetdb-rest/entities/fact'
require_relative 'puppetdb-rest/entities/resource'

require_relative 'puppetdb-rest/request'
require_relative 'puppetdb-rest/response/client_error'
require_relative 'puppetdb-rest/response/parse_json'
require_relative 'puppetdb-rest/connection/nodes'
require_relative 'puppetdb-rest/connection/fact-names'
require_relative 'puppetdb-rest/connection/facts'
require_relative 'puppetdb-rest/connection/resources'
require_relative 'puppetdb-rest/connection'

module PuppetDbRestClient
  extend PuppetDbRestClient::Config

  class << self
    # Convenience alias for PuppetDbRestClient::Connection.new
    #
    # return [PuppetDbRestClient::Connection]
    def new(options=Mash.new)
      PuppetDbRestClient::Connection.new(options)
    end

    # Delegate methods to PuppetDbRestClient::Connection
    def method_missing(method, *args, &block)
      return super unless new.respond_to?(method)
      new.send(method, *args, &block)
    end

    def respond_to?(method, include_private=false)
      new.respond_to?(method, include_private) || super(method, include_private)
    end

    def read_key_file(path)
      key_file_path = File.expand_path(path)

      begin
        raw_key = File.read(key_file_path).strip
      rescue SystemCallError, IOError => e
        raise IOError, "Unable to read #{key_file_path}"
      end

      begin_rsa = '-----BEGIN RSA PRIVATE KEY-----'
      end_rsa   = '-----END RSA PRIVATE KEY-----'

      unless (raw_key =~ /\A#{begin_rsa}$/) && (raw_key =~ /^#{end_rsa}\Z/)
        msg = "The file #{key_file_path} is not a properly formatted private key.\n"
        msg << "It must contain '#{begin_rsa}' and '#{end_rsa}'"
        raise ArgumentError, msg
      end
      return OpenSSL::PKey::RSA.new(raw_key)
    end
  end
end