require 'spec_helper'

module Admino
  module Query
    describe Base do
      subject(:query) { Base.new(params) }
      let(:params) { {} }

      it 'takes a request params' do
        expect(query.params).to eq params
      end
    end
  end
end

