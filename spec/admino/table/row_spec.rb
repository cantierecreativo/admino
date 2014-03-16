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
          it { should eq(attribute_name: :title, label: nil, html_options: {}) }
        end

        context 'with a string param' do
          let(:arguments) { ['Title'] }
          it { should eq(attribute_name: nil, label: 'Title', html_options: {}) }
        end

        context 'with a string and a symbol param' do
          let(:arguments) { [:title, 'Title'] }
          it { should eq(attribute_name: :title, label: 'Title', html_options: {}) }
        end

        context 'with options' do
          let(:arguments) { [{ foo: 'bar' }] }
          it { should eq(attribute_name: nil, label: nil, html_options: { foo: 'bar' }) }
        end
      end

      describe '#parse_action_args' do
        subject do
          row.parse_action_args(arguments)
        end

        context 'with a symbol param' do
          let(:arguments) { [:show] }
          it { should eq(action_name: :show, url: nil, label: nil, html_options: {}) }
        end

        context 'with a one string param' do
          let(:arguments) { ['/'] }
          it { should eq(action_name: nil, url: '/', label: nil, html_options: {}) }
        end

        context 'with a two string params' do
          let(:arguments) { ['/', 'Details'] }
          it { should eq(action_name: nil, url: '/', label: 'Details', html_options: {}) }
        end

        context 'with options' do
          let(:arguments) { [{ foo: 'bar' }] }
          it { should eq(action_name: nil, url: nil, label: nil, html_options: { foo: 'bar' }) }
        end
      end
    end
  end
end

