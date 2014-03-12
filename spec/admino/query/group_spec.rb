require 'spec_helper'

module Admino
  module Query
    describe Group do
      subject(:group) { Group.new(config, params) }
      let(:config) { Configuration::Group.new(:foo, [:bar]) }
      let(:params) { {} }

      describe '#current_scope' do
        context 'with no param' do
          let(:params) { {} }

          it 'returns the param value for the field' do
            expect(group.current_scope).to be_nil
          end
        end

        context 'with an invalid value' do
          let(:params) { { 'foo' => 'qux' } }

          it 'returns the param value for the field' do
            expect(group.current_scope).to be_nil
          end
        end

        context 'with a valid value' do
          let(:params) { { 'foo' => 'bar' } }

          it 'returns nil' do
            expect(group.current_scope).to eq :bar
          end
        end
      end

      describe '#augment_scope' do
        let(:result) { group.augment_scope(scope) }
        let(:scope) { ScopeMock.new('original') }

        context 'if the field has a value' do
          let(:params) { { 'foo' => 'bar' } }

          it 'returns the original scope chained with the group scope' do
            expect(result.chain).to eq [:bar, []]
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

