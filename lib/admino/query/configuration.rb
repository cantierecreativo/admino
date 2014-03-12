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
      attr_accessor :starting_scope
      attr_accessor :ending_scope

      def initialize
        @fields = []
        @groups = []
        @ending_scope = ->(query) { where(nil) }
      end

      def add_field(name)
        self.fields << Field.new(name)
      end

      def add_group(name, scopes)
        self.groups << Group.new(name, scopes)
      end
    end
  end
end

