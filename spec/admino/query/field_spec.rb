require 'spec_helper'

module Admino
  module Query
    describe Field do
      subject(:field) { Field.new(config, params) }
      let(:config) { Configuration::Field.new(:foo) }
      let(:params) { {} }

      describe '#value' do
        context 'with a value' do
          let(:params) { { 'query' => { 'foo' => 'bar' } } }

          it 'returns the param value for the field' do
            expect(field.value).to eq 'bar'
          end
        end

        context 'else' do
          it 'returns nil' do
            expect(field.value).to be_nil
          end
        end

        context 'with coertion' do
          let(:config) {
            Configuration::Field.new(:foo, coerce: :to_date)
          }
          let(:params) { { 'query' => { 'foo' => '2014-10-05' } } }

          it 'returns the coerced param value for the field' do
            expect(field.value).to be_a Date
          end
        end
      end

      describe '#augment_scope' do
        let(:result) { field.augment_scope(scope) }
        let(:scope) { ScopeMock.new('original') }

        context 'if the field has a value' do
          let(:params) { { 'query' => { 'foo' => 'bar' } } }

          it 'returns the original scope chained with the field scope' do
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

