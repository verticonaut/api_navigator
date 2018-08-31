require 'api_navigator/collection_hash'
require 'api_navigator/link'
require 'api_navigator/attributes'
require 'api_navigator/curie'
require 'api_navigator/entry_point'
require 'api_navigator/link_collection'
require 'api_navigator/resource'
require 'api_navigator/resources/member_resource'
require 'api_navigator/resources/collection_resource'
require 'api_navigator/version'

# 
# @author [martinschweizer]
# 
module ApiNavigator

  ClientResourceClasses = {}

  # @param url [String] The base url
  # @param &block [type] Block for configuring the navitgator
  # 
  # @return [ApiNavigator::EntryPoint] Then entrypoint hoocking it all up
  def self.new(url, client_identifier=nil, &block)
    ApiNavigator::EntryPoint.new(url, client_identifier, &block)
  end

  class << self
    def register(client_identifier)
      raise "Already registered client_identifier: #{client_identifier}" if ClientResourceClasses.include?(client_identifier)

      ClientResourceClasses[client_identifier] = {}
    end

    def register_resource(identifier, resource_class, client_identifier:)
      ClientResourceClasses.fetch(client_identifier)[identifier] = resource_class
    end

    def resource_class(identifier, client_identifier:)
      result = ClientResourceClasses.fetch(client_identifier, {}).fetch(identifier, nil)

      result.nil? ? ApiNavigator::Resources::MemberResource : result
    end
  end

end
