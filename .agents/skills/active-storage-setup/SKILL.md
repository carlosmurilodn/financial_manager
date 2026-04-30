---
name: active-storage-setup
description: >-
  Configura Active Storage para uploads de arquivos com variantes e uploads diretos. Use
  ao adicionar uploads de arquivos, anexos de imagens, armazenamento de documentos,
  geração de miniaturas ou quando o usuário mencionar Active Storage, upload de
  arquivos, anexos ou processamento de imagens.
license: MIT
compatibility: Ruby 3.3+, Rails 8.1+, Active Storage
metadata:
  author: ThibautBaissac
  version: "1.0"
---

# Configuração Active Storage para Rails 8

## Visão geral

Active Storage lida com uploads de arquivos no Rails:
- Armazenamento em nuvem (S3, GCS, Azure) ou disco local
- Variantes de imagens (miniaturas, redimensionamento)
- Uploads diretos do navegador
- Anexos polimórficos

## Início rápido

```bash
# Install Active Storage (if not already)
bin/rails active_storage:install
bin/rails db:migrate

# Add image processing
bundle add image_processing
```

## Configuração

### Serviços de armazenamento

```yaml
# config/storage.yml
local:
  service: Disk
  root: <%= Rails.root.join("storage") %>

test:
  service: Disk
  root: <%= Rails.root.join("tmp/storage") %>

amazon:
  service: S3
  access_key_id: <%= Rails.application.credentials.dig(:aws, :access_key_id) %>
  secret_access_key: <%= Rails.application.credentials.dig(:aws, :secret_access_key) %>
  region: eu-west-1
  bucket: <%= Rails.application.credentials.dig(:aws, :bucket) %>

google:
  service: GCS
  credentials: <%= Rails.root.join("config/gcs-credentials.json") %>
  project: my-project
  bucket: my-bucket
```

### Configuração do ambiente

```ruby
# config/environments/development.rb
config.active_storage.service = :local

# config/environments/production.rb
config.active_storage.service = :amazon
```

## Anexos de model

### Anexo Único

```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_one_attached :avatar

  # With variant defaults
  has_one_attached :avatar do |attachable|
    attachable.variant :thumb, resize_to_limit: [100, 100]
    attachable.variant :medium, resize_to_limit: [300, 300]
  end
end
```

### Vários anexos

```ruby
# app/models/event.rb
class Event < ApplicationRecord
  has_many_attached :photos

  has_many_attached :documents do |attachable|
    attachable.variant :preview, resize_to_limit: [200, 200]
  end
end
```

## Fluxo de trabalho TDD

```
Active Storage Progress:
- [ ] Step 1: Add attachment to model
- [ ] Step 2: Write model spec for attachment
- [ ] Step 3: Add validations (type, size)
- [ ] Step 4: Create upload form
- [ ] Step 5: Handle in controller
- [ ] Step 6: Display in views
- [ ] Step 7: Test upload flow
```

## Testando anexos

Ver [testing.md](references/testing.md) para specs de model, características de factory e specs de solicitação.

Padrões principais:
- Use `fixture_file_upload` nas specs de solicitação
- Defina características de factory `:with_avatar` usando `after(:build)`
- Teste `be_attached` e presença de variante nas specs do model

## Validations

Use a gem `active_storage_validations` para validation declarativa ou escreva métodos `validate` manuais. Ver [validations.md](references/validations.md) para ambas as abordagens.

```ruby
# Gemfile
gem 'active_storage_validations'
```

## Variantes de imagem

Defina variantes nomeadas no anexo do model usando `resize_to_fill`, `resize_to_limit` ou `resize_to_cover`. Ver [variants-and-views.md](references/variants-and-views.md) para operações variantes, visualizar auxiliares e exemplos de formulários.

## Controller e Tratamento de Serviços

- Permitir `:avatar` para uploads únicos, `photos: []` para uploads múltiplos
- Use `purge` para remover anexos, com resposta Turbo Stream opcional
- Use `rails_blob_path` ou `send_data` para downloads

Ver [controller-and-service.md](references/controller-and-service.md) para exemplos completos de controllers, métodos de serviço, configuração de uploads diretos e dicas de desempenho.

## Lista de verificação

- [] Active Storage instalado e migrado
- [] Serviço de armazenamento configurado
- [] Gema de processamento de imagem adicionada (se estiver usando variantes)
- [] Anexo adicionado ao model
- [] Validations adicionadas (tipo, tamanho)
- [ ] Variantes definidas
- [] O controller permite parâmetros de anexo
- [] O formulário lida com o upload do arquivo
- [] Testes escritos para anexos
- [] Uploads diretos configurados (se necessário)

## Referências

- [testing.md](references/testing.md) - Especificações do model, características de factory, specs de solicitação
- [validations.md](references/validations.md) - Exemplos de validation manual e baseada em gemas
- [variants-and-views.md](references/variants-and-views.md) - Definições de variantes, visualizar ajudantes, fazer upload de formulários
- [controller-and-service.md](references/controller-and-service.md) - Controllers, métodos de serviço, uploads diretos, desempenho
