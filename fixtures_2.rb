require 'json'

module Spinach
  module Fixtures2

    def root_response
      '{
          "_links": {
              "self": { "href": "/" },
              "posts": { "href": "/posts" },
              "search": { "href": "/search{?q}", "templated": true },
              "tagged": { "href": "/search{?tags*}", "templated": true },
              "api:authors": { "href": "/authors" },
              "next": { "href": "/page2" }
          }
      }'
    end

    # collection resource 
    def posts_response
      response = {
        data: [
          {
            data: {
              title: 'Book 1',
              body: 'Book 1 Body',
              year: 1999,
              publisher: {
                data: {
                  name: 'Manning Publisher',
                },
                _links: {
                  self: {
                    href: "http://localhost:3000/sample/publisher/1",
                  }
                },
                _meta: { type: "publisher" }                              
              },
            },
            _links: {
              self: {
                href: "http://localhost:3000/sample/books/1",
              },
              authors: {
                href: "http://localhost:3000/sample/book/1/authors",
              },
              publisher: {
                href: "http://localhost:3000/sample/book/1/publisher",
              },
            },
            _meta: { type: "book" }                              
          },
          {
            data: {
              title: 'Book 2',
              body: 'Book 2 Body',
              year: 1999,
              publisher: {
                data: {
                  name: 'PragBook Publisher',
                },
                _links: {
                  self: {
                    href: "http://localhost:3000/sample/publisher/2",
                  }
                },
                _meta: { type: "publisher" }                              
              },
            },
            _links: {
              self: {
                href: "http://localhost:3000/sample/books/2",
              },
              authors: {
                href: "http://localhost:3000/sample/book/2/authors",
              },
              publisher: {
                href: "http://localhost:3000/sample/book/2/publisher",
              },
            },
            _meta: { type: "book" }                              
          },
        ],
        _links: {
          self: {
            href: "http://localhost:3000/sample/books",
          }
        },
        _meta: { total_number_of: 22 }
      }

      response
    end

    # singular resource
    def post_response
      response = {
        data: {
          title: 'Book 1',
          body: 'Book 1 Body',
          year: 1999,
          publisher: {
            data: {
              name: 'Manning Publisher',
            },
            _links: {
              self: {
                href: "http://localhost:3000/sample/publisher/1",
              }
            },
            _meta: { type: "book" }                              
          },
        },
        _links: {
          self: {
            href: "http://localhost:3000/sample/books/1",
          },
          authors: {
            href: "http://localhost:3000/sample/book/1/authors",
          },
          publisher: {
            href: "http://localhost:3000/sample/book/1/publisher",
          },
        },
        _meta: { type: "book" }                              
      }

      response
    end

  end
end

__END__
# singular resource - nested
{
  data: {
    attr1: 'ffg1',
    attr2: 'ffg2',
    attr3: 'ffg2',
    attr4: 'ffg4',
    publisher: {
      data: { name: 'Publisher 1'},
      _meta: {
        type: 'publisher'
      }
    },
    authors: [
      {
        data: {
          name: 'Author1'
        },
        _links: {
          authors: {
            rel: 'self',
            href: "http:…/author/1"
          }
        },
        _meta: {        
          type: 'author'
        }
      },
      {
        data: {
          name: 'Author2'
        },
        _links: {
          self: {
            href: "http:…/author/1"
          }
          authors: {
            href: "http:…/authors"
          }
          books: {
            href: "http:…/author1/books"
          }
        },
        _meta: {        
          type: 'author'
        }
      }
    ]
  },
  _links: {
    authors: {
      href: "http:…/authors"
    }
  },
  _meta: {
    type: 'resource_type'
  }
}

# singular resource - nested ~/authors.json?…
{
  data: [
    {
      data: {
        name: 'Author1'
      },
      _links: {
        authors: {
          rel: 'self',
          href: "http:…/author/1"
        }
      },
      _meta: {        
        type: 'author'
      }
    },
    {
      data: {
        name: 'Author2'
      },
      _links: {
        authors: {
          rel: 'self',
          href: "http:…/author/1"
        }
      },
      _meta: {        
        type: 'author'
      }
    }
  ]
  _links: {
    self: {
      name: 'Authors',
      href: "http:…/authors"
    }
  },
  _meta: {
    type: 'resource_type'
  }
}



# js-compact
{
  attr1: 'ffg1',
  attr2: 'ffg2',
  attr3: 'ffg2',
  attr4: 'ffg4',
  publisher: { name: 'Publisher 1'},
  authors: [
    { name: 'Author1' },
    { name: 'Author2' }
  ]
}


# articles?_include="{authors: 'person'},publisher"