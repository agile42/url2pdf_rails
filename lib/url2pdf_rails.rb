require 'url2pdf_rails/version'
require 'url2pdf_rails/authentication'
require 'url2pdf_rails/pdf_generation'

ActiveSupport.on_load(:action_controller) do
  include Url2pdfRails::Authentication
  include Url2pdfRails::PdfGeneration
end
