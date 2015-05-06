require 'rails_helper'

describe Url2pdfRails::PdfGeneration, :type => :controller do

  let(:api_key) { '123456abc' }
  let(:rails_config) { double("rails_config") }

  before(:each) do
    allow(rails_config).to receive(:url2pdf_api_key).and_return(api_key)
    allow(Rails).to receive(:configuration).and_return(rails_config)
  end

  describe 'generate and render(send to browser) a pdf by calling render directly from a controller' do
    controller(ActionController::Base) do
      def report
        render_pdf_from params[:report_url], {filename: params[:filename]}
      end
    end

    before(:each) do
      routes.draw do
        get "report" => "anonymous#report", as: :report
      end
    end

    context 'successful pdf generation request', vcr: {cassette_name: 'successful_pdf_generation', record: :new_episodes} do
      let(:filename) { 'my_report.pdf' }

      before(:each) do
        params = {report_url: 'http://google.com'}
        params.merge!(filename: filename) if filename.present?
        get :report, params
      end

      it 'sends it as pdf content type' do
        expect(response.headers["Content-Type"]).to eq "application/pdf"
      end

      context 'options supplied' do
        it 'sets the filename to the one supplied' do
          expect(response.headers["Content-Disposition"]).to eq "attachment; filename=\"my_report.pdf\""
        end
      end

      context 'no filename supplied' do
        let(:filename) { nil }

        it 'sets the filename to the one supplied' do
          expect(response.headers["Content-Disposition"]).to eq "attachment; filename=\"#{Date.today.to_s(:number)}.pdf\""
        end
      end
    end

    context 'failed pdf generation request', vcr: {cassette_name: 'failed_pdf_generation'} do
      it 'raises an error describing the return code and body returned from the pdf service' do
        expect { get :report, report_url: 'htp:/bad.url', format: 'pdf' }.to raise_error
      end
    end
  end

  describe 'generate pdf by including module and calling get_pdf_from directly' do
    subject { Class.new.include(Url2pdfRails::PdfGeneration).new }

    context 'successful pdf generation request', vcr: {cassette_name: 'successful_pdf_generation'} do
      let(:url) { 'http://google.com' }

      it 'generates pdf and returns http response' do
        response = subject.get_pdf_from(url)
        expect(response.code).to eq(200)
        expect(response.headers['Content-Type']).to eq "application/pdf"
      end

      context 'server options have been configured in rails env' do
        let(:alternate_server_url) { "http://icanhazpdf.dev/generate_url" }
        let(:timeout_override) { 1000 }

        before(:each) do
          allow(rails_config).to receive(:url2pdf_server_url).and_return(alternate_server_url)
          allow(rails_config).to receive(:url2pdf_timeout).and_return(timeout_override)
          client = Url2pdf::Client.new(api_key)
          allow(Url2pdf::Client).to receive(:new).and_return(client)
        end

        it 'uses the configured server settings' do
          subject.get_pdf_from(url)
          expect(Url2pdf::Client).to have_received(:new).with(api_key, {server_url: alternate_server_url, timeout: timeout_override})
        end
      end
    end

    context 'failed pdf generation request', vcr: {cassette_name: 'failed_pdf_generation'} do
      let(:url) { 'htp:/bad.url' }

      it 'generates pdf and returns http response with error message' do
        response = subject.get_pdf_from(url)
        expect(response.code).to eq(400)
        expect(response.headers['Content-Type']).to eq "text/html;charset=utf-8"
      end
    end
  end
end
