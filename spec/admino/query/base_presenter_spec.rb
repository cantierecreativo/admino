require 'spec_helper'

module Admino
  module Query
    describe BasePresenter do
      subject(:presenter) { BasePresenter.new(query, view) }
      let(:view) { RailsViewContext.new }
      let(:query) do
        TestQuery.new(query: { foo: 'value' })
      end
      let(:request_object) do
        double(
          'ActionDispatch::Request',
          fullpath: '/?foo=bar'
        )
      end

      before do
        view.stub(:request).and_return(request_object)
      end

      describe '#form' do
        let(:result) do
          presenter.form do |form|
            form.label(:foo) <<
            form.text_field(:foo)
          end
        end

        before do
          I18n.backend.store_translations(
            :en,
            query: { attributes: { test_query: { foo: 'NAME' } } }
          )
        end

        it 'renders a form pointing to the current URL' do
          expect(result).to have_tag(:form, with: { action: '/?foo=bar' })
        end

        it 'renders a form with method GET' do
          expect(result).to have_tag(:form, with: { method: 'get' })
        end

        it 'renders inputs with a query[] name prefix' do
          expect(result).to have_tag(:input, with: { type: 'text', name: 'query[foo]' })
        end

        it 'prefills inputs with query value' do
          expect(result).to have_tag(:input, with: { type: 'text', value: 'value' })
        end

        it 'it generates labels in the :query I18n space' do
          expect(result).to have_tag(:label, text: 'NAME')
        end
      end
    end
  end
end

