require 'url2pdf_rails/configuration'

module Url2pdfRails
  module Authentication

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def authenticate_as_pdf_request!(options = {})
        skip_filter = options.delete(:skip_filter)
        devise_auth_model = options.delete(:devise_auth_model)

        # should skip an existing authentication filter?
        skip_before_filter skip_filter, options if skip_filter.present?

        # add our filter for authentication
        authenticate_as_icanhazpdf_or_devise = -> do
          devise_auth_model ||= 'user'
          devise_auth_method = "authenticate_#{devise_auth_model}!"
          head 401 unless valid_icanhazpdf_request? || (self.respond_to?(devise_auth_method) && self.send(devise_auth_method))
        end

        before_filter authenticate_as_icanhazpdf_or_devise, options
      end
    end

    private

    def valid_icanhazpdf_request?
      return false unless params[:icanhazpdf].present?
      return params[:icanhazpdf] == Configuration.get_api_key
    end

  end
end
