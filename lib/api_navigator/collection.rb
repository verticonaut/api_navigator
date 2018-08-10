module ApiNavigator
  # Public: A helper class to wrap a collection of elements and provide
  # Hash-like access or via a method call.
  #
  # Examples
  #
  #  collection['value']
  #  collection.value
  #
  class Collection
    include Enumerable

    # Public: Initializes the Collection.
    #
    # collection - The Hash to be wrapped.
    def initialize(collection)
      @collection = collection
    end

    # Public: Each implementation to allow the class to use the Enumerable
    # benefits.
    #
    # Returns an Enumerator.
    def each(&block)
      @collection.each(&block)
    end

    # Public: Checks if this collection includes a given key.
    #
    # key - A String or Symbol to check for existance.
    #
    # Returns True/False.
    def include?(key)
      @collection.include?(key)
    end

    # Public: Returns a value from the collection for the given key.
    # If the key can't be found, there are several options:
    # With no other arguments, it will raise an KeyError exception;
    # if default is given, then that will be returned;
    #
    # key - A String or Symbol of the value to get from the collection.
    # default - An optional value to be returned if the key is not found.
    #
    # Returns an Object.
    def fetch(*args)
      @collection.fetch(*args)
    end

    # Public: Provides Hash-like access to the collection.
    #
    # name - A String or Symbol of the value to get from the collection.
    #
    # Returns an Object.
    def [](name)
      @collection[name.to_s]
    end

    # Public: Returns the wrapped collection as a Hash.
    #
    # Returns a Hash.
    def to_h
      @collection.to_hash
    end
    alias to_hash to_h

    def to_s
      to_hash
    end

  end
end
