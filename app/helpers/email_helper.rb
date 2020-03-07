# frozen_string_literal: true

# email helper
module EmailHelper
  def self.formatted_email(email)
    URI.encode_www_form_component(email)
  end
end
