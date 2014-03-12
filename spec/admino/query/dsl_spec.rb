require 'spec_helper'

module Admino
  module Query
    describe Dsl do
      let(:config) { TestQuery.config }
      let(:instance) { TestQuery.new }

      it 'allows #field declaration' do
        field = config.fields.last
        expect(field.name).to eq :starting_from
        expect(field.coerce_to).to eq :to_date
      end

      it 'allows #group declaration' do
        group = config.groups.first
        expect(group.name).to eq :bar
        expect(group.scopes).to eq [:one, :two]
      end

      it 'allows #starting_scope block declaration' do
        expect(config.starting_scope_callable.call).to eq 'start'
      end

      it 'allows #ending_scope block declaration' do
        expect(config.ending_scope_callable.call).to eq 'end'
      end

      context 'with a field' do
        let(:field) { double('Field', value: 'value') }

        before do
          instance.stub(:field_by_name).
            with(:foo).
            and_return(field)
        end

        it 'it generates a getter' do
          expect(instance.foo).to eq 'value'
        end
      end
    end
  end
end

