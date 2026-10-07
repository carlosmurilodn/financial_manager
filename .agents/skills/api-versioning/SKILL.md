---
name: api-versioning
description: >-
  Implementa o design RESTful API com controle de versão e specs de solicitação. Use ao
  criar APIs, adicionar endpoints API, versionar APIs ou quando o usuário mencionar o
  design REST, JSON API ou API.
license: MIT
compatibility: Ruby 3.3+, Rails 8.1+, RSpec
metadata:
  author: ThibautBaissac
  version: "1.0"
---

# API Versionamento para Rails

## Visão geral

APIs bem estruturadas precisam de controle de versão para compatibilidade com versões anteriores e organização clara.

## Estratégias de versionamento

| Strategy | URL Example | Header Example |
|----------|-------------|----------------|
| URL Path | `/api/v1/users` | - |
| Query Param | `/api/users?version=1` | - |
| Header | `/api/users` | `Accept: application/vnd.api+json; version=1` |
| Accept Header | `/api/users` | `Accept: application/vnd.myapp.v1+json` |

**Recomendado**: controle de versão do caminho de URL (mais comum, mais fácil de entender)

## Configuração rápida

### Rotas

```ruby
# config/routes.rb
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: [:index, :show, :create, :update, :destroy]
      resources :posts, only: [:index, :show, :create]
    end

    # v2 with changes
    namespace :v2 do
      resources :users, only: [:index, :show, :create, :update, :destroy]
    end
  end
end
```

### Estrutura de diretório

```
app/controllers/
├── api/
│   ├── base_controller.rb      # Shared API logic
│   ├── v1/
│   │   ├── base_controller.rb  # V1 base
│   │   ├── users_controller.rb
│   │   └── posts_controller.rb
│   └── v2/
│       ├── base_controller.rb  # V2 base
│       └── users_controller.rb
```

### Controller básico

```ruby
# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    # Skip CSRF for API requests
    skip_before_action :verify_authenticity_token

    # Respond with JSON by default
    respond_to :json

    # Handle common errors
    rescue_from ActiveRecord::RecordNotFound, with: :not_found
    rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
    rescue_from ActionController::ParameterMissing, with: :bad_request

    private

    def not_found(exception)
      render json: { error: exception.message }, status: :not_found
    end

    def unprocessable_entity(exception)
      render json: { errors: exception.record.errors }, status: :unprocessable_entity
    end

    def bad_request(exception)
      render json: { error: exception.message }, status: :bad_request
    end
  end
end
```

### Versão Controller Base

```ruby
# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < Api::BaseController
      # V1-specific configuration
    end
  end
end
```

### Controller de recursos

```ruby
# app/controllers/api/v1/users_controller.rb
module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [:show, :update, :destroy]

      def index
        @users = User.page(params[:page]).per(25)
        render json: {
          data: @users,
          meta: pagination_meta(@users)
        }
      end

      def show
        render json: { data: @user }
      end

      def create
        @user = User.create!(user_params)
        render json: { data: @user }, status: :created
      end

      def update
        @user.update!(user_params)
        render json: { data: @user }
      end

      def destroy
        @user.destroy
        head :no_content
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:name, :email)
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
```

## Formato de resposta

### Resposta JSON padrão

```json
{
  "data": {
    "id": 1,
    "type": "user",
    "attributes": {
      "name": "John Doe",
      "email": "john@example.com",
      "created_at": "2024-01-15T10:30:00Z"
    }
  }
}
```

### Resposta de coleta

```json
{
  "data": [
    { "id": 1, "type": "user", "attributes": { ... } },
    { "id": 2, "type": "user", "attributes": { ... } }
  ],
  "meta": {
    "current_page": 1,
    "total_pages": 10,
    "total_count": 100
  }
}
```

### Resposta de erro

```json
{
  "error": "Record not found",
  "code": "not_found"
}

{
  "errors": {
    "email": ["has already been taken"],
    "name": ["can't be blank"]
  }
}
```

## Testando APIs

### Model de spec de solicitação

```ruby
# spec/requests/api/v1/users_spec.rb
require 'rails_helper'

RSpec.describe 'Api::V1::Users', type: :request do
  let(:headers) { { 'Accept' => 'application/json', 'Content-Type' => 'application/json' } }

  describe 'GET /api/v1/users' do
    let!(:users) { create_list(:user, 3) }

    it 'returns all users' do
      get '/api/v1/users', headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data'].size).to eq(3)
    end

    it 'returns paginated results' do
      get '/api/v1/users', params: { page: 1 }, headers: headers

      expect(json_response['meta']).to include('current_page', 'total_pages')
    end
  end

  describe 'GET /api/v1/users/:id' do
    let(:user) { create(:user) }

    it 'returns the user' do
      get "/api/v1/users/#{user.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response['data']['id']).to eq(user.id)
    end

    context 'when user not found' do
      it 'returns 404' do
        get '/api/v1/users/999999', headers: headers

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'POST /api/v1/users' do
    let(:valid_params) { { user: { name: 'Test', email: 'test@example.com' } } }

    it 'creates a user' do
      expect {
        post '/api/v1/users', params: valid_params.to_json, headers: headers
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    context 'with invalid params' do
      let(:invalid_params) { { user: { name: '', email: '' } } }

      it 'returns validation errors' do
        post '/api/v1/users', params: invalid_params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['errors']).to be_present
      end
    end
  end

  # Helper method
  def json_response
    JSON.parse(response.body)
  end
end
```

## Autenticação API

### Autenticação baseada em token

```ruby
# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    before_action :authenticate_api_user!

    private

    def authenticate_api_user!
      token = request.headers['Authorization']&.split(' ')&.last
      @current_api_user = User.find_by(api_token: token)

      render json: { error: 'Unauthorized' }, status: :unauthorized unless @current_api_user
    end

    def current_api_user
      @current_api_user
    end
  end
end
```

### Autenticação JWT

```ruby
# Using jwt gem
def authenticate_api_user!
  token = request.headers['Authorization']&.split(' ')&.last
  return unauthorized unless token

  payload = JWT.decode(token, Rails.application.secret_key_base).first
  @current_api_user = User.find(payload['user_id'])
rescue JWT::DecodeError
  unauthorized
end

def unauthorized
  render json: { error: 'Unauthorized' }, status: :unauthorized
end
```

## Lista de verificação do fluxo de trabalho

```
API Implementation:
- [ ] Define routes in namespace
- [ ] Create base controller with error handling
- [ ] Create version-specific base controller
- [ ] Create resource controller
- [ ] Add authentication (if needed)
- [ ] Write request specs
- [ ] Document API endpoints
```
