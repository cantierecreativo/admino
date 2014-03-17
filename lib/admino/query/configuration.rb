module Admino
  module Query
    class Configuration
      class Field
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

      class Group
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

      attr_reader :fields
      attr_reader :groups
      attr_reader :sorting
      attr_accessor :starting_scope_callable
      attr_accessor :ending_scope_callable

      def initialize
        @fields = []
        @groups = []
      end

      def add_field(name, options = {})
        Field.new(name, options).tap do |field|
          self.fields << field
        end
      end

      def add_group(name, scopes)
        Group.new(name, scopes).tap do |group|
          self.groups << group
        end
      end

      def add_sorting_scopes(scopes, options = {})
        @sorting = Sorting.new(scopes, options)
      end
    end
  end
end

