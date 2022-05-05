require 'omniauth'
require 'eth'

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

      # this will be shown on signature screen
      option :custom_title, 'Hello from Ruby!'

      def request_phase
        form = OmniAuth::Form.new :title => 'Ethereum Authentication', :url => callback_path
        form.html("<span class='custom_title'>#{options.custom_title}</span>")
        options.fields.each do |field|

          # these fields are read-only and will be filled by javascript in the process
          if field == :eth_message
            form.html("<input type='hidden' id='eth_message' name='eth_message' value='#{now}' />")
          else
            form.html("<input type='hidden' id='#{field.to_s}' name='#{field.to_s}' />")
          end
        end

        # the form button will be heavy on javascript, requesting account, nonce, and signature before submission
        form.button 'Sign In'
        path = File.join( File.dirname(__FILE__), 'new_session.js')
        js = File.read(path)
        mod = "<script type='module'>\n#{js}\n</script>"

        form.html(mod)
        form.to_response
      end

      def callback_phase
        address = request.params['eth_address'].downcase
        message = request.params['eth_message']
        signature = request.params['eth_signature']
        signature_pubkey = Eth::Key.personal_recover message, signature
        signature_address = (Eth::Utils.public_key_to_address signature_pubkey).downcase

        unix_time = message.scan(/\d+/).first.to_i
        ten_min = 10 * 60
        return fail!(:invalid_time) unless unix_time + ten_min >= now && unix_time - ten_min <= now

        return fail!(:invalid_credentials) unless signature_address == address

        super
      end

      uid do
        request.params[options.uid_field.to_s]
      end

      private

      def now
        Time.now.utc.to_i
      end
    end
  end
end
