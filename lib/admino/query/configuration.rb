module Admino
  module Query
    class Configuration
      class SearchField
        attr_reader :name
        attr_reader :coerce_to

        def initialize(name, options = {})
          options.symbolize_keys!
          options.assert_valid_keys(:coerce)

          @name = name.to_sym

          if coerce_to = options[:coerce]
            @coerce_to = coerce_to.to_sym
          end
        end
      end

      class FilterGroup
        attr_reader :name
        attr_reader :scopes

        def initialize(name, scopes)
          @name = name.to_sym
          @scopes = scopes.map(&:to_sym)
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

      def add_filter_group(name, scopes)
        FilterGroup.new(name, scopes).tap do |filter_group|
          self.filter_groups << filter_group
        end
      end

      def add_sorting_scopes(scopes, options = {})
        @sorting = Sorting.new(scopes, options)
      end
    end
  end
end

