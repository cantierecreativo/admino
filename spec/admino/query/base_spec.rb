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

          let(:params) do
            {
              query: {
                search_field: "foo",
                filter_group: "one",
              },
              sorting: "title",
              sort_order: "desc"
            }
          end

          before do
            search_field_config
            filter_group_config
            sorting_config
            query
          end

          context 'if query object does not respond to scopes' do
            it 'chains from starting scope' do
              expect(result.chain).to eq [
                :search_field, ["foo"],
                :one, [],
                :title, [:desc]
              ]
            end
          end

          context 'else' do
            let(:query_klass) do
              Class.new(Base) do
                def self.model_name
                  ActiveModel::Name.new(self, nil, "temp")
                end

                def search_field(scope, foo)
                  scope.my_search_field(foo)
                end

                def one(scope)
                  scope.my_one
                end

                def title(scope, order)
                  scope.my_title(order)
                end
              end
            end

            subject(:query) do
              query_klass.new(params, config)
            end

            it 'chains from starting scope calling query object methods' do
              expect(result.chain).to eq [
                :my_search_field, ["foo"],
                :my_one, [],
                :my_title, [:desc]
              ]
            end
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

