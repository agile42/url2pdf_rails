require 'rails_helper'

describe Url2pdfRails::Authentication, :type => :controller do

  controller(ActionController::Base) do
    before_filter :my_filter # typical authentication filter

    authenticate_as_pdf_request! only: [:report], skip_filter: :my_filter, devise_auth_model: 'admin'

    def index
      render text: "dummy route"
    end

    def report
      render text: "dummy report route"
    end

    def authenticate_admin! # stub for devise auth method
    end

    private

    def my_filter # typical authentication filter
    end
  end

  describe 'authenticate as pdf request' do

    before(:each) do
      routes.draw do
        get "index" => "anonymous#index"
        get "report" => "anonymous#report"
      end

      allow(subject).to receive(:my_filter)
    end

    describe 'skip filter' do
      context 'action which is not specified in options' do
        it 'still runs the before filter' do
          get :index
          expect(subject).to have_received(:my_filter)
        end
      end

      context 'action which is specified in options' do
        it 'skips the filter requested' do
          get :report
          expect(subject).not_to have_received(:my_filter)
        end
      end
    end

    describe 'devise authentication fallback' do
      context 'devise user model specified' do
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
          end

          context 'invalid pdf request' do
            it 'returns 401 unauthorized' do
              get :report, icanhazpdf: "not_a_valid_api_key"
              expect(response.code).to eq("401")
            end

            context 'devise user is signed in' do
              before(:each) do
                allow(subject).to receive(:authenticate_admin!).and_return(true)
              end

              it 'falls back to devise and completes action if devise auth is successful' do
                get :report, icanhazpdf: "not_a_valid_api_key"
                expect(response.code).to eq("200")
              end
            end
          end
        end
      end
    end

  end

end
