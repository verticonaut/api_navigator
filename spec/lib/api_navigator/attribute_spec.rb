require 'spec_helper'

module ApiNavigator
  describe Attributes do
    let(:representation) do
      JSON.parse(Fixtures::Requests.book_response)
    end

    let(:attributes) do
      Attributes.new(representation)
    end

    it 'does not set _links as an attribute' do
      expect(attributes).not_to respond_to :_links
    end

    it 'does not set _meta as an attribute' do
      expect(attributes).not_to respond_to :_meta
    end

    it 'sets normal attributes' do
      expect(attributes).to respond_to :title
      expect(attributes.title).to be == "Book 1"

      expect(attributes).to respond_to :body
      expect(attributes.body).to be == 'Book 1 Body'

      expect(attributes).to respond_to :year
      expect(attributes.year).to be == 1999
    end

    it 'is a collection' do
      expect(Attributes.ancestors).to include(Collection)
    end
  end
end
