module Admino
  module Query
    class Configuration
      class Field
        attr_reader :name

        def initialize(name)
          @name = name.to_sym
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

      attr_reader :fields
      attr_reader :groups
      attr_accessor :starting_scope_callable
      attr_accessor :ending_scope_callable

      def initialize
        @fields = []
        @groups = []
      end

      def add_field(name)
        Field.new(name).tap do |field|
          self.fields << field
        end
      end

      def add_group(name, scopes)
        Group.new(name, scopes).tap do |group|
          self.groups << group
        end
      end
    end
  end
end

