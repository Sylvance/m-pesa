# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'
require 'base64'

module Mobile
  module Pesa
    class StkPushStatus
      attr_reader :checkout_request_id, :short_code

      def self.call(checkout_request_id:, short_code:)
        new(checkout_request_id, short_code).call
      end

      def initialize(checkout_request_id, short_code)
        @checkout_request_id = checkout_request_id
        @short_code = short_code
      end

      def call
        url = URI("https://sandbox.safaricom.co.ke/mpesa/stkpushquery/v1/query")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Post.new(url)
        request["Content-Type"] = 'application/json'
        request["Authorization"] = "Bearer #{token}"
        request.body = JSON.dump(body)

        response = http.request(request)
        parsed_body = JSON.parse(response.read_body)

        if parsed_body.key?("errorCode")
          error = OpenStruct.new(
            error_code: parsed_body["errorCode"],
            error_message: parsed_body["errorMessage"],
            request_id: parsed_body["requestId"]
          )
          OpenStruct.new(result: nil, error: error)
        else
          result = OpenStruct.new(
            merchant_request_id: parsed_body["MerchantRequestID"],
            checkout_request_id: parsed_body["CheckoutRequestID"],
            response_code: parsed_body["ResponseCode"],
            response_description: parsed_body["ResponseDescription"],
            result_desc: parsed_body["ResultDesc"],
            result_code: parsed_body["ResultCode"]
          )
          OpenStruct.new(result: result, error: nil)
        end
      rescue JSON::ParserError => error
        OpenStruct.new(result: nil, error: error)
      end

      private

      def token
        Mobile::Pesa::Authorization.call.result.access_token
      end

      def body
        {
          "BusinessShortCode": short_code,
          "Password": password,
          "Timestamp": timestamp.to_s,
          "CheckoutRequestID": checkout_request_id
        }
      end

      def password
        Base64.strict_encode64("#{short_code}#{Mobile::Pesa.configuration.pass_key}#{timestamp}")
      end

      def timestamp
        Time.now.strftime('%Y%m%d%H%M%S').to_i
      end
    end
  end
end
