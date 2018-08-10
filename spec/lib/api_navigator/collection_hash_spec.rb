require 'spec_helper'

module ApiNavigator
  describe CollectionHash do
    let(:representation) do
      JSON.parse(Fixtures::Requests.book_response)
    end

    let(:collection) do
      CollectionHash.new(representation)
    end

    it 'exposes the collection as methods' do
      expect(collection.data['title']).to be == 'Book 1'
      expect(collection.data).to be_kind_of Hash
    end

    it 'exposes collection as a hash' do
      expect(collection['data']['body']).to be == 'Book 1 Body'
      expect(collection['data']).to be_kind_of Hash
    end

    it 'correctly responds to methods' do
      expect(collection).to respond_to :data
    end

    it 'acts as enumerable' do
      names = collection.map do |name, _value|
        name
      end
      expect(names).to include(*%w[data _links _meta])
    end

    describe '#to_hash' do
      it 'returns the wrapped collection as a hash' do
        expect(collection.to_hash).to be_kind_of Hash
      end
    end

    describe 'include?' do
      it 'returns true for keys that exist' do
        expect(collection.include?('_links')).to be_truthy
      end

      it 'returns false for missing keys' do
        expect(collection.include?('missing key')).to be_falsey
      end
    end

    describe '#fetch' do
      it 'returns the value for keys that exist' do
        expect(collection.fetch('data')).to be == representation['data']
        expect(collection.fetch('data').fetch('title')).to be == 'Book 1'
      end

      it 'raises an error for missing keys' do
        expect { collection.fetch('missing key') }.to raise_error KeyError
      end

      describe 'with a default value' do
        it 'returns the value for keys that exist' do
          expect(collection.fetch('data', 'a_string')).to be_kind_of Hash
        end

        it 'returns the default value for missing keys' do
          expect(collection.fetch('missing key', 'default')).to be == 'default'
        end
      end
    end
  end
end
