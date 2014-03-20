require 'spec_helper'

module Admino
  module Query
    describe SearchField do
      subject(:search_field) { SearchField.new(config, params) }
      let(:config) { Configuration::SearchField.new(:foo) }
      let(:params) { {} }

      describe '#value' do
        context 'with a value' do
          let(:params) { { 'query' => { 'foo' => 'bar' } } }

          it 'returns the param value for the search_field' do
            expect(search_field.value).to eq 'bar'
          end
        end

        context 'else' do
          it 'returns nil' do
            expect(search_field.value).to be_nil
          end
        end

        context 'with coertion' do
          let(:config) {
            Configuration::SearchField.new(:foo, coerce: :to_date)
          }

          context 'with a possible coertion' do
            let(:params) { { 'query' => { 'foo' => '2014-10-05' } } }

            it 'returns the coerced param value for the search_field' do
              expect(search_field.value).to be_a Date
            end
          end

          context 'with a possible coertion' do
            let(:params) { { 'query' => { 'foo' => '' } } }

            it 'returns nil' do
              expect(search_field.value).to be_nil
            end
          end
        end
      end

      describe '#augment_scope' do
        let(:result) { search_field.augment_scope(scope) }
        let(:scope) { ScopeMock.new('original') }

        context 'if the search_field has a value' do
          let(:params) { { 'query' => { 'foo' => 'bar' } } }

          it 'returns the original scope chained with the search_field scope' do
            expect(result.chain).to eq [:foo, ['bar']]
          end
        end

        context 'else' do
          it 'returns the original scope' do
            expect(result).to eq scope
          end
        end
      end
    end
  end
end

