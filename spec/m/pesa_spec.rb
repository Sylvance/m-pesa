# frozen_string_literal: true

RSpec.describe M::Pesa do
  before do
    M::Pesa.configure do |configuration|
      configuration.username = "Azs2KejU1ARvIL5JdJsARbV2gDrWmpOB"
      configuration.password = "hipGvFJbOxri330c"
      configuration.pass_key = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919"
      configuration.short_code = 174379
      configuration.callback_url = "https://ip_address:port/callback"
      configuration.default_description = "Payment of X"
    end
  end

  it "has a version number" do
    expect(M::Pesa::VERSION).not_to be nil
  end

  it "returns an access token on authorization" do
    expect(M::Pesa::Authorization.call.result.access_token).not_to be nil
  end

  it "returns an expires in on authorization" do
    expect(M::Pesa::Authorization.call.result.expires_in).not_to be nil
  end
end
