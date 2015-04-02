require 'spec_helper'

describe Url2pdfRails::Configuration do
  let(:dummy_config)  { double("rails config") }

  before(:each) do
    allow(Rails).to receive(:configuration).and_return(dummy_config)
  end

  describe 'api key' do
    let(:api_key) { 'abc123' }

    subject { Url2pdfRails::Configuration.get_api_key }

    before(:each) do
      allow(dummy_config).to receive(:url2pdf_api_key).and_return(api_key)
    end

    it 'returns the configured value for url2pdf_api_key from the rails env' do
      expect(subject).to eq(api_key)
    end
  end

  describe 'server url' do
    let(:server_url) { 'http://another.server' }

    subject { Url2pdfRails::Configuration.get_server_url }

    before(:each) do
      allow(dummy_config).to receive(:url2pdf_server_url).and_return(server_url)
    end

    it 'returns the configured value for url2pdf_server_url from the rails env' do
      expect(subject).to eq(server_url)
    end
  end


end
