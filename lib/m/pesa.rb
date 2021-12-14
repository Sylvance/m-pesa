# frozen_string_literal: true

require_relative "pesa/authorization"
require_relative "pesa/b2c_payment"
require_relative "pesa/register_urls"
require_relative "pesa/reversal"
require_relative "pesa/simulate_c2b_via_paybill_number"
require_relative "pesa/simulate_c2b_via_till_number"
require_relative "pesa/stk_push_status"
require_relative "pesa/stk_push_via_paybill_number"
require_relative "pesa/stk_push_via_till_number"
require_relative "pesa/version"
require 'ostruct'

module M
  module Pesa
    class Error < StandardError; end

    def self.configuration
      @configuration ||= OpenStruct.new(
        consumer_key: nil,
        consumer_secret: nil,
        pass_key: nil,
        short_code: nil,
        response_type: nil,
        callback_url: nil,
        result_url: nil,
        queue_time_out_url: nil,
        default_description: nil,
        enviroment: nil
      )
    end

    def self.configure
      yield(configuration)
    end
  end
end
