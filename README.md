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

## Usage

### Query

WIP

### Table

WIP

