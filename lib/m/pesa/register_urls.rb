require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module M
  module Pesa
    class RegisterUrls
      attr_reader :short_code, :response_type, :confirmation_url, :validation_url

      def self.call(short_code:, response_type:, confirmation_url:, validation_url:)
        new(short_code, response_type, confirmation_url, validation_url).call
      end

      def initialize(short_code, response_type, confirmation_url, validation_url)
        @short_code = short_code
        @response_type = response_type
        @confirmation_url = confirmation_url
        @validation_url = validation_url
      end

      def call
        url = URI("https://sandbox.safaricom.co.ke/mpesa/c2b/v1/registerurl")

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
          error = OpenStruct.new(error_code: parsed_body["errorCode"], error_message: parsed_body["errorMessage"])
          OpenStruct.new(result: nil, error: error)
        else
          result = OpenStruct.new(
            originator_converstion_id: parsed_body["OriginatorConverstionID"],
            conversation_id: parsed_body["conversation_id"],
            response_description: parsed_body["response_description"]
          )
          OpenStruct.new(result: result, error: nil)
        end
      rescue JSON::ParserError => error
        OpenStruct.new(result: nil, error: error)
      end

      private

      def token
        M::Pesa::Authorization.call.result.access_token
      end

      def body
        {
          "ShortCode": M::Pesa.configuration.short_code || short_code,
          "ResponseType": M::Pesa.configuration.response_type || response_type,
          "ConfirmationURL": M::Pesa.configuration.confirmation_url || confirmation_url,
          "ValidationURL": M::Pesa.configuration.validation_url || validation_url
        }
      end
    end
  end
end
