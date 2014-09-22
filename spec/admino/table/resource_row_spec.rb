require 'spec_helper'

module Admino
  module Table
    describe ResourceRow do
      subject(:row) { ResourceRow.new(resource, view) }
      let(:view) { RailsViewContext.new }
      let(:resource) { Post.new('1') }

      it 'takes a resource and a view context' do
        expect(row.resource).to eq resource
        expect(row.view_context).to eq view
      end

      describe '#column' do
        subject { row.to_html }

        context 'if block is present' do
          before do
            row.column { 'foo' }
          end

          it 'fills the cell with the block content' do
            is_expected.to have_tag(:td, text: 'foo')
          end
        end

        context 'if attribute is present' do
          before { row.column(:title) }

          it 'fills the cell with the attribute value' do
            is_expected.to have_tag(:td, text: 'Post 1')
          end
        end

        context 'if both attribute and block are missing' do
          it 'raises an ArgumentError' do
            expect { row.column('Title') }.to raise_error(ArgumentError)
          end
        end

        context 'role attribute' do
          before { row.column(:author_name) }

          it 'generates a role attribute with the snake-cased name of the attribute' do
            is_expected.to have_tag(:td, with: { role: 'author-name' })
          end
        end

        context 'with HTML options param' do
          before { row.column(:title, class: 'title') }

          it 'uses it to build attributes' do
            is_expected.to have_tag(:td, with: { class: 'title' })
          end

          context 'with a class that implements a <action_name>_html_options' do
            let(:row) { row_subclass.new(resource, view) }
            let(:row_subclass) do
              Class.new(ResourceRow) do
                def column_html_options(action_name)
                  { class: 'attribute' }
                end
              end
            end

            it 'renders them as attributes' do
              is_expected.to have_tag(:td, with: { class: 'attribute title' })
            end
          end
        end
      end

      describe '#actions' do
        context 'block given' do
          it 'yields the block' do
            called = false
            result = row.actions do
              called = true
            end

            expect(called).to be_truthy
          end
        end

        context 'no block' do
          before do
            allow(row).to receive(:action)
          end

          before do
            row.actions(:show, :destroy)
          end

          it 'calls #action for each passed param' do
            expect(row).to have_received(:action).with(:show)
            expect(row).to have_received(:action).with(:destroy)
          end
        end
      end

      describe '#action' do
        subject { row.to_html }

        context 'URL' do
          context 'with an explicit URL' do
            before { row.action(:show, '/') }

            it 'generates a link with the specified URL' do
              is_expected.to have_tag(:a, with: { href: '/' })
            end
          end

          context 'with no explicit URL' do
            let(:row) { row_subclass.new(resource, view) }
            let(:row_subclass) do
              Class.new(ResourceRow) do
                def show_action_url
                  "/posts/#{resource.to_param}"
                end
              end
            end

            before { row.action(:show) }

            it 'uses a method to build the URL (ie. show_url)' do
              is_expected.to have_tag(:a, with: { href: '/posts/1' })
            end
          end

          context 'with no explicit URL and no action name' do
            it 'raises an ArgumentError' do
              expect { row.action(:show) }.to raise_error(ArgumentError)
            end
          end
        end

        context 'with no arguments' do
          it 'raises an ArgumentError' do
            expect { row.action }.to raise_error(ArgumentError)
          end
        end

        context 'td cell' do
          before { row.action(:show, '/') }

          it 'generates a td cell with actions role' do
            is_expected.to have_tag(:td, with: { role: 'actions' })
          end
        end

        context 'link role' do
          before { row.action(:show, '/') }

          it 'generates a link with role' do
            is_expected.to have_tag(:a, with: { role: 'show' })
          end
        end

        context 'link text' do
          context do
            before { row.action(:show, '/') }

            it 'generates a link with a titleized attribute' do
              is_expected.to have_tag(:a, text: 'Show')
            end
          end

          context 'if I18n is set up' do
            before do
              I18n.backend.store_translations(
                :en,
                table: { actions: { post: { show: 'Show post' } } }
              )
            end

            before { row.action(:show, '/') }

            it 'generates a I18n text' do
              is_expected.to have_tag(:a, text: 'Show post')
            end
          end
        end

        context 'with html options' do
          before { row.action(:show, '/', class: 'foo') }

          it 'renders them as attributes' do
            is_expected.to have_tag(:a, with: { class: 'foo' })
          end

          context 'with a class that implements a <action_name>_html_options' do
            let(:row) { row_subclass.new(resource, view) }
            let(:row_subclass) do
              Class.new(ResourceRow) do
                def action_html_options(action_name)
                  { class: 'button' }
                end

                def show_action_html_options
                  { class: 'show-button' }
                end
              end
            end

            it 'renders them as attributes' do
              is_expected.to have_tag(:a, with: { class: 'foo show-button button' })
            end
          end
        end

        context 'with block' do
          before do
            row.action { 'Foo' }
          end

          it 'renders it' do
            is_expected.to have_tag(:td, text: 'Foo')
          end
        end
      end
    end
  end
end

