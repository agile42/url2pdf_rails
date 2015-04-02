require 'rails_helper'

describe Url2pdfRails::Authentication, :type => :controller do

  controller(ActionController::Base) do
    before_filter :authenticate_admin! # probably in application controller

    authenticate_as_pdf_request! only: [:report], devise_fallback: [:admin, :blah]

    def index
      render text: "dummy route"
    end

    def report
      render text: "dummy report route"
    end

    def authenticate_admin! # stub for devise auth method
    end

    def admin_signed_in? # stub for devise auth method
    end
  end

  describe 'authenticate as pdf request' do

    before(:each) do
      routes.draw do
        get "index" => "anonymous#index"
        get "report" => "anonymous#report"
      end

      allow(subject).to receive(:authenticate_admin!)
    end

    describe 'skip devise filters' do
      context 'action which is not specified in options' do
        it 'still runs the before filter' do
          get :index
          expect(subject).to have_received(:authenticate_admin!)
        end
      end

      context 'action which is specified in options' do
        it 'skips the filter requested' do
          get :report
          expect(subject).not_to have_received(:authenticate_admin!)
        end
      end
    end

    describe 'devise authentication fallback' do
      context 'devise fallback model specified as admin' do
        context 'action which is specified in the options' do
          let(:api_key) { 'apikey1234567890' }

          before(:each) do
            Rails.configuration.url2pdf_api_key = api_key
          end

          context 'valid pdf request' do
            it 'completes report action' do
              get :report, icanhazpdf: api_key
              expect(response.code).to eq("200")
            end

            it 'authenticated pdf request is true' do
              get :report, icanhazpdf: api_key
              expect(subject.authenticated_pdf_request?).to be true
            end

            it 'authenticated request is true' do
              get :report, icanhazpdf: api_key
              expect(subject.authenticated_request?).to be true
            end
          end

          context 'invalid pdf request' do
            it 'returns 401 unauthorized' do
              get :report, icanhazpdf: "not_a_valid_api_key"
              expect(response.code).to eq("401")
            end

            it 'authenticated pdf request is false' do
              get :report, icanhazpdf: "not_a_valid_api_key"
              expect(subject.authenticated_pdf_request?).to be false
            end

            it 'authenticated request is false' do
              get :report, icanhazpdf: "not_a_valid_api_key"
              expect(subject.authenticated_request?).to be false
            end

            context 'devise admin is signed in' do
              before(:each) do
                allow(subject).to receive(:admin_signed_in?).and_return(true)
              end

              it 'falls back to devise and completes action if devise auth is successful' do
                get :report, icanhazpdf: "not_a_valid_api_key"
                expect(subject).to have_received(:admin_signed_in?)
                expect(response.code).to eq("200")
              end

              it 'authenticated pdf request is false' do
                get :report, icanhazpdf: "not_a_valid_api_key"
                expect(subject.authenticated_pdf_request?).to be false
              end

              it 'authenticated devise request is true' do
                get :report, icanhazpdf: "not_a_valid_api_key"
                expect(subject.authenticated_devise_request?).to be true
              end

              it 'authenticated request is true' do
                get :report, icanhazpdf: "not_a_valid_api_key"
                expect(subject.authenticated_request?).to be true
              end
            end
          end
        end
      end
    end

    describe 'authenticated request?' do
      it 'is available as a method in the controller' do
        expect(subject.respond_to?(:authenticated_request?)).to be true
      end

      it 'defaults to false' do
        expect(subject.authenticated_request?).to be false
      end
    end

  end

end
