require 'showcase'

module Admino
  module Query
    class ScopePresenter < Showcase::Presenter
      def initialize(object, parent, view_context)
        super(object, view_context)
        @parent = parent
      end

      def link(*args)
        @parent.scope_link(object, *args)
      end
    end
  end
end

