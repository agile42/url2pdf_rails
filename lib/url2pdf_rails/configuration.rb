module Url2pdfRails
  class Configuration

    def self.method_missing(method_sym, *arguments, &block)
      # the first argument is a Symbol, so you need to_s it if you want to pattern match
      if method_sym.to_s =~ /^get_(.*)$/
        get_config_for("url2pdf_#{$1}".to_sym)
      else
        super
      end
    end

    def self.respond_to?(method_sym, include_private = false)
      if method_sym.to_s =~ /^get_(.*)$/
        true
      else
        super
      end
    end

    private

    def self.get_config_for(config_parameter)
      Rails.configuration.respond_to?(config_parameter) ? Rails.configuration.send(config_parameter) : nil
    end
  end
end
