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

      context 'with a declared field' do
        let(:config) { Configuration.new }
        let(:field_config) { config.add_field(:field) }

        before do
          field_config
        end

        it 'returns a configured Field' do
          field = query.field_by_name(:field)
          expect(field.config).to eq field_config
          expect(field.params).to eq params
        end
      end

      context 'with a declared group' do
        let(:config) { Configuration.new }
        let(:group_config) { config.add_group(:group, [:one, :two]) }

        before do
          group_config
        end

        it 'returns a configured Group' do
          group = query.group_by_name(:group)
          expect(group.config).to eq group_config
          expect(group.params).to eq params
          expect(group.i18n_key).to eq :group
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

        context 'with a set of fields and groups' do
          let(:field_config) { config.add_field(:field) }
          let(:group_config) { config.add_group(:group, [:one, :two]) }
          let(:scope_chained_with_field) { double('scope 1') }
          let(:final_chain) { double('scope 2') }

          before do
            field_config
            group_config
            query

            query.field_by_name(:field).
              stub(:augment_scope).
              with(starting_scope).
              and_return(scope_chained_with_field)

            query.group_by_name(:group).
              stub(:augment_scope).
              with(scope_chained_with_field).
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

