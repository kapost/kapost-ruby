require 'spec_helper'

# I would like to revisit the testing strategy
# Webmocks/fixtures feels a little brittle
describe Kapost::Newsroom do
  let(:instance) { 'app' }
  let(:api_token) { 'fake_token' }
  let(:client) { Kapost::Client.new(:api_token => api_token, :instance => instance) }

  before :each do
  end
end
