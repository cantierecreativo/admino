require 'spec_helper'

describe 'Action View integration' do
  let(:context) { RailsViewContext.new }

  describe '#simple_table_for' do
    let(:collection) { [ first_post, second_post ] }
    let(:first_post) { Post.new('1') }
    let(:second_post) { Post.new('2') }
    let(:params) {
      {
        sorting: 'by_title',
        sort_order: 'desc'
      }
    }
    let(:query) { TestQuery.new(params) }

    it 'produces HTML' do
      result = context.table_for(collection, query: query) do |table, record|
        table.column :title, sorting: :by_title
        table.actions do
          table.action :show, '/foo', 'Show'
        end
      end

      expect(result).to have_tag(:table) do
        with_tag 'thead th:first-child', with: { role: 'title' }
        with_tag 'thead th:last-child', with: { role: 'actions' }

        with_tag 'th:first-child a', with: { class: 'is-desc', href: '/?sort_order=asc&sorting=by_title' }, text: 'Title'
        with_tag 'th:last-child', text: 'Actions'

        with_tag 'tbody tr:first-child', with: { class: 'is-even' }
        with_tag 'tbody tr:last-child', with: { class: 'is-odd' }

        with_tag 'tbody tr:first-child td:first-child', with: { role: 'title' }, text: 'Post 1'
        with_tag 'tbody tr:first-child td:last-child', with: { role: 'actions' }

        with_tag 'tbody tr:first-child td:last-child a', with: { role: 'show', href: '/foo' }
      end
    end
  end

  describe '#filters_for' do
    let(:params) {
      {
        query: { bar: 'one' }
      }
    }
    let(:query) { TestQuery.new(params) }

    it 'produces HTML' do
      result = ""
      context.filters_for(query) do |group|
        result << "#{group.name}: "
        group.each_scope do |scope|
          result << scope.link
        end
      end

      expect(result).to have_tag(:a, with: { href: '/?query%5Bbar%5D=empty' }) do
        with_text 'Empty'
      end

      expect(result).to have_tag(:a, with: { class: 'is-active', href: '/?' }) do
        with_text 'One'
      end

      expect(result).to have_tag(:a, with: { href: '/?query%5Bbar%5D=two' }) do
        with_text 'Two'
      end
    end
  end

  describe '#sortings_for' do
    let(:params) {
      {
        sorting: 'by_title',
        sort_order: 'desc'
      }
    }
    let(:query) { TestQuery.new(params) }

    it 'produces HTML' do
      result = ""
      context.sortings_for(query) do |scope|
        result << scope.link
      end

      expect(result).to have_tag(:a, with: { class: 'is-desc', href: '/?sort_order=asc&sorting=by_title' }) do
        with_text 'By title'
      end

      expect(result).to have_tag(:a, with: { href: '/?sort_order=asc&sorting=by_date' }) do
        with_text 'By date'
      end
    end
  end

  describe '#search_form_for' do
    let(:params) {
      {
        query: { foo: 'test' }
      }
    }
    let(:query) { TestQuery.new(params) }

    it 'produces HTML' do
      result = context.search_form_for(query) do |f|
        f.text_field :foo
      end

      expect(result).to have_tag(:form, with: { action: '/?p=1', method: 'get' }) do
        with_tag 'input', with: { type: 'text', value: 'test', name: 'query[foo]' }
      end
    end
  end

  describe '#simple_search_form_for' do
    let(:params) {
      {
        query: { foo: 'test' }
      }
    }
    let(:query) { TestQuery.new(params) }

    it 'produces HTML' do
      result = context.simple_search_form_for(query) do |f|
        f.input :foo
      end

      expect(result).to have_tag(:form, with: { action: '/?p=1', method: 'get' }) do
        with_tag 'input', with: { type: 'text', value: 'test', name: 'query[foo]' }
      end
    end
  end
end

