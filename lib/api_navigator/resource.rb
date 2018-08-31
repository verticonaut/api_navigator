require 'forwardable'
require 'pry'

module ApiNavigator
  # Public: Exception that is raised when passing in invalid representation data
  # for the resource.
  class InvalidRepresentationError < ArgumentError
    attr_reader :representation

    def initialize(error_description, representation)
      super(error_description)
      @representation = representation
    end
  end

  # Public: Represents a resource from your API. Its responsability is to
  # ease the way you access its  attributes, links and embedded resources.
  class Resource
    extend Forwardable

    # Public: Returns the links of the Resource as a LinkCollection.
    attr_reader :_links

    # Public: Returns the response object for the HTTP request that created this
    # resource, if one exists.
    attr_reader :_response

    # Public: Delegate all HTTP methods (get, post, put, delete, options and
    # head) to its self link.
    def_delegators :_self_link, :_get, :_post, :_put, :_delete, :_options, :_head

    def self.from_representation(representation, entry_point, response = nil)
      case (representation || {}).fetch('data', "_no_data")
        when Hash
          Resources::MemberResource.from_representation(representation, entry_point, response)
        when Array
          Resources::CollectionResource.new(representation, entry_point, response)
        when "_no_data"
          new(representation, entry_point, response)
        else
          raise InvalidRepresentationError.new("Representation has not valid data element - must be Hash or List", representation)
      end
    end

    # Public: Initializes a Resource.
    #
    # representation - The hash with the HAL representation of the Resource.
    # entry_point    - The EntryPoint object to inject the configutation.
    def initialize(representation, entry_point, response = nil)
      representation = validate(representation)
      links          = representation['_links'] || {}
      @_links        = LinkCollection.new(links, links['curies'], entry_point)
      @_entry_point  = entry_point
      @_response     = response
    end

    def inspect
      "#<#{self.class.name} self_link:#{_self_link.inspect} attributes:#{@_attributes.inspect}  collection:#{@_collection.inspect}>"
    end

    def _success?
      _response && _response.success?
    end

    def _status
      _response && _response.status
    end

    def [](name)
      send(name) if respond_to?(name)
    end

    def fetch(key, *args)
      return self[key] if respond_to?(key)

      if args.any?
        args.first
      elsif block_given?
        yield key
      else
        raise KeyError
      end
    end

    private

    # Internal: Ensures the received representation is a valid Hash-lookalike.
    def validate(representation)
      return {} unless representation

      if representation.respond_to?(:to_hash)
        representation.to_hash.dup
      else
        raise InvalidRepresentationError.new(
          "Invalid representation for resource (got #{representation.class}, expected Hash). " \
          "Is your web server returning JSON HAL data with a 'Content-Type: application/hal+json' header?",
          representation
        )
      end
    end

    # Internal: Returns the self Link of the Resource. Used to handle the HTTP
    # methods.
    def _self_link
      @_links['self']
    end

    # Internal: Delegate the method to various elements of the resource.
    #
    # This allows `api.posts` instead of `api.links.posts.resource`
    # as well as api.posts(id: 1) assuming posts is a link.
    def method_missing(method, *args, &block)
      # if _links.respond_to?(method, include_private)
        if args.any? && args.first.is_a?(Hash)
          return _links.send(method, [], &block)._expand(*args)
        else
          return _links.send(method, *args, &block)
        end
      # end

      super
    end

    # Internal: Accessory method to allow the resource respond to
    # methods that will hit method_missing.
    def respond_to_missing?(method, include_private = false)
      _links.respond_to?(method, include_private)
    end
  end
end
