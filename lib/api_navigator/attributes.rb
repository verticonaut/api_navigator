module ApiNavigator
  # Public: A wrapper class to easily acces the attributes in a Resource.
  #
  # Examples
  #
  #   resource.attributes['title']
  #   resource.attributes.title
  #
  class Attributes < CollectionHash
    # Public: Initializes the Attributes of a Resource.
    #
    # representation - The hash with the HAL representation of the Resource.
    #
    def initialize(attributes_hash)
      raise ArgumentError, "argument nust be a Hash, is #{attributes_hash.class}" unless attributes_hash.kind_of? Hash
      super
    end

  end
end
