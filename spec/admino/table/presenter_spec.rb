require 'spec_helper'
require 'ostruct'

module Admino
  module Table
    describe Presenter do
      subject(:presenter) { presenter_klass.new(collection, Post, query, view) }
      let(:presenter_klass) { Presenter }
      let(:query) { double('Query') }
      let(:view) { RailsViewContext.new }

      let(:collection) { [ first_post, second_post ] }
      let(:first_post) { Post.new('1') }
      let(:second_post) { Post.new('2') }

      let(:head_row) { double('HeadRow', to_html: '<td id="thead_td"></td>'.html_safe) }
      let(:resource_row) { double('ResourceRow', to_html: '<td id="tbody_td"></td>'.html_safe) }

      before do
        allow(HeadRow).to receive(:new).with(Post, query, view).and_return(head_row)
        allow(ResourceRow).to receive(:new).with(first_post, view).and_return(resource_row)
        allow(ResourceRow).to receive(:new).with(second_post, view).and_return(resource_row)
      end

      describe '#to_html' do
        let(:result) { presenter.to_html }

        it 'outputs a table' do
          expect(result).to have_tag(:table)
        end

        it 'outputs a thead with a single row' do
          expect(result).to have_tag('table thead tr')
        end

        it 'outputs a tbody with a row for each collection member' do
          expect(result).to have_tag('table tbody tr', count: 2)
        end

        context 'if the record responds to #dom_id' do
          before do
            allow(first_post).to receive(:dom_id).and_return('post_1')
            allow(second_post).to receive(:dom_id).and_return('post_2')
          end

          it 'adds a record identifier to each collection row' do
            expect(result).to have_tag('tbody tr#post_1:first-child')
            expect(result).to have_tag('tbody tr#post_2:last-child')
          end
        end

        it 'adds zebra classes to each collection row' do
          expect(result).to have_tag('tbody tr.is-even:first-child')
          expect(result).to have_tag('tbody tr.is-odd:last-child')
        end

        it 'delegates thead columns creation to .to_html HeadRow' do
          expect(result).to have_tag('thead tr td#thead_td')
        end

        it 'delegates tbody columns creation to .to_html ResourceRow' do
          expect(result).to have_tag('tbody tr td#tbody_td')
        end

        it 'allows passing table HTML options' do
          expect(presenter.to_html(id: 'table')).to have_tag(:table, with: { id: 'table' })
        end

        context 'with a block' do
          let(:block_call_args) do
            block_call_args = []
            presenter.to_html do |*args|
              block_call_args << args
            end
            block_call_args
          end

          it 'calls it once passing the HeadRow instance' do
            expect(block_call_args[0]).to eq [head_row, nil]
          end

          it 'calls it once for each collection member passing the ResourceRow instance and the member itself' do
            expect(block_call_args[1]).to eq [resource_row, first_post]
            expect(block_call_args[2]).to eq [resource_row, second_post]
          end
        end

        context 'custom table HTML options' do
          let(:presenter_klass) do
            Class.new(Presenter) do
              private

              def table_html_options
                { id: 'table' }
              end

              def thead_html_options
                { id: 'thead' }
              end

              def thead_tr_html_options
                { id: 'thead_tr' }
              end

              def tbody_html_options
                { id: 'tbody' }
              end

              def tbody_tr_html_options(resource, index)
                { class: "index-#{index}" }
              end

              def zebra_css_classes
                %w(one two)
              end
            end
          end

          it "allows customizing the default table html attributes" do
            expect(presenter.to_html).to have_tag(:table, with: { id: 'table' })
          end

          it "allows customizing the the default thead html attributes" do
            expect(presenter.to_html).to have_tag(:thead, with: { id: 'thead' })
          end

          it "allows customizing the the default thead_tr html attributes" do
            expect(presenter.to_html).to have_tag('thead tr#thead_tr')
          end

          it "allows customizing the the default tbody html attributes" do
            expect(presenter.to_html).to have_tag(:tbody, with: { id: 'tbody' })
          end

          it "allows customizing the tbody_tr html attributes" do
            expect(presenter.to_html).to have_tag("tbody tr.index-0:first-child")
          end

          it 'allows customizing zebra classes' do
            expect(presenter.to_html).to have_tag("tbody tr.one:first-child")
          end
        end

        context 'custom row builders' do
          let(:presenter_klass) do
            Class.new(Presenter) do
              private

              def head_row(*args)
                OpenStruct.new(to_html: '<td id="custom_thead_td"></td>'.html_safe)
              end

              def resource_row(*args)
                OpenStruct.new(to_html: '<td id="custom_tbody_td"></td>'.html_safe)
              end
            end
          end

          it 'allows customizing head row renderers' do
            expect(presenter.to_html).to have_tag('thead tr td#custom_thead_td')
          end

          it 'allows customizing resource row renderers' do
            expect(presenter.to_html).to have_tag('tbody tr td#custom_tbody_td')
          end
        end

        context 'with empty collection and no collection_klass' do
          let(:collection) { [] }
          subject(:presenter) { presenter_klass.new(collection, nil, query, view) }

          it 'raises an Exception' do
            expect { result }.to raise_error(ArgumentError)
          end
        end
      end
    end
  end
end

