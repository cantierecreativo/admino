module Admino
  module Query
    class Configuration
      class SearchField
        attr_reader :name
        attr_reader :options

        def initialize(name, options = {})
          options.symbolize_keys!
          options.assert_valid_keys(
            :coerce,
            :default
          )

          @name = name.to_sym
          @options = options
        end

        def default_value
          options[:default]
        end

        def coerce_to
          if options[:coerce]
            options[:coerce].to_sym
          end
        end
      end

      class FilterGroup
        attr_reader :name
        attr_reader :scopes
        attr_reader :options

        def initialize(name, scopes, options = {})
          options.symbolize_keys!
          options.assert_valid_keys(
            :include_empty_scope,
            :default
          )

          @name = name.to_sym
          @scopes = scopes.map(&:to_sym)
          @options = options
        end

        def include_empty_scope?
          @options.fetch(:include_empty_scope) { false }
        end

        def default_scope
          if options[:default]
            options[:default].to_sym
          end
        end
      end

      class Sorting
        attr_reader :scopes
        attr_reader :default_scope
        attr_reader :default_direction

        def initialize(scopes, options = {})
          options.symbolize_keys!
          options.assert_valid_keys(:default_scope, :default_direction)

          @scopes = scopes.map(&:to_sym)
          @default_scope = if options[:default_scope]
                             options[:default_scope].to_sym
                           end

          @default_direction = if options[:default_direction]
                                 options[:default_direction].to_sym
                               end
        end
      end

      attr_reader :search_fields
      attr_reader :filter_groups
      attr_reader :sorting
      attr_accessor :starting_scope_callable
      attr_accessor :ending_scope_callable

      def initialize
        @search_fields = []
        @filter_groups = []
      end

      def add_search_field(name, options = {})
        SearchField.new(name, options).tap do |search_field|
          self.search_fields << search_field
        end
      end

      def add_filter_group(name, scopes, options = {})
        FilterGroup.new(name, scopes, options).tap do |filter_group|
          self.filter_groups << filter_group
        end
      end

      def add_sorting_scopes(scopes, options = {})
        @sorting = Sorting.new(scopes, options)
      end
    end
  end
end

