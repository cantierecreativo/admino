require 'active_support/core_ext/module/delegation'

require "admino/version"
require "admino/query"
require "admino/table"
require "admino/action_view_extension"

module Admino
end

ActiveSupport.on_load(:action_view) do
  include Admino::ActionViewExtension
end

