require 'json'

module Fixtures
  module Requests

    # Fixtures::Requests.root_response
    def root_response(format: :json)
      response = {
        _links: {
          self:          { "href": "/" },
          books:         { "href": "/books" },
          filter: {
            href: "/productions/1?categories={filter}",
            templated: true,
          },
          two_links:     [
            { "href": "/any_resource/1" },
            { "href": "/any_resource/2" },
          ],
          'api:authors': { "href": "/api/authors" },
          curies: [
            {
              name:      "api",
              href:      "/docs/resources/{rel}",
              templated: true,
            }
          ],
          null_link: nil,
        }
      }

      format == :json ? response.to_json : response
    end

    def books_response(format = :json)
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

      format == :json ? response.to_json : response
    end

    # singular resource
    def book_response(format = :json)
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
          authors: {
            data: [
              # author1,
              # author2
            ],
            _links: {},
            _meta: {}
          }
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

      format == :json ? response.to_json : response
    end

    module_function :root_response, :books_response, :book_response

  end
end
