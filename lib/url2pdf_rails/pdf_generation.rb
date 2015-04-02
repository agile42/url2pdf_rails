require 'url2pdf'

module Url2pdfRails
  module PdfGeneration

    # generate and render a pdf from a url
    def render_pdf_from(url, options = {})
      http_response = get_pdf_from url, options
      raise "Failed to generate pdf:\nCode: #{http_response.code}\nBody:\n#{http_response.body}" unless http_response.code == 200

      filename = options[:filename] || "#{Date.today.to_s(:number)}.pdf"
      send_data http_response, :filename => filename, :type => :pdf
    end

    # generate a pdf and return the http response
    def get_pdf_from(url, options = {})
      server_options = {}
      server_options.merge!(server_url: Rails.configuration.url2pdf_server_url) if Rails.configuration.respond_to?(:url2pdf_server_url)
      server_options.merge!(timeout: Rails.configuration.url2pdf_timeout) if Rails.configuration.respond_to?(:url2pdf_timeout)
      Url2pdf::Client.new(Rails.configuration.url2pdf_api_key, server_options).pdf_from_url(url, options)
    end

  end
end
