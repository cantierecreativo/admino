# Admino

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

## Installation

Add this line to your application's Gemfile:

    gem 'admino'

And then execute:

    $ bundle

## Admino::Query::Base

A subclass of `Admino::Query::Base` represents a [Query object](http://martinfowler.com/eaaCatalog/queryObject.html), that is, an object responsible for returning a result set (ie. an `ActiveRecord::Relation`) based on business rules (ie. action params).

Given a `Task` model with the following scopes:

```ruby
class Task < ActiveRecord::Base
  scope :text_matches, ->(text) { where(...) }

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }

  scope :by_due_date, ->(direction) { order(due_date: direction) }
  scope :by_title, ->(direction) { order(title: direction) }
end
```

The following `TasksQuery` class can be created:

```ruby
class TasksQuery < Admino::Query::Base
  starting_scope { ProjectTask.all }

  field :text_matches
  filter_by :status, [:completed, :pending]
  sorting :by_due_date, :by_title
end
```

Every query object can declare:

* a **starting scope**, that is, the scope that will start the filtering/ordering chain;
* a set of **search fields**, which represent model scopes that require an input to filter the result set;
* a set of **filtering groups**, each of which is composed by a set of scopes that take no argument;
* a set of **sorting scopes** that take a sigle argument (`:asc` or `:desc`) and thus are able to order the result set in both directions;

Each query object instance gets initialized with a hash of params. The `#scope` method will then perform the chaining of the scopes based on the given params, returning the final result set:

```ruby
params = {
  query: {
    text_matches: 'ASAP'
  },
  status: 'pending',
  sorting: 'by_title',
  sort_order: 'desc'
}

tasks = TasksQuery.new(params).scope
```

As you may have guessed, query objects can be great companions to index controller actions:

```ruby
class ProjectTasksController < ApplicationController
  def index
    @query = TasksQuery.new(params)
    @project_tasks = @query.scope
  end
end
```

But that's not all.

### Presenting search form and filters to the user

Admino also offers a [Showcase presenter](https://github.com/stefanoverna/showcase) that makes it really easy to generate search forms and filtering links:

```erb
<%# instanciate the the query object presenter %>
<% query = present(@query) %>

<%# generate the search form %>
<%= query.form do |q| %>
  <p>
    <%= q.label :text_matches %>
    <%= q.text_field :text_matches %>
  </p>
  <p>
    <%= q.submit %>
  </p>
<% end %>

<%# generate the filtering links %>
<% query.filter_groups.each do |filter_group| %>
  <h6><%= filter_group.name %></h6>
  <ul>
    <% filter_group.scopes.each do |scope| %>
      <li>
        <%= filter_group.scope_link(scope) %>
      <li>
    <% end %>
  </ul>
<% end %>
```

The great thing is that the search form gets automatically filled in with the last input the user submitted, and a CSS class `is-active` gets added to the currently active filter scopes.

If a particular filter has been clicked and is now active, it is possible to deactivate it by clicking it again.

### Simple Form support

The presenter also offers a `#simple_form` method to make it work with [Simple Form](https://github.com/plataformatec/simple_form) out of the box.

### I18n

To localize the search form labels, as well as the group filter names and scope links, please refer to the following YAML file:

```yaml
en:
  query:
    attributes:
      tasks_query:
        text_matches: 'Contains text'
    filter_groups:
      tasks_query:
        status:
          name: 'Filter by status'
          scopes:
            completed: 'Completed'
            pending: 'Pending'
```

### Output customisation

The query object and its presenter implement a number of additional methods and optional arguments that allow a great amount of flexibility: please refer to the tests to see all the possibile customisations available.

#### Overwriting the starting scope

Suppose you have to filter the tasks based on the `@current_user` work group. You can easily provide an alternative starting scope from the controller passing it as an argument to the `#scope` method:

```ruby
def index
  @query = TasksQuery.new(params)
  @project_tasks = @query.scope(@current_user.team.tasks)
end
```

### Default sortings

#### Coertions

Admino can perform automatic coertions from a param string input to the type needed by the model named scope:

```ruby
class TasksQuery < Admino::Query::Base
  # ...
  field :due_date_from, coerce: :to_date
  field :due_date_to, coerce: :to_date
end
```
The following coertions are available:

* `:to_boolean`
* `:to_constant`
* `:to_date`
* `:to_datetime`
* `:to_decimal`
* `:to_float`
* `:to_integer`
* `:to_symbol`
* `:to_time`

If a specific coercion cannot be performed with the provided input, the scope won't be chained.

Please see the [`Coercible::Coercer::String`](https://github.com/solnic/coercible/blob/master/lib/coercible/coercer/string.rb) class for details.

### Ending the scope chain

It's very common ie. to paginate the result set. `Admino::Query::Base` DSL makes it easy to append any scope to the end of the chain:

```ruby
class TasksQuery < Admino::Query::Base
  ending_scope { |q| page(q.params[:page]) }
end
```

## Admino::Table::Presenter

WIP

