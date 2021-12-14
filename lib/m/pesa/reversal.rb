# frozen_string_literal: true

require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'
require 'base64'

module M
  module Pesa
    class Reversal
      attr_reader :amount, :transaction_id, :short_code

      def self.call(amount:, transaction_id: nil, short_code: nil)
        new(amount, transaction_id, short_code).call
      end

      def initialize(amount, transaction_id, short_code)
        @amount = amount
        @transaction_id = transaction_id
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
          error = OpenStruct.new(
            error_code: parsed_body["errorCode"],
            error_message: parsed_body["errorMessage"],
            request_id: parsed_body["requestId"]
          )
          OpenStruct.new(result: nil, error: error)
        else
          result = OpenStruct.new(
            originator_converstion_id: parsed_body["OriginatorConverstionID"],
            response_code: parsed_body["ResponseCode"],
            response_description: parsed_body["ResponseDescription"]
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
          "Initiator": "M-pesa Gem",
          "SecurityCredential": security_credential,
          "CommandID": "TransactionReversal",
          "TransactionID": transaction_id,
          "Amount": amount,
          "ReceiverParty": short_code,
          "RecieverIdentifierType": "4",
          "Remarks": remarks,
          "QueueTimeOutURL": M::Pesa.configuration.queue_time_out_url,
          "ResultURL": M::Pesa.configuration.result_url,
          "Occasion": occasion
        }
      end

      def security_credential
        cert = OpenSSL::X509::Certificate.new(file_data)
        key = cert.public_key

        Base64.strict_encode64(key.public_encrypt(password))
      end

      def file_data
        file = File.open(cert_file_path)
        data = file.read
        file.close

        data
      end

      def cert_file_path
        File.join(File.dirname(__FILE__), file_path)
      end

      def file_path
        return 'certificates/SandboxCertificate.cer' if M::Pesa.configuration.enviroment == 'sandbox'
        return 'certificates/ProductionCertificate.cer' if M::Pesa.configuration.enviroment == 'production'
      end

      def password
        Base64.strict_encode64("#{short_code}#{M::Pesa.configuration.pass_key}#{timestamp}")
      end

      def timestamp
        Time.now.strftime('%Y%m%d%H%M%S').to_i
      end
    end
  end
end
