require 'spec_helper'

module ApiNavigator
  describe EntryPoint do
    describe 'default' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org'
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          expect(entry_point.connection.url_prefix.to_s).to be == 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default headers' do
          expect(entry_point.headers['Content-Type']).to be == 'application/hal+json'
          expect(entry_point.headers['Accept']).to be == 'application/hal+json,application/json'
        end

        it 'can update headers after a connection has been constructed' do
          expect(entry_point.connection).to be_kind_of(Faraday::Connection)
          entry_point.headers.update('Content-Type' => 'application/foobar')
          expect(entry_point.headers['Content-Type']).to be == 'application/foobar'
        end

        it 'can insert additional middleware after a connection has been constructed' do
          expect(entry_point.connection).to be_kind_of(Faraday::Connection)
          entry_point.connection.use :instrumentation
          handlers = entry_point.connection.builder.handlers
          expect(handlers).to include FaradayMiddleware::Instrumentation
        end

        it 'creates a Faraday connection with the default block' do
          handlers = entry_point.connection.builder.handlers

          expect(handlers).to include Faraday::Response::RaiseError
          expect(handlers).to include FaradayMiddleware::FollowRedirects
          expect(handlers).to include FaradayMiddleware::EncodeHalJson
          expect(handlers).to include FaradayMiddleware::ParseHalJson
          expect(handlers).to include Faraday::Adapter::NetHttp

          expect(entry_point.connection.options.params_encoder).to be == Faraday::FlatParamsEncoder
        end

        it 'raises a  ConnectionAlreadyInitializedError if attempting to modify headers' do
          expect(entry_point.connection).to be_kind_of Faraday::Connection
          expect{ entry_point.headers = {} }.to raise_error ConnectionAlreadyInitializedError
        end

        it 'raises a  ConnectionAlreadyInitializedError if attempting to modify the faraday block' do
          expect(entry_point.connection).to be_kind_of Faraday::Connection
          expect{ entry_point.connection {} }.to raise_error ConnectionAlreadyInitializedError
        end
      end

      describe 'initialize' do
        it 'sets a Link with the entry point url' do
          expect(entry_point._url).to be == 'http://my.api.org'
        end
      end
    end

    describe 'faraday_options' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.faraday_options = { proxy: 'http://my.proxy:8080' }
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          expect(entry_point.connection.url_prefix.to_s).to be == 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default headers' do
          expect(entry_point.headers['Content-Type']).to be == 'application/hal+json'
          expect(entry_point.headers['Accept']).to be == 'application/hal+json,application/json'
        end

        it 'creates a Faraday connection with options' do
          expect(entry_point.connection.proxy).to be_kind_of Faraday::ProxyOptions
          expect(entry_point.connection.proxy.uri.to_s).to be == 'http://my.proxy:8080'
        end
      end
    end

    describe 'options' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.connection(proxy: 'http://my.proxy:8080')
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          expect(entry_point.connection.url_prefix.to_s).to be == 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default headers' do
          expect(entry_point.headers['Content-Type']).to be == 'application/hal+json'
          expect(entry_point.headers['Accept']).to be == 'application/hal+json,application/json'
        end

        it 'creates a Faraday connection with options' do
          expect(entry_point.connection.proxy).to be_kind_of Faraday::ProxyOptions
          expect(entry_point.connection.proxy.uri.to_s).to be == 'http://my.proxy:8080'
        end
      end
    end

    describe 'custom' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.connection(default: false) do |conn|
            conn.request :json
            conn.response :json, content_type: /\bjson$/
            conn.adapter :net_http
          end

          entry_point.headers = {
            'Content-Type' => 'application/foobar',
            'Accept' => 'application/foobar'
          }
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the entry point url' do
          expect(entry_point.connection.url_prefix.to_s).to be == 'http://my.api.org/'
        end

        it 'creates a Faraday connection with non-default headers' do
          expect(entry_point.headers['Content-Type']).to be == 'application/foobar'
          expect(entry_point.headers['Accept']).to be == 'application/foobar'
        end

        it 'creates a Faraday connection with the default block' do
          handlers = entry_point.connection.builder.handlers
          # TODO - we are below not included?
          # expect(handlers).to include Faraday::Response::RaiseError
          # expect(handlers).to include FaradayMiddleware::FollowRedirects
          expect(handlers).to include FaradayMiddleware::EncodeJson
          expect(handlers).to include FaradayMiddleware::ParseJson
          expect(handlers).to include Faraday::Adapter::NetHttp
        end
      end
    end

    describe 'inherited' do
      let(:entry_point) do
        EntryPoint.new 'http://my.api.org' do |entry_point|
          entry_point.connection do |conn|
            conn.use Faraday::Request::OAuth
          end
          entry_point.headers['Access-Token'] = 'token'
        end
      end

      describe 'connection' do
        it 'creates a Faraday connection with the default and additional headers' do
          expect(entry_point.headers['Content-Type']).to be == 'application/hal+json'
          expect(entry_point.headers['Accept']).to be == 'application/hal+json,application/json'
          expect(entry_point.headers['Access-Token']).to be == 'token'
        end

        it 'creates a Faraday connection with the entry point url' do
          expect(entry_point.connection.url_prefix.to_s).to be == 'http://my.api.org/'
        end

        it 'creates a Faraday connection with the default block plus any additional handlers' do
          handlers = entry_point.connection.builder.handlers

          expect(handlers).to include Faraday::Request::OAuth
          expect(handlers).to include Faraday::Response::RaiseError
          expect(handlers).to include FaradayMiddleware::FollowRedirects
          expect(handlers).to include FaradayMiddleware::EncodeHalJson
          expect(handlers).to include FaradayMiddleware::ParseHalJson
          expect(handlers).to include Faraday::Adapter::NetHttp

          expect(entry_point.connection.options.params_encoder).to be == Faraday::FlatParamsEncoder
        end
      end
    end
  end
end
