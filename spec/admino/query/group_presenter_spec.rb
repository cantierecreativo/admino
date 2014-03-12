require 'spec_helper'

module Admino
  module Query
    describe GroupPresenter do
      subject(:presenter) { GroupPresenter.new(group, view) }
      let(:view) { RailsViewContext.new }
      let(:group) do
        double(
          'Group',
          query_i18n_key: :query_name,
          i18n_key: :group,
          param_name: :group
        )
      end
      let(:request_object) do
        double(
          'ActionDispatch::Request',
          query_parameters: { 'group' => 'bar' },
          path: '/'
        )
      end

      before do
        view.stub(:request).and_return(request_object)
      end

      describe '#scope_link' do
        before do
          group.stub(:is_scope_active?).with(:foo).and_return(true)
        end

        context 'active CSS class' do
          it 'adds an is-active class' do
            expect(presenter.scope_link(:foo)).to have_tag(:a, with: { class: 'is-active' })
          end

          context 'if an :active_class option is specified' do
            it 'adds it' do
              expect(presenter.scope_link(:foo, active_class: 'active')).to have_tag(:a, with: { class: 'active' })
            end
          end

          context 'else' do
            before do
              group.stub(:is_scope_active?).with(:foo).and_return(false)
            end

            it 'does not add it' do
              expect(presenter.scope_link(:foo)).not_to have_tag(:a, with: { class: 'is-active' })
            end
          end
        end

        context 'label' do
          before do
            presenter.stub(:scope_name).with(:foo).and_return('scope_name')
          end

          it 'uses #scope_name method' do
            expect(presenter.scope_link(:foo)).to have_tag(:a, text: 'scope_name')
          end

          context 'if a second parameter is supplied' do
            it 'uses it' do
              expect(presenter.scope_link(:foo, 'test')).to have_tag(:a, text: 'test')
            end
          end
        end

        context 'URL' do
          before do
            presenter.stub(:scope_path).with(:foo).and_return('URL')
          end

          it 'uses #scope_path method' do
            expect(presenter.scope_link(:foo)).to have_tag(:a, href: 'URL')
          end
        end
      end

      describe '#scope_params' do
        context 'if scope is nil' do
          it 'deletes the group param' do
            expect(presenter.scope_params(nil)).not_to have_key 'group'
          end
        end

        context 'else' do
          it 'deletes the group param' do
            expect(presenter.scope_params(:bar)[:group]).to eq 'bar'
          end
        end
      end

      describe '#name' do
        context do
          before do
            I18n.backend.store_translations(
              :en,
              query: { groups: { query_name: { group: { name: 'NAME' } } } }
            )
          end

          it 'returns a I18n translatable name for the group' do
            expect(presenter.name).to eq 'NAME'
          end
        end

        context 'if no translation is available' do
          it 'falls back to a titleized version of the group name' do
            expect(presenter.name).to eq 'Group'
          end
        end
      end

      describe '#scope_name' do
        context do
          before do
            I18n.backend.store_translations(
              :en,
              query: { groups: { query_name: { group: { scopes: { bar: 'NAME' } } } } }
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

