require 'rails_helper'

describe Url2pdfRails::PdfGeneration, :type => :controller do

  let(:api_key) { "123456abc" }
  before(:each) do
    allow(Url2pdfRails::Configuration).to receive(:get_api_key).and_return(api_key)
  end

  controller(ActionController::Base) do
    def report
      render_pdf_from params[:report_url], {filename: params[:filename]}
    end
  end

  describe 'generate and render(send to browser) a pdf by calling render directly from a controller' do
    before(:each) do
      routes.draw do
        get "report" => "anonymous#report", as: :report
      end
    end

    context 'successful pdf generation request', vcr: {cassette_name: 'successful_pdf_generation'} do
      let(:filename) { 'my_report.pdf' }

      before(:each) do
        params = {report_url: 'http://google.com'}
        params.merge!(filename: filename) if filename.present?
        get :report, params
      end

      it 'configures the client with the api key' do
        expect(Url2pdfRails::Configuration).to have_received(:get_api_key)
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
    subject { Class.new.include(Url2pdfRails::PdfGeneration).new.get_pdf_from(url) }

    context 'successful pdf generation request', vcr: {cassette_name: 'successful_pdf_generation'} do
      let(:url) { 'http://google.com' }

      it 'generates pdf and returns http response' do
        expect(subject.code).to eq(200)
        expect(subject.headers['Content-Type']).to eq "application/pdf"
      end
    end

    context 'failed pdf generation request', vcr: {cassette_name: 'failed_pdf_generation'} do
      let(:url) { 'htp:/bad.url' }

      it 'generates pdf and returns http response with error message' do
        expect(subject.code).to eq(400)
        expect(subject.headers['Content-Type']).to eq "text/html;charset=utf-8"
      end
    end
  end
end
