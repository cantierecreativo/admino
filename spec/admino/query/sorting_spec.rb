require 'spec_helper'

module Admino
  module Query
    describe Sorting do
      subject(:sorting) { Sorting.new(config, params) }
      let(:config) do
        Configuration::Sorting.new(sorting_scopes, options)
      end
      let(:sorting_scopes) { [:by_title, :by_date] }
      let(:options) { {} }
      let(:params) { {} }

      describe '#active_scope' do
        context 'with no param' do
          let(:params) { {} }

          it 'returns false' do
            expect(sorting.active_scope).to be_nil
          end

          context 'if a default scope is configured' do
            let(:options) { { default_scope: :by_date } }

            it 'returns it' do
              expect(sorting.active_scope).to eq :by_date
            end
          end
        end

        context 'with an invalid value' do
          let(:params) { { 'sorting' => 'foo' } }

          it 'returns false' do
            expect(sorting.active_scope).to be_nil
          end
        end

        context 'with a valid value' do
          let(:params) { { 'sorting' => 'by_title' } }

          it 'returns the scope name' do
            expect(sorting.active_scope).to eq :by_title
          end
        end
      end

      describe '#ascending?' do
        context 'with no param' do
          let(:params) { {} }

          it 'returns true' do
            expect(sorting).to be_ascending
          end
        end

        context 'with invalid value' do
          let(:params) { { 'sort_order' => 'foo' } }

          it 'returns true' do
            expect(sorting).to be_ascending
          end
        end

        context 'with "asc" value' do
          let(:params) { { 'sort_order' => 'asc' } }

          it 'returns nil' do
            expect(sorting).to be_ascending
          end
        end

        context 'with "desc" value' do
          let(:params) { { 'sort_order' => 'desc' } }

          it 'returns the param value for the search_field' do
            expect(sorting).not_to be_ascending
          end
        end

        context 'if a default scope and direction are set and default scope is current' do
          let(:options) { { default_scope: :by_date, default_direction: :desc } }
          let(:params) { { 'sorting' => 'by_date', 'sort_order' => 'desc' } }

          it 'returns it' do
            expect(sorting).not_to be_ascending
          end
        end
      end

      describe '#augment_scope' do
        let(:result) { sorting.augment_scope(scope) }
        let(:scope) { ScopeMock.new('original') }

        context 'if the search_field has a value' do
          let(:params) { { 'sorting' => 'by_title', 'sort_order' => 'desc' } }

          it 'returns the original scope chained with the current scope' do
            expect(result.chain).to eq [:by_title, [:desc]]
          end
        end

        context 'else' do
          it 'returns the original scope' do
            expect(result).to eq scope
          end
        end

        context 'if a default scope is configured' do
          let(:options) { { default_scope: :by_date } }
          let(:params) { {} }

          it 'returns the original scope chained with the default scope' do
            expect(result.chain).to eq [:by_date, [:asc]]
          end

          context 'if a default direction is configured' do
            let(:options) { { default_scope: :by_date, default_direction: :desc } }

            it 'returns the original scope chained with the default scope and default direction' do
              expect(result.chain).to eq [:by_date, [:desc]]
            end
          end
        end
      end

      describe '#is_scope_active?' do
        let(:params) { { 'sorting' => 'by_date' } }

        it 'returns true if the provided scope is the one currently active' do
          expect(sorting.is_scope_active?(:by_date)).to be_true
        end
      end
    end
  end
end

