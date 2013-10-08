module PuppetDbRestClient
  class Connection
    module Nodes
      def nodes(options=Mash.new)
        get(api_path('nodes')).map {|node|
          n = PuppetDbRestClient::Node.get_or_new(node)
          n.connection = self
          n
        }
      end

      def node(name)
        attributes = get(api_path("nodes/#{name}"))
        n = PuppetDbRestClient::Node.get_or_new(attributes)
        n.connection = self
        n
      end

      def node_facts(name)
        get(api_path("nodes/#{name}/facts")).map {|fact|
          PuppetDbRestClient::Fact.get_or_new(fact)
        }
      end

      def node_resources(name)
        get(api_path("nodes/#{name}/resources")).map {|resource|
          PuppetDbRestClient::Resource.get_or_new(resource)
        }
      end
    end
  end
end