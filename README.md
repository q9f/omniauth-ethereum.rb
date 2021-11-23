# omniauth-ethereum

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/q9f/omniauth-ethereum/Build)](https://github.com/q9f/omniauth-ethereum/actions)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/q9f/omniauth-ethereum)](https://github.com/q9f/omniauth-ethereum/releases)
[![Gem](https://img.shields.io/gem/v/omniauth-ethereum)](https://rubygems.org/gems/omniauth-ethereum)
[![GitHub top language](https://img.shields.io/github/languages/top/q9f/omniauth-ethereum?color=red)](https://github.com/q9f/omniauth-ethereum/pulse)
[![GitHub](https://img.shields.io/github/license/q9f/omniauth-ethereum)](LICENSE)

Authentication Strategy for [OmniAuth](https://github.com/omniauth/omniauth) to authenticate a user with an [Ethereum](https://ethereum.org) account.

### Installation
Add `omniauth-ethereum` to your `Gemspec`.

```ruby
gem 'omniauth-ethereum'
```

### Rails Usage
1. Configure `config/routes.rb` in rails to serve the following routes:

```ruby
Rails.application.routes.draw do
  post '/auth/:provider/callback', to: 'sessions#create'
  post '/auth/ethereum', to: 'sessions#new'
  root to: 'sessions#index'
end
```

2. Create a `SessionsController` for your app that enables an Ethereum authentication path.

```ruby
class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create

  def create
    if request.env['omniauth.auth']
      flash[:notice] = "Logged in"
    else
      flash[:notice] = "Unable to log in"
    end

    redirect_to '/'
  end

  def index
    render inline: "<%= button_to 'Sign in', auth_ethereum_path %>", layout: true
  end
end
```

3. Add an Ethereum provider to your `config/initializers/omniauth.rb` middleware.

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ethereum
end
```

4. Add a `notice` class to your body templates relevant for authentication.

```html
<p class="notice"><%= notice %></p>
```

### Testing
Run the spec tests:

```shell
bundle install
bundle exec rspec --require spec_helper
```

### Demo template
An example Rails app using omniauth-ethereum can be found at [nahurst/omniauth-ethereum-rails](https://github.com/nahurst/omniauth-ethereum-rails).

### License
The gem is available as open-source software under the terms of the [Apache 2.0 License](LICENSE).
