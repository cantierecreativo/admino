require 'spec_helper'
require 'active_support/hash_with_indifferent_access'

module Admino
  module Query
    describe FilterGroupPresenter do
      subject(:presenter) { FilterGroupPresenter.new(filter_group, view) }
      let(:view) { RailsViewContext.new }
      let(:filter_group) do
        double(
          'FilterGroup',
          query_i18n_key: :query_name,
          i18n_key: :filter_group,
          param_name: :filter_group
        )
      end
      let(:request_object) do
        double(
          'ActionDispatch::Request',
          query_parameters: ActiveSupport::HashWithIndifferentAccess.new(
            params
          ),
          path: '/'
        )
      end
      let(:params) do
        { 'query' => { 'field' => 'value', 'filter_group' => 'bar' } }
      end

      before do
        allow(view).to receive(:request).and_return(request_object)
      end

      describe '#scope_link' do
        subject { presenter.scope_link(:foo) }
        let(:scope_active) { false }

        before do
          allow(filter_group).to receive(:is_scope_active?).
            with(:foo).and_return(scope_active)
        end

        context 'active CSS class' do
          let(:scope_active) { true }

          it 'adds an is-active class' do
            is_expected.to have_tag(:a, with: { class: 'is-active' })
          end

          context 'if an :active_class option is specified' do
            subject { presenter.scope_link(:foo, active_class: 'active') }

            it 'adds it' do
              is_expected.to have_tag(:a, with: { class: 'active' })
            end
          end
        end

        context 'else' do
          it 'does not add it' do
            is_expected.not_to have_tag(:a, with: { class: 'is-active' })
          end
        end

        context 'label' do
          before do
            allow(presenter).to receive(:scope_name).with(:foo).and_return('scope_name')
          end

          it 'uses #scope_name method' do
            is_expected.to have_tag(:a, text: 'scope_name')
          end

          context 'if a second parameter is supplied' do
            subject { presenter.scope_link(:foo, 'test', active_class: 'active') }

            it 'uses it' do
              is_expected.to have_tag(:a, text: 'test')
            end
          end
        end

        context 'URL' do
          before do
            allow(presenter).to receive(:scope_path).with(:foo).and_return('URL')
          end

          it 'uses #scope_path method' do
            is_expected.to have_tag(:a, href: 'URL')
          end
        end
      end

      describe '#scope_params' do
        let(:scope_active) { false }
        subject { presenter.scope_params(:foo) }

        before do
          allow(filter_group).to receive(:is_scope_active?).with(:foo).and_return(scope_active)
        end

        context 'if scope is active' do
          let(:scope_active) { true }

          it 'deletes the filter_group param' do
            expect(subject[:query]).not_to have_key 'filter_group'
          end

          it 'keeps the request parameters intact' do
            presenter.scope_params(:foo)
            expect(request_object.query_parameters[:query][:filter_group]).to be_present
          end

          context 'the resulting query hash becomes empty' do
            let(:params) do
              { 'query' => { 'filter_group' => 'bar' } }
            end

            it 'removes the param altoghether' do
              expect(subject).not_to have_key 'query'
            end
          end
        end

        context 'else' do
          let(:scope_active) { false }

          it 'is set as filter group value' do
            expect(subject[:query][:filter_group]).to eq 'foo'
          end
        end

        it 'preserves the other params' do
          expect(subject[:query][:field]).to eq 'value'
        end
      end

      describe '#name' do
        context do
          before do
            I18n.backend.store_translations(
              :en,
              query: { filter_groups: { query_name: { filter_group: { name: 'NAME' } } } }
            )
          end

          it 'returns a I18n translatable name for the filter_group' do
            expect(presenter.name).to eq 'NAME'
          end
        end

        context 'if no translation is available' do
          it 'falls back to a titleized version of the filter_group name' do
            expect(presenter.name).to eq 'Filter group'
          end
        end
      end

      describe '#scope_name' do
        context do
          before do
            I18n.backend.store_translations(
              :en,
              query: { filter_groups: { query_name: { filter_group: { scopes: { bar: 'NAME' } } } } }
            )
          end

          it 'returns a I18n translatable name for the scope' do
            expect(presenter.scope_name(:bar)).to eq 'NAME'
          end
        end

        context 'if no translation is available' do
          it 'falls back to a titleized version of the scope name' do
            expect(presenter.scope_name(:bar)).to eq 'Bar'
          end
        end
      end
    end
  end
end

