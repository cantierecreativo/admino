require 'spec_helper'

module Admino
  module Query
    describe Base do
      subject(:query) { Base.new(params, config) }
      let(:params) { {} }
      let(:config) { nil }

      it 'takes a request params' do
        expect(query.params).to eq params
      end

      context 'with an explicit config' do
        let(:config) { Configuration.new }

        it 'uses it' do
          expect(query.config).to eq config
        end
      end

      context 'with a declared search_field' do
        let(:config) { Configuration.new }
        let(:search_field_config) { config.add_search_field(:search_field) }

        before do
          search_field_config
        end

        it 'returns a configured SearchField' do
          search_field = query.search_field_by_name(:search_field)
          expect(search_field.config).to eq search_field_config
          expect(search_field.params).to eq params
        end
      end

      context 'with a declared filter_group' do
        let(:config) { Configuration.new }
        let(:filter_group_config) { config.add_filter_group(:filter_group, [:one, :two]) }

        before do
          filter_group_config
        end

        it 'returns a configured FilterGroup' do
          filter_group = query.filter_group_by_name(:filter_group)
          expect(filter_group.config).to eq filter_group_config
          expect(filter_group.params).to eq params
          expect(filter_group.i18n_key).to eq :filter_group
        end
      end

      context 'with a declared sorting' do
        let(:config) { Configuration.new }
        let(:sorting_config) do
          config.add_sorting_scopes([:by_title, :by_date])
        end

        before do
          sorting_config
        end

        it 'returns a configured Sorting' do
          sorting = query.sorting
          expect(sorting.config).to eq sorting_config
          expect(sorting.params).to eq params
        end
      end

      describe '#scope' do
        let(:config) { Configuration.new }
        let(:result) { query.scope(starting_scope) }
        let(:starting_scope) { ScopeMock.new('explicit') }

        describe 'starting scope' do
          context 'with an explicit scope' do
            it 'uses it' do
              expect(result.name).to eq 'explicit'
            end
          end

          context 'with no explicit scope, but a default one configured' do
            let(:result) { query.scope }

            before do
              config.starting_scope_callable = Proc.new { |query|
                ScopeMock.new('configured').foo(query)
              }
            end

            before do
              result
            end

            it 'calls it with self and uses it' do
              expect(result.name).to eq 'configured'
              expect(result.chain).to eq [:foo, [query]]
            end
          end

          context 'with no scope' do
            let(:result) { query.scope }

            it 'raises a ArgumentError' do
              expect { result }.to raise_error(ArgumentError)
            end
          end
        end

        context 'with a set of search_fields, filter_groups and sortings' do
          let(:search_field_config) { config.add_search_field(:search_field) }
          let(:filter_group_config) { config.add_filter_group(:filter_group, [:one, :two]) }
          let(:sorting_config) { config.add_sorting_scopes([:title, :year]) }

          let(:scope_chained_with_search_field) { double('scope 1') }
          let(:scope_chained_with_group_filter) { double('scope 2') }
          let(:final_chain) { double('scope 3') }

          before do
            search_field_config
            filter_group_config
            sorting_config
            query

            allow(query.search_field_by_name(:search_field)).
              to receive(:augment_scope).
              with(starting_scope).
              and_return(scope_chained_with_search_field)

            allow(query.filter_group_by_name(:filter_group)).
              to receive(:augment_scope).
              with(scope_chained_with_search_field).
              and_return(scope_chained_with_group_filter)

            allow(query.sorting).to receive(:augment_scope).
              with(scope_chained_with_group_filter).
              and_return(final_chain)
          end

          it 'chains them toghether' do
            expect(result).to eq final_chain
          end
        end

        context 'with a configured ending scope' do
          before do
            config.ending_scope_callable = Proc.new { |query| bar(query) }
          end

          it 'calls it with self at the end of the chain' do
            expect(result.chain).to eq [:bar, [query]]
          end
        end
      end
    end
  end
end

