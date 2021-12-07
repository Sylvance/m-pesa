# frozen_string_literal: true

require_relative "pesa/authorization"
require_relative "pesa/c2b_via_paybill_number"
require_relative "pesa/c2b_via_till_number"
require_relative "pesa/stk_push_via_paybill_number"
require_relative "pesa/stk_push_via_till_number"
require_relative "pesa/version"
require 'ostruct'

module M
  module Pesa
    class Error < StandardError; end

    def self.configuration
      @configuration ||= OpenStruct.new(
        username: nil,
        password: nil,
        pass_key: nil,
        short_code: nil,
        callback_url: nil,
        default_description: nil
      )
    end

    def self.configure
      yield(configuration)
    end
  end
end