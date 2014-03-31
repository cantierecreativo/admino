require 'spec_helper'

module Admino
  module Query
    describe Dsl do
      let(:config) { TestQuery.config }
      let(:instance) { TestQuery.new }

      it 'allows #search_field declaration' do
        search_field = config.search_fields.last
        expect(search_field.name).to eq :starting_from
        expect(search_field.coerce_to).to eq :to_date
      end

      it 'allows #filter_by declaration' do
        filter_group = config.filter_groups.first
        expect(filter_group.name).to eq :bar
        expect(filter_group.scopes).to eq [:one, :two]
        expect(filter_group.include_empty_scope?).to be_true
      end

      it 'allows #sortings declaration' do
        sorting = config.sorting
        expect(sorting.scopes).to eq [:by_title, :by_date]
        expect(sorting.default_scope).to eq :by_title
        expect(sorting.default_direction).to eq :desc
      end

      it 'allows #starting_scope block declaration' do
        expect(config.starting_scope_callable.call).to eq 'start'
      end

      it 'allows #ending_scope block declaration' do
        expect(config.ending_scope_callable.call).to eq 'end'
      end

      context 'with a search_field' do
        let(:search_field) { double('SearchField', value: 'value') }

        before do
          instance.stub(:search_field_by_name).
            with(:foo).
            and_return(search_field)
        end

        it 'it generates a getter' do
          expect(instance.foo).to eq 'value'
        end
      end
    end
  end
end

