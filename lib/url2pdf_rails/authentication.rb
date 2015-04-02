module Url2pdfRails
  module Authentication

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def authenticate_as_pdf_request!(options = {})
        skip_filter = options.delete(:skip_filter)
        devise_fallback = options.delete(:devise_fallback)

        # should skip any before filters?
        skip_before_filter skip_filter, options if skip_filter.present?

        # skip devise authentication filters if present
        devise_fallback.each do |devise_auth_model|
          devise_auth_method = "authenticate_#{devise_auth_model}!"
          skip_before_filter devise_auth_method.to_sym, options
        end if devise_fallback.present?

        # try authenticate as pdf request and then fallback to devise if supplied
        authenticate_as_icanhazpdf_or_devise = -> do
          if valid_icanhazpdf_request?
            @authenticated_pdf_request = true
            return
          end
          head 401 and return unless devise_fallback.present?
          devise_fallback.each do |devise_auth_model|
            devise_signed_in_method = "#{devise_auth_model}_signed_in?"
            if self.respond_to?(devise_signed_in_method) && self.send(devise_signed_in_method)
              @authenticated_devise_request = true
              return
            end
          end
          head 401
        end
        before_filter authenticate_as_icanhazpdf_or_devise, options
      end
    end

    def authenticated_pdf_request?
      @authenticated_pdf_request || false
    end

    def authenticated_devise_request?
      @authenticated_devise_request || false
    end

    def authenticated_request?
      authenticated_pdf_request? || authenticated_devise_request?
    end

    private

    def valid_icanhazpdf_request?
      return false unless params[:icanhazpdf].present?
      return params[:icanhazpdf] == Rails.configuration.url2pdf_api_key
    end

  end
end
