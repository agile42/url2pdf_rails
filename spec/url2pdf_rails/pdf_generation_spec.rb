require 'rails_helper'

describe Url2pdfRails::PdfGeneration, :type => :controller do

  controller(ActionController::Base) do

    def report
      respond_to do |format|
        format.html do
          render text: "dummy html render"
        end
        format.pdf do
          render_pdf_from "http://google.com"
        end
      end
    end

  end

  describe 'generate and render a pdf' do
    let(:api_key) { "123456abc" }
    let(:dummy_client) { double("client") }
    let(:response) { double("response") }

    before(:each) do
      routes.draw do
        get "report" => "anonymous#report", as: :report
      end

      allow(Url2pdfRails::Configuration).to receive(:get_api_key).and_return(api_key)
      allow(Url2pdf::Client).to receive(:new).and_return(dummy_client)
      allow(dummy_client).to receive(:pdf_from).and_return(response)
      allow(response).to receive(:code).and_return(200)
      allow(response).to receive(:body).and_return("")
    end

    it 'configures the client with the api key' do
      get :report, format: 'pdf'
      expect(Url2pdfRails::Configuration).to have_received(:get_api_key)
    end

    it 'creates a client' do
      get :report, format: 'pdf'
      expect(Url2pdf::Client).to have_received(:new).with(api_key)
    end

    it 'calls generate pdf' do
      get :report, format: 'pdf'
      expect(dummy_client).to have_received(:pdf_from).with("http://google.com", {})
    end
  end

end
