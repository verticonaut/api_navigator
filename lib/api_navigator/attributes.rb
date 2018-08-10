module ApiNavigator
  # Public: A wrapper class to easily acces the attributes in a Resource.
  #
  # Examples
  #
  #   resource.attributes['title']
  #   resource.attributes.title
  #
  class Attributes < Collection
    # Public: Initializes the Attributes of a Resource.
    #
    # representation - The hash with the HAL representation of the Resource.
    #
    def initialize(attributes_hash)
      raise ArgumentError, "argument nust be a Hash, is #{attributes_hash.class}" unless attributes_hash.kind_of? Hash
      super
    end

    # Public: Provides method access to the collection values.
    #
    # It allows accessing a value as `collection.name` instead of
    # `collection['name']`
    #
    # Returns an Object.
    def method_missing(method_name, *_args, &_block)
      @collection.fetch(method_name.to_s) do
        raise "Could not find `#{method_name}` in #{self.class.name}"
      end
    end

    # Internal: Accessory method to allow the collection respond to the
    # methods that will hit method_missing.
    def respond_to_missing?(method_name, _include_private = false)
      @collection.include?(method_name.to_s)
    end

  end
end
