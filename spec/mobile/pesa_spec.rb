# frozen_string_literal: true

RSpec.describe Mobile::Pesa do
  before do
    Mobile::Pesa.configure do |configuration|
      configuration.consumer_key        = "Azs2KejU1ARvIL5JdJsARbV2gDrWmpOB"
      configuration.consumer_secret     = "hipGvFJbOxri330c"
      configuration.pass_key            = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
      configuration.short_code          = 174379
      configuration.response_type       = "Completed"
      configuration.callback_url        = "https://example.com/callback"
      configuration.queue_time_out_url  = "https://example.com/callback"
      configuration.result_url          = "https://example.com/callback"
      configuration.default_description = "Payment of X"
      configuration.enviroment          = "sandbox"
    end
  end

  it "has a version number" do
    expect(Mobile::Pesa::VERSION).not_to be nil
  end

  it "returns an access token on authorization" do
    expect(Mobile::Pesa::Authorization.call.result.access_token).not_to be nil
  end

  it "returns an expires in on authorization" do
    expect(Mobile::Pesa::Authorization.call.result.expires_in).not_to be nil
  end

  it "can make a b2c payment successfully" do
    response = Mobile::Pesa::B2cPayment.call(
      amount: 10, phone_number: 254791780833, short_code: 174379,
      command_id: 'BusinessPayment', remarks: 'Remarks', occasion: 'Occassion'
    )

    expect(response.error).to be nil
  end

  it "can register urls successfully" do
    response = Mobile::Pesa::RegisterUrls.call(
      short_code: 123454,
      response_type: 'Completed',
      confirmation_url: 'https://www.youtube.com/callback',
      validation_url: 'https://www.youtube.com/callback'
    )

    expect(response.error).to be nil
  end

  it "can reverse a transaction successfully" do
    response = Mobile::Pesa::Reversal.call(
      amount: 10,
      transaction_id: 'asdf',
      short_code: 174379,
      remarks: 'Just a random remark',
      occasion: 'Just a random occassion'
    )

    expect(response.error).to be nil
  end

  it "can simulate a c2b via paybill payment successfully" do
    response = Mobile::Pesa::SimulateC2bViaPaybillNumber.call(
      amount: 20, phone_number: 254791780833, account_number: '1334', pay_bill_number: 174379
    )

    expect(response.error).to be nil
  end

  it "can simulate a c2b via till payment successfully" do
    response = Mobile::Pesa::SimulateC2bViaTillNumber.call(
      amount: 20, phone_number: 254791780833, till_number: 174379
    )

    expect(response.error).to be nil
  end

  it "can get stk push status successfully" do
    response = Mobile::Pesa::StkPushStatus.call(
      checkout_request_id: checkout_request_id, short_code: 174379
    )

    expect(response.error).to be nil
  end

  it "can do an stk push via paybill successfully" do
    response = Mobile::Pesa::StkPushViaPaybillNumber.call(
      amount: 20, phone_number: 254791780833, account_number: '1334', pay_bill_number: 174379
    )

    expect(response.error).to be nil
  end

  it "can do an stk push via till successfully" do
    response = Mobile::Pesa::StkPushViaTillNumber.call(
      amount: 20, phone_number: 254791780833, till_number: 174379
    )

    expect(response.error).to be nil
  end
end
