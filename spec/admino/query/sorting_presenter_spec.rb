require 'spec_helper'

module Admino
  module Query
    describe SortingPresenter do
      subject(:presenter) { SortingPresenter.new(sorting, view) }
      let(:view) { RailsViewContext.new }
      let(:sorting) { double('Sorting', default_scope: 'by_name') }
      let(:request_object) do
        double(
          'ActionDispatch::Request',
          query_parameters: { 'sorting' => 'by_date' },
          path: '/'
        )
      end

      before do
        view.stub(:request).and_return(request_object)
      end

      describe '#scope_link' do
        subject { presenter.scope_link(:by_title, 'Titolo') }

        before do
          sorting.stub(:is_scope_active?).with(:by_title).and_return(false)
        end

        context 'scope is active' do
          before do
            sorting.stub(:is_scope_active?).with(:by_title).and_return(true)
          end

          context 'ascending' do
            before do
              sorting.stub(:ascending?).and_return(true)
            end

            it 'adds an is-asc class' do
              should have_tag(:a, with: { class: 'is-asc' })
            end

            context 'if an :asc_class option is specified' do
              subject { presenter.scope_link(:by_title, 'Titolo', asc_class: 'asc') }

              it 'adds it' do
                should have_tag(:a, with: { class: 'asc' })
              end
            end
          end

          context 'descendent' do
            before do
              sorting.stub(:ascending?).and_return(false)
            end

            it 'adds an is-desc class' do
              should have_tag(:a, with: { class: 'is-desc' })
            end

            context 'if a :desc_class option is specified' do
              subject { presenter.scope_link(:by_title, 'Titolo', desc_class: 'desc') }

              it 'adds it' do
                should have_tag(:a, with: { class: 'desc' })
              end
            end
          end
        end

        context 'else' do
          it 'does not add it' do
            should_not have_tag(:a, with: { class: 'is-asc' })
          end
        end

        context 'label' do
          it 'uses the provided argument' do
            should have_tag(:a, text: 'Titolo')
          end
        end

        context 'URL' do
          before do
            presenter.stub(:scope_path).with(:by_title).and_return('URL')
          end

          it 'uses #scope_path method' do
            should have_tag(:a, href: 'URL')
          end
        end
      end

      describe '#scope_params' do
        subject { presenter.scope_params(:by_title) }

        before do
          sorting.stub(:is_scope_active?).with(:by_title).and_return(false)
        end

        it 'sets the sorting param as the scope' do
          subject[:sorting] == 'by_title'
        end

        context 'scope is active' do
          before do
            sorting.stub(:is_scope_active?).with(:by_title).and_return(true)
          end

          context 'is currently ascending' do
            before do
              sorting.stub(:ascending?).and_return(true)
            end

            it 'sets the sorting order to descending' do
              subject[:sort_order] == 'desc'
            end
          end

          context 'is currently descending' do
            before do
              sorting.stub(:ascending?).and_return(false)
            end

            it 'sets the sorting order to ascending' do
              subject[:sort_order] == 'asc'
            end
          end
        end

        context 'scope is the default one' do
          let(:sorting) { double('Sorting', default_scope: 'by_title') }

          context 'default scope is ascending' do
            before do
              sorting.stub(:default_direction).and_return(:asc)
            end

            it 'sets the sorting order to ascending' do
              subject[:sort_order] == 'asc'
            end
          end

          context 'default scope is descending' do
            before do
              sorting.stub(:default_direction).and_return(:desc)
            end

            it 'sets the sorting order to descending' do
              subject[:sort_order] == 'desc'
            end
          end
        end

        context 'else' do
          before do
            sorting.stub(:is_scope_active?).with(:by_title).and_return(false)
          end

          it 'sets the sorting order to ascending' do
            subject[:sort_order] == 'asc'
          end
        end
      end
    end
  end
end

