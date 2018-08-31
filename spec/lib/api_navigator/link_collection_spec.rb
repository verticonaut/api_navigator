require 'spec_helper'

module ApiNavigator
  describe LinkCollection do
    let(:entry_point) { double('EntryPoint', config: { base_uri: '/' }) }

    let(:representation) do
      JSON.parse(Fixtures::Requests.root_response)
    end

    let(:links) do
      LinkCollection.new(representation['_links'], representation['_links']['curies'], entry_point)
    end

    it 'is a CollectionHash' do
      expect(LinkCollection.ancestors).to include CollectionHash
    end

    it 'initializes the collection with links' do
      expect(links).to respond_to(:books)
    end

    it 'returns link objects for each link' do
      expect(links.books).to be_kind_of Link
      expect(links['self']).to be_kind_of Link

      expect(links.two_links).to be_kind_of Array
      expect(links['two_links']).to be_kind_of Array
    end

    describe 'plain link' do
      let(:plain_link) { links.books }
      it 'must be correct' do
        expect(plain_link._url).to be == '/books'
      end
    end

    describe 'templated link' do
      let(:templated_link) { links.filter }
      it 'must expand' do
        expect(templated_link._expand(filter: 'gizmos')._url).to be == '/productions/1?categories=gizmos'
      end
    end

    describe 'curied link collection' do
      let(:curied_link) { links['api:authors'] }
      let(:curie) { links._curies['api'] }
      it 'must expand' do
        expect(curied_link._expand(rel: 'assoc')._url).to be == '/api/authors'
      end
      it 'exposes curie' do
        expect(curie.expand('authors')).to be == '/docs/resources/authors'
      end
    end

    describe 'array of links' do
      let(:two_links) { links.two_links }

      it 'should have 2 items' do
        expect(two_links.length).to be == 2
      end

      it 'must be an array of Links' do
        two_links.each do |link|
          expect(link).to be_kind_of Link
        end
      end
    end

    describe 'null link value' do
      let(:null_link) { links.null_link }
      it 'must be nil' do
        expect(null_link).to be_nil
      end
    end
  end
end
