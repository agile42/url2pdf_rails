require 'url2pdf_rails/configuration'
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
      Url2pdf::Client.new(Configuration.get_api_key).pdf_from_url(url, options)
    end

  end
end
