module ApiNavigator
  module Resources
    class MemberResource < Resource

      # Public: Returns the attributes of the Resource as Attributes.
      attr_reader :_attributes

      # Public: Initializes a Resource.
      #
      # representation - The hash with the HAL representation of the Resource.
      # entry_point    - The EntryPoint object to inject the configutation.
      def initialize(representation, entry_point, response = nil)
        super

        @_attributes = Attributes.new(representation.fetch('data'))
      end

      # Internal: Delegate the method to various elements of the resource.
      #
      # This allows `api.posts` instead of `api.links.posts.resource`
      # as well as api.posts(id: 1) assuming posts is a link.
      def method_missing(method, *args, &block)
        if @_attributes.include?(method.to_s)
          @_attributes[method.to_s] 
        else
          super
        end
      end

      # Internal: Accessory method to allow the resource respond to
      # methods that will hit method_missing.
      def respond_to_missing?(method, include_private = false)
        @_attributes.include?(method.to_s) ||
          super
      end

    end # class MemberResource < Resource
  end
end
