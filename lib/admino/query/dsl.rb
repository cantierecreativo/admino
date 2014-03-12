module Admino
  module Query
    module Dsl
      def config
        @config ||= Admino::Query::Configuration.new
      end

      def field(name)
        config.add_field(name)

        define_method name do
          field_by_name(name).value
        end
      end

      def group(name, scopes)
        config.add_group(name, scopes)
      end

      def starting_scope(&block)
        config.starting_scope = block
      end

      def ending_scope(&block)
        config.ending_scope = block
      end

      def i18n_scope
        :query
      end
    end
  end
end

