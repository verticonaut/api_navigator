module ApiNavigator
  module Resources
    class CollectionResource < Resource

      # Public: Returns the embedded resource of the Resource as a
      # ResourceCollection.
      attr_reader :_collection

      # Public: Initializes a Resource.
      #
      # representation - The hash with the HAL representation of the Resource.
      # entry_point    - The EntryPoint object to inject the configutation.
      def initialize(representation, entry_point, response = nil)
        super
        
        collection_data = representation.fetch('data')
        @_collection    = collection_data.map do |resource| Resources::MemberResource.new(resource, entry_point) end
      end

      # Internal: Delegate the method to various elements of the resource.
      #
      # This allows `api.posts` instead of `api.links.posts.resource`
      # as well as api.posts(id: 1) assuming posts is a link.
      def method_missing(method, *args, &block)
        begin
          @_collection.send(method, *args, &block)
        rescue NoMethodError
          super
        end
      end

      # Internal: Accessory method to allow the resource respond to
      # methods that will hit method_missing.
      def respond_to_missing?(method, include_private = false)
        @_collection.respond_to?(method, include_private) ||
          super
      end

    end # class CollectionResource < Resource
  end
end