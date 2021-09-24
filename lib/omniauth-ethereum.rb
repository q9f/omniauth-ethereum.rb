require 'omniauth'

module OmniAuth
  module Strategies
    class Ethereum
      include OmniAuth::Strategy

      # ethereum authentication strategy fields
      # `eth_message`: contains a custom string, the request time, and the specific nonce to sign
      # `eth_address`: contains the public Eth::Address of the user's Ethereum account
      # `eth_signature`: contains the signature of the `eth_message` signed by `eth_address`
      option :fields, [:eth_message, :eth_address, :eth_signature]

      # the `eth_address` will be the _fake_ unique identifier for the Ethereum strategy
      option :uid_field, :eth_address

      # the omniauth request phase
      def request_phase

        # helper omniauth form to gather required data
        form = OmniAuth::Form.new :title => "Ethereum Authentication", :url => callback_path
        options.fields.each do |field|

          # these fields are read-only and will be filled by javascript in the process
          form.text_field field.to_s.capitalize.gsub("_", " "), field.to_s, readonly: true, class: field.to_s
        end

        # the form button will be heavy on javascript, requesting account, nonce, and signature before submission
        form.button "Sign-In with Ethereum", class: "eth_connect"
        form.to_response
      end
    end
  end
end
