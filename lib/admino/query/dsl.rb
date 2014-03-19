module Admino
  module Query
    module Dsl
      def config
        @config ||= Admino::Query::Configuration.new
      end

      def field(name, options = {})
        config.add_field(name, options)

        define_method name do
          field_by_name(name).value
        end
      end

      def filter_by(name, scopes)
        config.add_filter_group(name, scopes)
      end

      def sorting(*args)
        options = args.extract_options!
        config.add_sorting_scopes(args, options)
      end

      def starting_scope(&block)
        config.starting_scope_callable = block
      end

      def ending_scope(&block)
        config.ending_scope_callable = block
      end
    end
  end
end

