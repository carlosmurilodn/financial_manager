---
name: hotwire-patterns
description: >-
  Implementa padrões Hotwire com controllers Turbo Frames, Turbo Streams e Stimulus. Use
  ao criar UIs interativas, atualizações em tempo real, manipulação de formulários,
  atualizações partials de páginas ou quando o usuário mencionar Turbo, Stimulus ou
  Hotwire.
license: MIT
compatibility: Ruby 3.3+, Rails 8.1+, Hotwire (Turbo + Stimulus)
metadata:
  author: ThibautBaissac
  version: "1.0"
---

# Padrões Hotwire para Rails 8

## Visão geral

Hotwire = HTML Over The Wire - Crie aplicativos da web modernos sem escrever muito JavaScript.

| Component | Purpose | Use Case |
|-----------|---------|----------|
| **Turbo Drive** | SPA-like navigation | Automatic, no code needed |
| **Turbo Frames** | Partial page updates | Inline editing, tabbed content |
| **Turbo Streams** | Real-time DOM updates | Live updates, flash messages |
| **Stimulus** | JavaScript sprinkles | Toggles, forms, interactions |

## Início rápido

### Turbo Frames (navegação com escopo)

```erb
<%# app/views/posts/index.html.erb %>
<%= turbo_frame_tag "posts" do %>
  <%= render @posts %>
  <%= link_to "Load More", posts_path(page: 2) %>
<% end %>

<%# Clicking "Load More" only updates content inside this frame %>
```

### Turbo Streams (atualizações em tempo real)

```erb
<%# app/views/posts/create.turbo_stream.erb %>
<%= turbo_stream.prepend "posts", @post %>
<%= turbo_stream.update "flash", partial: "shared/flash" %>
```

### Controller Stimulus

```javascript
// app/javascript/controllers/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content"]

  toggle() {
    this.contentTarget.classList.toggle("hidden")
  }
}
```

```erb
<div data-controller="toggle">
  <button data-action="toggle#toggle">Toggle</button>
  <div data-toggle-target="content">Hidden content</div>
</div>
```

## Lista de verificação do fluxo de trabalho

```
Hotwire Implementation:
- [ ] Identify update scope (full page vs partial)
- [ ] Choose pattern (Frame vs Stream vs Stimulus)
- [ ] Implement server response
- [ ] Add client-side markup
- [ ] Test with and without JavaScript
- [ ] Write system spec
```

## Quando usar cada padrão

| Scenario | Pattern | Why |
|----------|---------|-----|
| Inline edit | Turbo Frame | Scoped replacement |
| Form submission | Turbo Stream | Multiple updates |
| Real-time feed | Turbo Stream + ActionCable | Push updates |
| Toggle visibility | Stimulus | No server needed |
| Form validation | Stimulus | Client-side feedback |
| Infinite scroll | Turbo Frame + lazy loading | Paginated content |
| Modal dialogs | Turbo Frame | Load on demand |
| Flash messages | Turbo Stream | Append/update |

## Referências

- Ver [turbo-frames.md](references/turbo-frames.md) for frame patterns
- Ver [turbo-streams.md](references/turbo-streams.md) for stream patterns
- Ver [stimulus.md](references/stimulus.md) for controller patterns

## Testando Hotwire

### Especificações do sistema

```ruby
# spec/system/posts_spec.rb
require 'rails_helper'

RSpec.describe "Posts", type: :system do
  before { driven_by(:selenium_chrome_headless) }

  it "updates post inline with Turbo Frame" do
    post = create(:post, title: "Original")

    visit posts_path
    within("#post_#{post.id}") do
      click_link "Edit"
      fill_in "Title", with: "Updated"
      click_button "Save"
    end

    expect(page).to have_content("Updated")
    expect(page).not_to have_content("Original")
  end

  it "adds comment with Turbo Stream" do
    post = create(:post)

    visit post_path(post)
    fill_in "Comment", with: "Great post!"
    click_button "Add Comment"

    within("#comments") do
      expect(page).to have_content("Great post!")
    end
  end
end
```

### Solicitar specs para Turbo Stream

```ruby
# spec/requests/posts_spec.rb
RSpec.describe "Posts", type: :request do
  describe "POST /posts" do
    let(:valid_params) { { post: { title: "Test" } } }

    it "returns turbo stream response" do
      post posts_path, params: valid_params,
           headers: { "Accept" => "text/vnd.turbo-stream.html" }

      expect(response.media_type).to eq("text/vnd.turbo-stream.html")
      expect(response.body).to include("turbo-stream")
    end
  end
end
```

## Padrões Comuns

### Edição embutida com moldura

```erb
<%# _post.html.erb %>
<%= turbo_frame_tag dom_id(post) do %>
  <article>
    <h2><%= post.title %></h2>
    <%= link_to "Edit", edit_post_path(post) %>
  </article>
<% end %>

<%# edit.html.erb %>
<%= turbo_frame_tag dom_id(@post) do %>
  <%= form_with model: @post do |f| %>
    <%= f.text_field :title %>
    <%= f.submit "Save" %>
    <%= link_to "Cancel", @post %>
  <% end %>
<% end %>
```

### Mensagens Flash com Stream

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  after_action :flash_to_turbo_stream, if: -> { request.format.turbo_stream? }

  private

  def flash_to_turbo_stream
    flash.each do |type, message|
      flash.now[type] = message
    end
  end
end
```

### Quadro de carregamento lento

```erb
<%= turbo_frame_tag "comments", src: post_comments_path(@post), loading: :lazy do %>
  <p>Loading comments...</p>
<% end %>
```

## Dicas de depuração

1. **O quadro não está sendo atualizado?** Verifique se os IDs dos quadros correspondem exatamente
2. **Stream não funciona?** Verifique se o cabeçalho `Accept` inclui turbo-stream
3. **Stimulus não dispara?** Verifique se o nome do controller corresponde ao nome do arquivo
4. **Eventos não funcionam?** Use `data-action="event->controller#method"`
