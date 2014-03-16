require 'spec_helper'

module Admino
  module Table
    describe HeadRow do
      subject(:row) { HeadRow.new(klass, view) }
      let(:view) { RailsViewContext.new }
      let(:klass) { Post }

      it 'takes a class and a view context' do
        expect(row.resource_klass).to eq klass
        expect(row.view_context).to eq view
      end

      describe '#column' do
        subject { row.to_html }

        context 'text' do
          context 'with label' do
            before do
              row.column(:title, 'This is a title')
            end

            it 'generates a label with it' do
              should have_tag(:th, text: 'This is a title')
            end
          end

          context 'with no label' do
            before { row.column(:title) }

            it 'generates a label with the titleized attribute name' do
              should have_tag(:th, text: 'Title')
            end
          end

          context 'with I18n set up' do
            before do
              I18n.backend.store_translations(
                :en,
                activemodel: { attributes: { post: { title: 'Post title' } } }
              )
            end

            before { row.column(:title) }

            it 'generates a label with the human attribute name' do
              should have_tag(:th, text: 'Post title')
            end
          end
        end

        context 'role' do
          before { row.column(:author_name) }

          it 'generates a role attribute with the snake-cased name of the attribute' do
            should have_tag(:th, with: { role: 'author-name' })
          end
        end

        context 'with html options param' do
          before { row.column(:title, class: 'foo') }

          it 'uses it to build attributes' do
            should have_tag(:th, with: { class: 'foo' })
          end
        end
      end

      describe '#actions' do
        subject { row.to_html }

        context do
          before { row.actions }

          it 'renders a th cell with role "actions"' do
            should have_tag(:th, with: { role: 'actions' })
          end

          it 'renders a th cell with text "Actions"' do
            should have_tag(:th, text: 'Actions')
          end
        end

        context 'with generic I18n set up' do
          before do
            I18n.backend.store_translations(
              :en,
              table: { actions: { title: 'Available actions' } }
            )
          end

          it 'renders a th cell with I18n text' do
            row.actions
            should have_tag(:th, text: 'Available actions')
          end

          context 'and specific I18n set up' do
            before do
              I18n.backend.store_translations(
                :en,
                table: { actions: { post: { title: 'Post actions' } } }
              )
            end

            it 'uses the specific I18n text' do
              row.actions
              should have_tag(:th, text: 'Post actions')
            end
          end
        end
      end
    end
  end
end

