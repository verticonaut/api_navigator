require 'api_navigator/collection'
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

  # @param url [String] The base url
  # @param &block [type] Block for configuring the navitgator
  # 
  # @return [ApiNavigator::EntryPoint] Then entrypoint hoocking it all up
  def self.new(url, &block)
    ApiNavigator::EntryPoint.new(url, &block)
  end

end
