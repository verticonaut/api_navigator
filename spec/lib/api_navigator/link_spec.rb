require 'spec_helper'

module ApiNavigator
  describe Link do
    let(:entry_point) do
      EntryPoint.new('http://api.example.org/')
    end

    %w[type deprecation name profile title hreflang].each do |prop|
      describe prop do
        it 'returns the property value' do
          link = Link.new('key', { prop => 'value' }, entry_point)
          expect(link.send("_#{prop}")).to be == 'value'
        end

        it 'returns nil if the property is not present' do
          link = Link.new('key', {}, entry_point)
          expect(link.send("_#{prop}")).to be_nil
        end
      end
    end

    describe '_templated?' do
      it 'returns true if the link is templated' do
        link = Link.new('key', { 'templated' => true }, entry_point)

        expect(link._templated?).to be_truthy
      end

      it 'returns false if the link is not templated' do
        link = Link.new('key', {}, entry_point)

        expect(link._templated?).to be_falsey
      end
    end

    describe '_variables' do
      it 'returns a list of required variables' do
        link = Link.new('key', { 'href' => '/orders{?id,owner}', 'templated' => true }, entry_point)

        expect(link._variables).to match_array %w[id owner]
      end

      it 'returns an empty array for untemplated links' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        expect(link._variables).to be_empty
      end
    end

    context '_expand templated links' do
      describe 'required argument' do
        it 'builds a Link with the templated URI representation' do
          link = Link.new('key', { 'href' => '/orders/{id}', 'templated' => true }, entry_point)
          expect(link._expand(id: '1')._url).to be == '/orders/1'
        end

        it 'expands an uri template without variables' do
          link = Link.new('key', { 'href' => '/orders/{id}', 'templated' => true }, entry_point)
          expect(link._expand._url).to be == '/orders/'
          expect(link._url).to be == '/orders/'
        end
      end

      describe 'query string argument' do
        it 'builds a Link with the templated URI representation' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          expect(link._expand(id: '1')._url).to be == '/orders?id=1'
        end

        it 'expands an uri template without variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          expect(link._expand._url).to be == '/orders'
          expect(link._url).to be == '/orders'
        end

        it 'does not expand unknown variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          expect(link._expand(unknown: '1')._url).to be == '/orders'
        end

        it 'only expands known variables' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)
          expect(link._expand(unknown: '1', id: '2')._url).to be == '/orders?id=2'
        end

        it 'only expands templated links' do
          link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => false }, entry_point)
          expect(link._expand(id: '1')._url).to be == '/orders{?id}'
        end
      end
    end

    describe '_url' do
      it 'expands an uri template without variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point)

        expect(link._url).to be == '/orders'
      end

      it 'expands an uri template with variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, id: 1)

        expect(link._url).to be == '/orders?id=1'
      end

      it 'does not expand an uri template with unknown variables' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, unknown: 1)

        expect(link._url).to be == '/orders'
      end

      it 'only expands known variables in a uri template' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, unknown: 1, id: 2)

        expect(link._url).to be == '/orders?id=2'
      end

      it 'returns the link when no uri template' do
        link = Link.new('key', { 'href' => '/orders' }, entry_point)

        expect(link._url).to be == '/orders'
      end

      it 'aliases to_s to _url' do
        link = Link.new('key', { 'href' => '/orders{?id}', 'templated' => true }, entry_point, id: 1)

        expect(link.to_s).to be == '/orders?id=1'
      end
    end

    describe '_resource' do
      it 'builds a resource with the link href representation' do
        expect(Resource).to receive(:new)

        link = Link.new('key', { 'href' => '/' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/') { [200, {}, nil] }
        end

        link._resource
      end
    end


    describe 'get' do
      it 'sends a GET request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._get).to be_kind_of Resource
      end

      it 'raises exceptions by default' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.get('http://api.example.org/productions/1') { [400, {}, nil] }
        end

        expect { link._get }.to raise_error Faraday::ClientError
      end
    end

    describe '_options' do
      it 'sends a OPTIONS request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.options('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._options).to be_kind_of Resource
      end
    end

    describe '_head' do
      it 'sends a HEAD request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.head('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._head).to be_kind_of Resource
      end
    end

    describe '_delete' do
      it 'sends a DELETE request with the link url' do
        link = Link.new('key', { 'href' => '/productions/1' }, entry_point)

        stub_request(entry_point.connection) do |stub|
          stub.delete('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._delete).to be_kind_of Resource
      end
    end

    describe '_post' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a POST request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._post('foo' => 'bar')).to be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.post('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._post).to be_kind_of Resource
      end
    end

    describe '_put' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a PUT request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.put('http://api.example.org/productions/1', '{"foo":"bar"}') { [200, {}, nil] }
        end

        expect(link._put('foo' => 'bar')).to be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.put('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._put).to be_kind_of Resource
      end
    end

    describe '_patch' do
      let(:link) { Link.new('key', { 'href' => '/productions/1' }, entry_point) }

      it 'sends a PATCH request with the link url and params' do
        stub_request(entry_point.connection) do |stub|
          stub.patch('http://api.example.org/productions/1', '{"foo":"bar"}') { [200, {}, nil] }
        end

        expect(link._patch('foo' => 'bar')).to be_kind_of Resource
      end

      it 'defaults params to an empty hash' do
        stub_request(entry_point.connection) do |stub|
          stub.patch('http://api.example.org/productions/1') { [200, {}, nil] }
        end

        expect(link._patch).to be_kind_of Resource
      end
    end

    describe 'inspect' do
      it 'outputs a custom-friendly output' do
        link = Link.new('key', { 'href' => '/productions/1' }, 'foo')

        expect(link.inspect).to include 'Link'
        expect(link.inspect).to include '"href"=>"/productions/1"'
      end
    end

    describe 'method_missing' do
      describe 'delegation' do
        it 'delegates when link key matches' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { 'data' => [{ 'id' => 1 }] }] }
          end
          binding.pry
          excpet(resource.orders.first.id).to be == 1
        end

        it 'can handle false values in the response' do
          resource = Resource.new({ '_links' => { 'orders' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { 'any' => false }] }
          end

          resource.orders.any.must_equal false
        end

        it "doesn't delegate when link key doesn't match" do
          resource = Resource.new({ '_links' => { 'foos' => { 'href' => '/orders' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/orders') { [200, {}, { 'data' => [{ 'id' => 1 }] }] }
          end

          resource.foos._embedded.orders.first.id.must_equal 1
          resource.foos.first.must_equal nil
        end

        it 'backtracks when navigating links' do
          resource = Resource.new({ '_links' => { 'next' => { 'href' => '/page2' } } }, entry_point)

          stub_request(entry_point.connection) do |stub|
            stub.get('http://api.example.org/page2') { [200, {}, { '_links' => { 'next' => { 'href' => 'http://api.example.org/page3' } } }] }
          end

          resource.next._links.next._url.must_equal 'http://api.example.org/page3'
        end
      end

      describe 'resource' do
        before do
          stub_request(entry_point.connection) do |stub|
            stub.get('http://myapi.org/orders') { [200, {}, '{"resource": "This is the resource"}'] }
          end

          Resource.stubs(:new).returns(resource)
        end

        let(:resource) { mock('Resource') }
        let(:link) { Link.new('orders', { 'href' => 'http://myapi.org/orders' }, entry_point) }

        it 'delegates unkown methods to the resource' do
          Resource.expects(:new).returns(resource).at_least_once
          resource.expects(:unknown_method)

          link.unknown_method
        end

        it 'raises an error when the method does not exist in the resource' do
          -> { link.this_method_does_not_exist }.must_raise NoMethodError
        end

        it 'responds to missing methods' do
          resource.expects(:respond_to?).with('orders').returns(false)
          resource.expects(:respond_to?).with('embedded').returns(true)
          link.respond_to?(:embedded).must_equal true
        end

        it 'does not delegate to_ary to resource' do
          resource.expects(:to_ary).never
          [[link, link]].flatten.must_equal [link, link]
        end
      end
    end
  end
end
