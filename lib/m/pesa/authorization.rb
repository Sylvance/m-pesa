require 'uri'
require 'net/http'
require 'openssl'
require 'ostruct'
require 'json'

module M
  module Pesa
    class Authorization
      def initialize; end

      def self.call
        url = URI("https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials")

        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE

        request = Net::HTTP::Get.new(url)
        request.basic_auth(M::Pesa.configuration.username, M::Pesa.configuration.password)

        response = http.request(request)
        parsed_body = JSON.parse(response.read_body)

        if parsed_body.key?("errorCode")
          error = OpenStruct.new(error_code: parsed_body["errorCode"], error_message: parsed_body["errorMessage"])
          OpenStruct.new(result: nil, error: error)
        else
          result = OpenStruct.new(access_token: parsed_body["access_token"], expires_in: parsed_body["expires_in"])
          OpenStruct.new(result: result, error: nil)
        end
      rescue JSON::ParserError => error
        OpenStruct.new(result: nil, error: error)
      end
    end
  end
end
