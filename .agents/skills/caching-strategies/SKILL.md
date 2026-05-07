---
name: caching-strategies
description: >-
  Implementa padrões de cache Rails para otimização de desempenho. Use ao adicionar
  cache de fragmentos, cache de boneca russa, cache de baixo nível, invalidação de cache
  ou quando o usuário mencionar cache, desempenho, chaves de cache ou memoização.
license: MIT
compatibility: Ruby 3.3+, Rails 8.1+, Solid Cache
metadata:
  author: ThibautBaissac
  version: "1.0"
---

# Estratégias de cache para Rails 8

## Visão geral

Rails fornece múltiplas camadas de cache:
- **Cache de fragmentos**: partials de view em cache
- **Cache de boneca russa**: fragmentos de cache aninhados
- **Cache de baixo nível**: armazena dados arbitrários em cache
- **Cache HTTP**: cache de navegador e CDN
- **Cache de consulta**: automático nas solicitações

## Início rápido

```ruby
# config/environments/development.rb
config.action_controller.perform_caching = true
config.cache_store = :memory_store

# config/environments/production.rb
config.cache_store = :solid_cache_store  # Rails 8 default
# OR
config.cache_store = :redis_cache_store, { url: ENV["REDIS_URL"] }
```

Habilite o cache no desenvolvimento:
```bash
bin/rails dev:cache
```

## Opções de armazenamento de cache

| Store | Use Case | Pros | Cons |
|-------|----------|------|------|
| `:memory_store` | Desenvolvimento | Fast, no setup | Not shared, limited size |
| `:solid_cache_store` | Production (Rails 8) | Database-backed, no Redis | Slightly slower |
| `:redis_cache_store` | Production | Fast, shared | Requires Redis |
| `:file_store` | Simple production | Persistent, no Redis | Slow, not shared |
| `:null_store` | Teste | No caching | N/A |

## Cache de fragmentos

### Cache de fragmentos básico

```erb
<%# app/views/events/_event.html.erb %>
<% cache event do %>
  <article class="event-card">
    <h3><%= event.name %></h3>
    <p><%= event.description %></p>
    <time><%= l(event.event_date, format: :long) %></time>
    <%= render event.venue %>
  </article>
<% end %>
```

### Componentes-chave do cache

Rails gera chaves de cache de:
- Nome do model
- ID do model
- Carimbo de data/hora `updated_at`
- Resumo do model (automático)

```ruby
# Generated key example:
# views/events/123-20240115120000000000/abc123digest
```

### Chaves de cache personalizadas

```erb
<%# With version %>
<% cache [event, "v2"] do %>
  ...
<% end %>

<%# With user-specific content %>
<% cache [event, current_user] do %>
  ...
<% end %>

<%# With explicit key %>
<% cache "featured-events-#{Date.current}" do %>
  <%= render @featured_events %>
<% end %>
```

## Cache de Boneca Russa

Caches aninhados onde os caches internos são reutilizados quando o cache externo é invalidado:

```erb
<%# app/views/events/show.html.erb %>
<% cache @event do %>
  <h1><%= @event.name %></h1>

  <section class="vendors">
    <% @event.vendors.each do |vendor| %>
      <% cache vendor do %>
        <%= render partial: "vendors/card", locals: { vendor: vendor } %>
      <% end %>
    <% end %>
  </section>

  <section class="comments">
    <% @event.comments.each do |comment| %>
      <% cache comment do %>
        <%= render comment %>
      <% end %>
    <% end %>
  </section>
<% end %>
```

Use `touch: true` on `belongs_to` associations to cascade invalidation up the chain. See [cache-invalidation.md](references/cache-invalidation.md) for examples.

## Cache de coleção

### Renderização de coleção eficiente

```erb
<%# Caches each item individually %>
<%= render partial: "events/event", collection: @events, cached: true %>

<%# With custom cache key %>
<%= render partial: "events/event",
           collection: @events,
           cached: ->(event) { [event, current_user.admin?] } %>
```

## Cache de baixo nível

Use `Rails.cache.fetch` with a block for the most common pattern. See [low-level-caching.md](references/low-level-caching.md) para:
- Exemplos básicos de leitura/gravação/busca
- Cache em Service Objects
- Cache em Query Objects
- Memoização de variável de instância
- Memoização com escopo de solicitação com `CurrentAttributes`

## Invalidação de cache

Three strategies: time-based expiration, key-based expiration (using `updated_at`), and manual deletion. See [cache-invalidation.md](references/cache-invalidation.md) para:
- Expiração baseada em tempo e chave
- Invalidação manual em callbacks e serviços de model
- Exclusão baseada em padrão (`delete_matched`)
- `touch: true` para cascata de boneca russa
- Caches de contadores integrados e personalizados

## Cache HTTP

Use `stale?` for conditional GET (ETags/Last-Modified) and `expires_in` for Cache-Control headers. See [http-caching-and-testing.md](references/http-caching-and-testing.md) para exemplos completos.

## Testando cache

Use a `:caching` metadata tag to enable caching in specs. See [http-caching-and-testing.md](references/http-caching-and-testing.md) para:
- Configuração `rails_helper.rb`
- Testando invalidação de view em cache
- Testando invalidação de cache em serviços
- Monitoramento de desempenho e instrumentação

## Lista de verificação

- [] Armazenamento de cache configurado para ambiente
- [] Cache de fragmentos em partials caros
- [] `touch: true` em pertence_to para boneca russa
- [] Cache de coleção com `cached: true`
- [] Cache de baixo nível para consultas caras
- [] Estratégia de invalidação de cache definida
- [] Caches de contador para contagens
- [] HTTP armazenando cabeçalhos em cache para API
- [] Aquecimento de cache para partidas a frio (se necessário)
- [] Monitoramento de taxas de acertos/erros

## Referências

- [low-level-caching.md](references/low-level-caching.md) - fetch/read/write, Service Objects, Query Objects, memoization
- [cache-invalidation.md](references/cache-invalidation.md) - expiration strategies, manual invalidation, touch, counter caches
- [http-caching-and-testing.md](references/http-caching-and-testing.md) - ETags, Cache-Control, spec configuration, monitoring
