require 'spec_helper'

module Admino
  module Query
    describe FilterGroup do
      subject(:filter_group) { FilterGroup.new(config, params) }
      let(:config) do
        Configuration::FilterGroup.new(:foo, [:bar, :other], options)
      end
      let(:options) { {} }
      let(:params) { {} }

      describe '#active_scope' do
        context 'with no param' do
          let(:params) { {} }

          it 'returns nil' do
            expect(filter_group.active_scope).to be_nil
          end

          context 'if include_empty_scope is true' do
            let(:options) { { include_empty_scope: true } }

            it 'returns the :empty scope' do
              expect(filter_group.active_scope).to eq :empty
            end

            context 'if default scope is set' do
              let(:config) do
                Configuration::FilterGroup.new(
                  :foo,
                  [:bar],
                  include_empty_scope: true,
                  default: :bar
                )
              end

              it 'returns it' do
                expect(filter_group.active_scope).to eq :bar
              end
            end
          end
        end

        context 'with "empty" param' do
          let(:params) { { 'query' => { 'foo' => 'empty' } } }

          context 'if include_empty_scope is true' do
            let(:options) { { include_empty_scope: true, default: :bar } }

            it 'returns the :empty scope' do
              expect(filter_group.active_scope).to eq :empty
            end
          end
        end

        context 'with an invalid value' do
          let(:params) { { 'query' => { 'foo' => 'qux' } } }

          it 'returns nil' do
            expect(filter_group.active_scope).to be_nil
          end

          context 'if include_empty_scope is true' do
            let(:options) { { include_empty_scope: true, default: :bar } }

            it 'returns nil' do
              expect(filter_group.active_scope).to be_nil
            end
          end
        end

        context 'with a valid value' do
          let(:params) { { 'query' => { 'foo' => 'bar' } } }

          it 'returns the scope name' do
            expect(filter_group.active_scope).to eq :bar
          end
        end
      end

      describe '#augment_scope' do
        let(:result) { filter_group.augment_scope(scope) }
        let(:scope) { ScopeMock.new('original') }

        context 'if the search_field has a value' do
          let(:params) { { 'query' => { 'foo' => 'bar' } } }

          it 'returns the original scope chained with the filter_group scope' do
            expect(result.chain).to eq [:bar, []]
          end
        end

        context 'else' do
          it 'returns the original scope' do
            expect(result).to eq scope
          end

          context 'if include_empty_scope is true' do
            let(:options) { { include_empty_scope: true } }

            it 'returns the original scope' do
              expect(result).to eq scope
            end
          end
        end
      end

      describe '#is_scope_active?' do
        let(:params) { { 'query' => { 'foo' => 'bar' } } }

        it 'returns true if the provided scope is the one currently active' do
          expect(filter_group.is_scope_active?('bar')).to be_truthy
        end
      end

      describe '#scopes' do
        subject { filter_group.scopes }

        context 'if include_empty_scope is true' do
          let(:options) { { include_empty_scope: true } }

          it { is_expected.to eq [:empty, :bar, :other] }
        end

        context 'else' do
          it { is_expected.to eq [:bar, :other] }
        end
      end
    end
  end
end

