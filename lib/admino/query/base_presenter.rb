require 'showcase'

module Admino
  module Query
    class BasePresenter < Showcase::Presenter
      presents_collection :filter_groups
      presents :sorting

      def form(options = {}, &block)
        h.form_for(
          self,
          options.reverse_merge(default_form_options),
          &block
        )
      end

      def simple_form(options = {}, &block)
        h.simple_form_for(
          self,
          options.reverse_merge(default_form_options),
          &block
        )
      end

      def default_form_options
        {
          as: :query,
          method: :get,
          url: h.request.fullpath
        }
      end
    end
  end
end

