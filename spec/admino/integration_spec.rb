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
      expect(result).to eq <<-HTML.strip
        <table><thead><tr><th role=\"title\"><a class=\"is-desc\" href=\"/?sort_order=asc&amp;sorting=by_title\">Title</a></th><th role=\"actions\">Actions</th></tr></thead><tbody><tr class=\"is-even\"><td role=\"title\" sorting=\"by_title\">Post 1</td><td role=\"actions\"><a href=\"/foo\" role=\"show\">Show</a></td></tr><tr class=\"is-odd\"><td role=\"title\" sorting=\"by_title\">Post 2</td><td role=\"actions\"><a href=\"/foo\" role=\"show\">Show</a></td></tr></tbody></table>
      HTML
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

      expect(result).to eq <<-HTML.strip
        Bar: <a href="/?query%5Bbar%5D=empty">Empty</a><a class="is-active" href="/?">One</a><a href="/?query%5Bbar%5D=two">Two</a>
      HTML
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

      expect(result).to eq <<-HTML.strip
        <a class=\"is-desc\" href=\"/?sort_order=asc&amp;sorting=by_title\">By title</a><a href=\"/?sort_order=asc&amp;sorting=by_date\">By date</a>
      HTML
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

      expect(result).to eq <<-HTML.strip
        <form accept-charset=\"UTF-8\" action=\"/?p=1\" class=\"new_query\" id=\"new_query\" method=\"get\"><div style=\"display:none\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div><input id=\"query_foo\" name=\"query[foo]\" type=\"text\" value=\"test\" /></form>
      HTML
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

      expect(result).to eq <<-HTML.strip
        <form accept-charset=\"UTF-8\" action=\"/?p=1\" class=\"simple_form new_query\" id=\"new_query\" method=\"get\"><div style=\"display:none\"><input name=\"utf8\" type=\"hidden\" value=\"&#x2713;\" /></div><div class=\"input string required query_foo\"><label class=\"string required\" for=\"query_foo\"><abbr title=\"required\">*</abbr> Foo</label><input aria-required=\"true\" class=\"string required\" id=\"query_foo\" name=\"query[foo]\" required=\"required\" type=\"text\" value=\"test\" /></div></form>
      HTML
    end
  end
end

