RSpec.describe OmniAuth::Strategies::Ethereum do
  let(:app) do
    Rack::Builder.new do |b|
      b.use Rack::Session::Cookie, :secret => 'abc123'
      b.use OmniAuth::Strategies::Ethereum
      b.run lambda { |_env| [200, {}, ['Not Found']] }
    end.to_app
  end

  before(:each) do
    allow(Time).to receive(:now).and_return(
      Time.at(1636680000, in: '+00:00'))
  end

  context 'request phase' do
    before(:each) { post '/auth/ethereum' }

    it 'displays a form' do
      expect(last_response.status).to eq(200)
      expect(last_response.body).to be_include('<form')
    end

    it 'has the callback as the action for the form' do
      expect(last_response.body).to be_include("action='/auth/ethereum/callback'")
    end

    it 'has a text field for each of the fields' do
      expect(last_response.body.scan('<input').size).to eq(3)
    end
  end

  context 'callback phase' do
    let(:auth_hash) { last_request.env['omniauth.auth'] }
    let(:eth_message) { "Hello from Ruby! #{Time.now.utc.to_i}" }
    let(:eth_address) { '0xf39fd6e51aad88f6f4ce6ab8827279cfffb92266' }
    let(:eth_signature) { '0x362b5463470038a62c9d0652712539bab36f9c74914f5a05475a8e2e84a9719e396ab201e62d0c92da7de91a3a4a61a221c3f4e0b528b709ecdaa22ee8391d0f1c' }

    describe 'with varied nonces' do
      before do
        post '/auth/ethereum/callback',
          :eth_message => eth_message,
          :eth_address => eth_address,
          :eth_signature => eth_signature
      end

      context 'with nonce from too long ago' do
        let(:eth_message) { "Hello from Ruby! #{Time.now.utc.to_i - 11 * 60}" }

        it 'fails with invalid nonce' do
          expect(last_response.status).to eq(302)
          expect(last_response.location).to eq('/auth/failure?message=invalid_nonce&strategy=ethereum')
        end
      end

      context 'with nonce from too far in future' do
        let(:eth_message) { "Hello from Ruby! #{Time.now.utc.to_i + 11 * 60}" }

        it 'fails with invalid nonce' do
          expect(last_response.status).to eq(302)
          expect(last_response.location).to eq('/auth/failure?message=invalid_nonce&strategy=ethereum')
        end
      end
    end

    context 'with mismatching address' do
      before do
        post '/auth/ethereum/callback',
          :name => 'Example User',
          :email => 'user@example.com',
          :eth_message => eth_message,
          :eth_address => '0xBADDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD',
          :eth_signature => '0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
      end

      it 'fails with invalid credentials' do
        expect(last_response.status).to eq(302)
        expect(last_response.location).to eq('/auth/failure?message=invalid_credentials&strategy=ethereum')
      end
    end

    context 'with default options' do
      before do
        post '/auth/ethereum/callback',
          :eth_message => eth_message,
          :eth_address => eth_address,
          :eth_signature => eth_signature
      end

      it 'sets the uid to the address' do
        expect(last_response.status).to eq(200)
        expect(auth_hash.uid).to eq(eth_address)
      end
    end

  end
end
