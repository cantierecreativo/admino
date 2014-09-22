require 'spec_helper'

module Admino
  module Table
    describe Row do
      subject(:row) { Row.new(view) }
      let(:view) { double('View Context') }

      it 'takes view context' do
        expect(row.view_context).to eq view
      end

      it 'aliases view_context to h' do
        expect(row.h).to eq view
      end

      describe '#parse_column_args' do
        subject do
          row.parse_column_args(arguments)
        end

        context 'with a symbol param' do
          let(:arguments) { [:title] }
          it { is_expected.to eq [:title, nil, {}] }
        end

        context 'with a string param' do
          let(:arguments) { ['Title'] }
          it { is_expected.to eq [nil, 'Title', {}] }
        end

        context 'with a symbol and string param' do
          let(:arguments) { [:title, 'Title'] }
          it { is_expected.to eq [:title, 'Title', {}] }
        end

        context 'with two symbol params' do
          let(:arguments) { [:title, :foo] }
          it { is_expected.to eq [:title, :foo, {}] }
        end

        context 'with options' do
          let(:arguments) { [{ foo: 'bar' }] }
          it { is_expected.to eq [nil, nil, { foo: 'bar' }] }
        end
      end

      describe '#parse_action_args' do
        subject do
          row.parse_action_args(arguments)
        end

        context 'with a symbol param' do
          let(:arguments) { [:show] }
          it { is_expected.to eq [:show, nil, nil, {}] }
        end

        context 'with a one string param' do
          let(:arguments) { ['/'] }
          it { is_expected.to eq [nil, '/', nil, {}] }
        end

        context 'with a two string params' do
          let(:arguments) { ['/', 'Details'] }
          it { is_expected.to eq [nil, '/', 'Details', {}] }
        end

        context 'with options' do
          let(:arguments) { [{ foo: 'bar' }] }
          it { is_expected.to eq [nil, nil, nil, { foo: 'bar' }] }
        end
      end
    end
  end
end

