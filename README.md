![Admino Logo](https://raw.github.com/cantierecreativo/admino/master/logo.jpg)

[![Gem Version](https://badge.fury.io/rb/admino.png)](http://badge.fury.io/rb/admino)
[![Build Status](https://travis-ci.org/cantierecreativo/admino.png?branch=v0.0.1)](https://travis-ci.org/cantierecreativo/admino)
[![Coverage Status](https://coveralls.io/repos/cantierecreativo/admino/badge.png?branch=master)](https://coveralls.io/r/cantierecreativo/admino?branch=master)
[![Code Climate](https://codeclimate.com/github/cantierecreativo/admino.png)](https://codeclimate.com/github/cantierecreativo/admino)

A minimal, object-oriented solution to generate Rails administrative index views. Through query objects and presenters, it features a customizable table generator and search forms with filtering/sorting.

## The philosophy behind it

The Rails ecosystem has many [full-fledged solutions to generate administrative interfaces](https://www.ruby-toolbox.com/categories/rails_admin_interfaces).

Although these tools are very handy to bootstrap a project quickly, they all obey the [80%-20% rule](http://en.wikipedia.org/wiki/Pareto_principle) and tend to be very invasive, often mixing up different concerns on a single responsibility level, thus making tests unbelievably difficult to setup and write.

A time comes when these all-encompassing tools get in the way. And that will be the moment where all the cumulated saved time will be wasted to solve a single, trivial problem with ugly workarounds and [epic facepalms](http://i.imgur.com/ghKDGyv.jpg).

So yes, if you're starting a small, short-lived project, go ahead with them, it will be fine! If you're building something that's more valuable or is meant to last longer, there are better alternatives.

### A modular approach to the problem

The great thing is that you don't need to write a lot of code to get a more maintainable and modular administrative area.
Gems like [Inherited Resources](https://github.com/josevalim/inherited_resources) and [Simple Form](https://github.com/plataformatec/simple_form), combined with [Rails 3.1+ template-inheritance](http://railscasts.com/episodes/269-template-inheritance) already give you ~90% of the time-saving features and the same super-DRY, declarative code that administrative interfaces offer, but with a far more relaxed contract.

If a particular controller or view needs something different from the standard CRUD/REST treatment, you can just avoid using those gems in that specific context, and fall back to standard Rails code. No workarounds, no facepalms. It seems easy, right? It is.

So what about Admino? Well, it complements the above-mentioned gems, giving you the the missing ~10%: a fast way to generate administrative index views.

## Demo

To better illustrate how to create a 100%-custom, super-DRY administrative interface using Admino and the  aforementioned gems, we prepared a [repo with a sample Rails project](https://github.com/cantierecreativo/admino-example) you can take a look. The app is browsable at [http://admino-example.herokuapp.com](http://admino-example.herokuapp.com), and features a Bootstrap 3 theme.

## Installation

Add this line to your application's Gemfile:

    gem 'admino'

And then execute:

    $ bundle

## Admino::Query::Base

`Admino::Query::Base` implements the [Query object](http://martinfowler.com/eaaCatalog/queryObject.html) pattern, that is, an object responsible for returning a result set (ie. an `ActiveRecord::Relation`) based on business rules.

Given a `Task` model, we can generate a `TasksQuery` query object subclassing `Admino::Query::Base`:

```ruby
class TasksQuery < Admino::Query::Base
end
```

Each query object gets initialized with a hash of params, and features a `#scope` method that returns the filtered/sorted result set. As you may have guessed, query objects can be great companions to index actions:

```ruby
class TasksController < ApplicationController
  def index
    @query = TasksQuery.new(params)
    @tasks = @query.scope
  end
end
```

### Building the query itself

You can specify how a `TaskQuery` must build a result set through a simple DSL.

#### `starting_scope`

The `starting_scope` method is in charge of defining the scope that will start the filtering/ordering chain:

```ruby
class TasksQuery < Admino::Query::Base
  starting_scope { Task.all }
end

Task.create(title: 'Low priority task')

TaskQuery.new.scope.count # => 1
```

#### `search_field`

Once you define the following field:

```ruby
class TasksQuery < Admino::Query::Base
  # ...
  search_field :title_matches
end
```

The `#scope` method will check the presence of the `params[:query][:title_matches]` key. If it finds it, it will augment the query with a named scope called `:title_matches`, expected to be found within the `Task` model. The scope needs to accept an argument.

```ruby
class Task < ActiveRecord::Base
  scope :title_matches, ->(text) {
    where('title ILIKE ?', "%#{text}%")
  }
end

Task.create(title: 'Low priority task')
Task.create(title: 'Fix me ASAP!!1!')

TaskQuery.new.scope.count # => 2
TaskQuery.new(query: { title_matches: 'ASAP' }).scope.count # => 1
```

You can provide a default value with the `default` option:

```ruby
class TasksQuery < Admino::Query::Base
  # ...
  search_field :title_matches, default: 'TODO'
end
```

#### `filter_by`

```ruby
class Task < ActiveRecord::Base
  enum :status, [:pending, :completed, :archived]
  scope :title_matches, ->(text) {
    where('title ILIKE ?', "%#{text}%")
  }
end

class TasksQuery < Admino::Query::Base
  # ...
  filter_by :status, [:completed, :pending]
  filter_by :deleted, [:with_deleted]
  filter_by :status, Task.statuses.keys
end
```

Just like a search field, with a declared filter group the `#scope` method will check the presence of a `params[:query][:status]` key. If it finds it (and its value corresponds to one of the declared scopes) it will augment the query with the scope itself:

```ruby
class Task < ActiveRecord::Base
  scope :completed, -> { where(completed: true) }
  scope :pending,   -> { where(completed: false) }
end

Task.create(title: 'First task', completed: true)
Task.create(title: 'Second task', completed: true)
Task.create(title: 'Third task', completed: false)

TaskQuery.new.scope.count # => 3
TaskQuery.new(query: { status: 'completed' }).scope.count # => 2
TaskQuery.new(query: { status: 'pending' }).scope.count # => 1
TaskQuery.new(query: { status: 'foobar' }).scope.count # => 3
```

You can include a "reset" scope with the `include_empty_scope` option, and provide a default scope with the `default` option:

```ruby
class TasksQuery < Admino::Query::Base
  # ...
  filter_by :time, [:last_month, :last_week],
            include_empty_scope: true,
            default: :last_week
end
```

#### `sorting`

```ruby
class TasksQuery < Admino::Query::Base
  # ...
  sorting :by_due_date, :by_title
end
```

Once you declare some sorting scopes, the query object looks for a `params[:sorting]` key. If it exists (and corresponds to one of the declared scopes), it will augment the query with the scope itself. The model named scope will be called passing an argument that represents the direction of sorting (`:asc` or `:desc`).

The direction passed to the scope will depend on the value of `params[:sort_order]`, and will default to `:asc`:

```ruby
class Task < ActiveRecord::Base
  scope :by_due_date, ->(direction) { order(due_date: direction) }
  scope :by_title, ->(direction) { order(title: direction) }
end

expired_task = Task.create(due_date: 1.year.ago)
future_task = Task.create(due_date: 1.week.since)

TaskQuery.new(sorting: 'by_due_date', sort_order: 'desc').scope # => [ future_task, expired_task ]
TaskQuery.new(sorting: 'by_due_date', sort_order: 'asc').scope  # => [ expired_task, future_task ]
TaskQuery.new(sorting: 'by_due_date').scope                     # => [ expired_task, future_task ]
```

#### `ending_scope`

It's very common ie. to paginate a result set. The block declared in the `ending_scope` block will be always appended to the end of the chain:

```ruby
class TasksQuery < Admino::Query::Base
  ending_scope { |q| page(q.params[:page]) }
end
```

### Inspecting the query state

A query object supports various methods to inspect the available search fields, filters and sortings, and their state:

```ruby
query = TaskQuery.new
query.search_fields  # => [ #<Admino::Query::SearchField>, ... ]
query.filter_groups  # => [ #<Admino::Query::FilterGroup>, ... ]

search_field = query.search_field_by_name(:title_matches)

search_field.name      # => :title_matches
search_field.present?  # => true
search_field.value     # => 'ASAP'

filter_group = query.filter_group_by_name(:status)

filter_group.name                        # => :status
filter_group.scopes                      # => [ :completed, :pending ]
filter_group.active_scope                # => :completed
filter_group.is_scope_active?(:pending)  # => false

sorting = query.sorting                  # => #<Admino::Query::Sorting>
sorting.scopes                           # => [ :by_title, :by_due_date ]
sorting.active_scope                     # => :by_due_date
sorting.is_scope_active?(:by_title)      # => false
sorting.ascending?                       # => true
```

### Presenting search form and filters to the user

Admino offers some helpers that make it really easy to generate search forms and filtering links:

```erb
<%# generate the search form %>
<%= search_form_for(query) do |q| %>
  <%# generate inputs from search_fields %>
  <p>
    <%= q.label :title_matches %>
    <%= q.text_field :title_matches %>
  </p>
  <p>
    <%= q.submit %>
  </p>
  
  <%# generate inputs from filter_by %>
  <p>
	<%= q.label :status %>
	<%= q.select :status, Task.statuses.keys %>  
  </p>

  <%# if filter_by has only one scope you can use a checkbox %>  
  <p>
    <%= q.check_box :deleted, {}, checked_value: "with_deleted" %>
    <%= q.label :deleted %>
  </p>
<% end %>

<%# generate the filtering links %>
<% filters_for(query) do |filter_group| %>
  <h6><%= filter_group.name %></h6>
  <ul>
    <% filter_group.each_scope do |scope| %>
      <li><%= scope.link %><li>
    <% end %>
  </ul>
<% end %>

<%# generate the sorting links %>
<h6>Sort by</h6>
<ul>
  <% sortings_for(query) do |scope| %>
    <li><%= scope.link %></li>
  <% end %>
</ul>
```
The great thing is that:

* the search form gets automatically filled in with the last input the user submitted
* a `is-active` CSS class gets added to the currently active filter scopes
* if a particular filter link has been clicked and is now active, it is possible to deactivate it by clicking on the link again
* a `is-asc`/`is-desc` CSS class gets added to the currently active sorting scope
* if a particular sorting scope link has been clicked and is now in ascending order, it is possible to make it descending by clicking on the link again

### Simple Form support

If you prefer using [Simple Form](https://github.com/plataformatec/simple_form), please use the `simple_search_form_for` helper instead.

### Output customization

The `#link` methods are very flexible, allowing you to change almost every aspect of the generated links:

```erb
<% filter_group.each_scope do |scope| %>
  <li><%= scope.link 'Custom title',
                     active_class: 'active',
                     class: 'custom-class'
  %><li>
<% end %>
```

Please refer to the tests for the details.

### Overwriting the starting scope

Suppose you have to filter the tasks based on the `@current_user` work group. You can easily provide an alternative starting scope from the controller passing it as an argument to the `#scope` method:

```ruby
def index
  @query = TasksQuery.new(params)
  @project_tasks = @query.scope(@current_user.team.tasks)
end
```

### Coertions

Suppose the presence of a model scope that requires a non-textual argument (ie. a date):

```ruby
class Task < ActiveRecord::Base
  scope :due_date_from, ->(date) { where('due_date >= ?', date) }
end
```

Admino can perform some automatic coertions to the textual parameter it gets, and pass the coerced value to the scope:

```ruby
class TasksQuery < Admino::Query::Base
  search_field :due_date_from, coerce: :to_date
end

query = TaskQuery.new(query: { due_date_from: '2014-03-01' })
query.search_field_by_name(:due_date_from).value # => #<Date Sat, 01 Mar 2014>
```

If a specific coercion cannot be performed with the provided input, the scope won't be chained. The following coertions are available:

* `:to_boolean`
* `:to_constant`
* `:to_date`
* `:to_datetime`
* `:to_decimal`
* `:to_float`
* `:to_integer`
* `:to_symbol`
* `:to_time`

Please see the [`Coercible::Coercer::String`](https://github.com/solnic/coercible/blob/master/lib/coercible/coercer/string.rb) class for details.

### Default sorting

If you need to setup a default sorting, you can pass some optional arguments to the `sorting` declaration:

```ruby
class TasksQuery < Admino::Query::Base
  # ...
  sorting :by_due_date, :by_title,
          default_scope: :by_due_date,
          default_direction: :desc
end
```

### I18n

To localize the search form labels, as well as the group filter names and scope links, please refer to the following YAML file:

```yaml
en:
  query:
    attributes:
      tasks_query:
        title_matches: 'Title contains'
    filter_groups:
      tasks_query:
        status:
          name: 'Filter by status'
          scopes:
            completed: 'Completed'
            pending: 'Pending'
    sorting_scopes:
      task_query:
        by_due_date: 'By due date'
        by_title: 'By title'
```

## Admino::Table::Presenter

Admino offers a `table_for` helper that makes it really easy to generate HTML tables from a set of records:

```erb
<%= table_for(@tasks, class: Task) do |row, record| %>
  <%= row.column :title %>
  <%= row.column :completed do %>
    <%= record.completed ? '✓' : '✗' %>
  <% end %>
  <%= row.column :due_date %>
<% end %>
```

With produces the following output:

```html
<table>
  <thead>
    <tr>
      <th role='title'>Title</th>
      <th role='completed'>Completed</th>
      <th role='due-date'>Due date</th>
    </tr>
  <thead>
  <tbody>
    <tr class='is-even'>
      <td role='title'>Call mum ASAP</td>
      <td role='completed'>✓</td>
      <td role='due-date'>2013-02-04</td>
    </tr>
    <tr class='is-odd'>
      <!-- ... -->
    </tr>
  <tbody>
</table>
```

### Record actions

Often tables need to offer some kind of action associated with the records. The table builder implements the following DSL to support that:

```erb
<%= table_for(@tasks, class: Task) do |row, record| %>
  <%# ... %>
  <%= row.actions do %>
    <%= row.action :show, admin_task_path(record) %>
    <%= row.action :edit, edit_admin_task_path(record) %>
    <%= row.action :destroy, admin_task_path(record), method: :delete %>
  <% end %>
<% end %>
```

```html
<table>
  <thead>
    <tr>
      <!-- ... -->
      <th role='actions'>Actions</th>
    </tr>
  <thead>
  <tbody>
    <tr class='is-even'>
      <!-- ... -->
      <td role='actions'>
        <a href='/admin/tasks/1' role='show'>Show</a>
        <a href='/admin/tasks/1/edit' role='edit'>Edit</a>
        <a href='/admin/tasks/1' role='destroy' data-method='delete'>Destroy</a>
      </td>
    </tr>
  <tbody>
</table>
```

### Sortable columns

If you want to make the table headers sortable, then please create an Admino query object class to define the available sorting scopes.

```ruby
class TaskQuery < Admino::Query::Base
  sorting :by_title, :by_due_date
end
```

You can then pass the query object as a parameter to the table presenter initializer, and associate table columns to specific sorting scopes of the query object using the `sorting` directive:

```erb
<% query = present(@query) %>

<%= table_for(@tasks, class: Task) do |row, record| %>
  <%= row.column :title, sorting: :by_title %>
  <%= row.column :due_date, sorting: :by_due_date %>
<% end %>
```

This generates links that allow the visitor to sort the result set in ascending and descending direction:

```html
<table>
  <thead>
    <tr>
      <th role='title'>
        <a href='/admin/tasks?sorting=by_title&sort_order=desc' class='is-asc'>Title</a>
      </th>
      <th role='due-date'>
        <a href='/admin/tasks?sorting=by_due_date&sort_order=asc'>Due date</a>
      </th>
    </tr>
  <thead>
  <!-- ... -->
</table>
```

### Customizing the output

The `#column` and `#action` methods are very flexible, allowing you to change almost every aspect of the generated table cells:

```erb
<%= table_for(@tasks, class: Task, html: { class: 'table-class' }) do |row, record| %>
  <%= row.column :title, 'Custom title',
                 class: 'custom-class', role: 'custom-role', data: { custom: 'true' },
                 sorting: :by_title, sorting_html_options: { desc_class: 'down' }
  %>
  <%= row.action :show, admin_task_path(record), 'Custom label',
                 class: 'custom-class', role: 'custom-role', data: { custom: 'true' }
  %>
<% end %>
```

If you need more power, you can also subclass `Admino::Table::Presenter`. For each HTML element, there's a set of methods you can override to customize it's appeareance.
Table cells are generated through two collaborator classes: `Admino::Table::HeadRow` and `Admino::Table::ResourceRow`. You can easily replace them with a subclass if you want. To grasp the idea here's an example:

```ruby
class CustomTablePresenter < Admino::Table::Presenter
  private

  def table_html_options
    { class: 'table-class' }
  end

  def tbody_tr_html_options(resource, index)
    { class: 'tr-class' }
  end

  def zebra_css_classes
    %w(one two three)
  end

  def resource_row(resource, view_context)
    ResourceRow.new(resource, view_context)
  end

  def head_row(collection_klass, query, view_context)
    HeadRow.new(collection_klass, query, view_context)
  end

  class ResourceRow < Admino::Table::ResourceRow
    private

    def action_html_options(action_name)
      { class: 'action-class' }
    end

    def show_action_html_options
      { class: 'show-action-class' }
    end

    def column_html_options(attribute_name)
      { class: 'column-class' }
    end
  end

  class HeadRow < Admino::Table::ResourceRow
    def column_html_options(attribute_name)
      { class: 'column-class' }
    end
  end
end
```

```erb
<%= table_for(@tasks, class: Task, presenter: CustomTablePresenter) do |row, record| %>
  <%= row.column :title, 'Custom title',
                 class: 'custom-class', role: 'custom-role', data: { custom: 'true' },
                 sorting: :by_title, sorting_html_options: { desc_class: 'down' }
  %>
  <%= row.action :show, admin_task_path(record), 'Custom label',
                 class: 'custom-class', role: 'custom-role', data: { custom: 'true' }
  %>
<% end %>
```

Please refer to the tests for all the details.

### Inherited resources (and similar)

If your controller actions are generated through [Inherited Resources](https://github.com/josevalim/inherited_resources), then you can always get the URL pointing to the show action with the `resource_path` helper method. Similar helpers [are available for the other REST actions too](https://github.com/josevalim/inherited_resources#url-helpers) (new, edit, destroy).

More in general, if you are able to programmatically generate/obtain the URLs of your row actions, you can subclass `Admino::Table::Presenter` and declare them:

```ruby
class CustomTablePresenter < Admino::Table::Presenter
  private

  def resource_row(resource, view_context)
    ResourceRow.new(resource, view_context)
  end

  class ResourceRow < Admino::Table::ResourceRow
    def show_action_url
      h.resource_url(resource)
    end

    def edit_action_url
      h.edit_resource_url(resource)
    end

    def destroy_action_url
      h.resource_url(resource)
    end

    def destroy_action_html_options
      { method: :delete }
    end
  end
end
```

This will enable you to generate row actions even faster, simply declaring them as arguments to the `#actions` DSL method:

```erb
<%= table_for(@tasks, class: Task, presenter: CustomTablePresenter) do |row, record| %>
  <%# ... %>
  <%= row.actions :show, :edit, :destroy %>
<% end %>
```

### Showcase::Traits::Record

As funny it may sound, it is strongly suggested to pass to the table presenter an array of records which in turn have been already presented. This enables you to use as columns not only the raw attributes of the model, but all the methods defined in the presenter.

Furthermore, if the record presenter includes the `Showcase::Traits::Record` trait, each row of the table will automatically have an unique id attribute thanks to the [`#dom_id` method](https://github.com/stefanoverna/showcase#dom_id).

```ruby
class TaskPresenter < Showcase::Presenter
  include Showcase::Traits::Record

  def truncated_title
    h.truncate(title, length: 50)
  end
end
```

```erb
<% tasks = present_collection(@tasks)

<%= Admino::Table::Presenter.new(tasks, Task, self).to_html do |row, record| %>
  <%= row.column :truncated_title, 'Title' %>
<% end %>
```

```html
<table>
  <thead>
    <th role='truncated-title'>Title</th>
  <thead>
  <tbody>
    <tr id='task_1' class='is-even'>
      <td role='truncated-title'>Call mum ASAP</td>
    </tr>
    <tr id='task_2' class='is-odd'>
      <td role='truncated-title'>Buy some milk</td>
    </tr>
  <tbody>
</table>
```

### I18n

Column titles are generated using the model [`#human_attribute_name`](http://apidock.com/rails/ActiveRecord/Base/human_attribute_name/class) method, so if you already translated the model attribute names, you're good to go. To translate actions, please refer to the following YAML file:

```yaml
en:
  activerecord:
    attributes:
      task:
        title: 'Title'
        due_date: 'Due date'
        completed: 'Completed?'
  table:
    actions:
      task:
        title: 'Actions'
        show: 'Details'
        edit: 'Edit task'
        destroy: 'Delete'
```

## Running tests

Install gems:

```
$ bundle
$ bundle exec appraisal
```

Launch tests:

```
bundle exec appraisal rake
```
