require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module M
  module Pesa
    class Reversal
      attr_reader :amount, :phone_number, :till_number

      def self.call(amount:, phone_number: nil, till_number: nil, short_code: nil)
        new(amount, phone_number, till_number, short_code).call
      end

      def initialize(amount, phone_number, till_number, short_code)
        @amount = amount
        @phone_number = phone_number
        @till_number = till_number
        @short_code = short_code
      end

      def call
        url = URI("https://sandbox.safaricom.co.ke/mpesa/reversal/v1/request")

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
          "Initiator": "",
          "SecurityCredential": "",
          "CommandID": "TransactionReversal",
          "TransactionID": "",
          "Amount": amount,
          "ReceiverParty": "",
          "RecieverIdentifierType": "4",
          "ResultURL": "",
          "QueueTimeOutURL": "",
          "Remarks": "",
          "Occasion": ""
        }
      end

      def password
        Base64.strict_encode64("#{till_number}#{M::Pesa.configuration.pass_key}#{timestamp}")
      end

      def timestamp
        Time.now.strftime('%Y%m%d%H%M%S').to_i
      end
    end
  end
end
