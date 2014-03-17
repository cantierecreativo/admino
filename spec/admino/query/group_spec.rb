require 'spec_helper'

module Admino
  module Query
    describe Group do
      subject(:group) { Group.new(config, params) }
      let(:config) { Configuration::Group.new(:foo, [:bar]) }
      let(:params) { {} }

      describe '#active_scope' do
        context 'with no param' do
          let(:params) { {} }

          it 'returns nil' do
            expect(group.active_scope).to be_nil
          end
        end

        context 'with an invalid value' do
          let(:params) { { 'foo' => 'qux' } }

          it 'returns nil' do
            expect(group.active_scope).to be_nil
          end
        end

        context 'with a valid value' do
          let(:params) { { 'foo' => 'bar' } }

          it 'returns the scope name' do
            expect(group.active_scope).to eq :bar
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

      describe '#is_scope_active?' do
        let(:params) { { 'foo' => 'bar' } }

        it 'returns true if the provided scope is the one currently active' do
          expect(group.is_scope_active?(:bar)).to be_true
        end
      end
    end
  end
end

