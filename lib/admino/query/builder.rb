module Admino
  module Query
    class Builder
      attr_accessor :scope
      attr_reader :context

      def initialize(context, scope)
        @context = context
        @scope = scope
      end

      private

      def method_missing(method, *args)
        if context.respond_to?(method)
          Builder.new(context, context.send(method, scope, *args))
        else
          Builder.new(context, scope.send(method, *args))
        end
      end
    end
  end
end
