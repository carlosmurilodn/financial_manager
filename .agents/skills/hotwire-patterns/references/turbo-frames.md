# Referência Turbo Frames

## Conceito

Turbo Frames navega no escopo para uma parte da página. Quando um link ou formulário dentro de um quadro é ativado, apenas o conteúdo desse quadro é substituído.

## Uso Básico

### Definir um quadro

```erb
<%= turbo_frame_tag "user_profile" do %>
  <h2><%= @user.name %></h2>
  <%= link_to "Edit", edit_user_path(@user) %>
<% end %>
```

### Corresponder quadro em resposta

```erb
<%# edit.html.erb - must have matching frame %>
<%= turbo_frame_tag "user_profile" do %>
  <%= form_with model: @user do |f| %>
    <%= f.text_field :name %>
    <%= f.submit %>
  <% end %>
<% end %>
```

## Atributos de quadro

| Attribute | Purpose | Example |
|-----------|---------|---------|
| `id` | Frame identifier | `turbo_frame_tag "posts"` |
| `src` | Lazy load URL | `src: posts_path` |
| `loading` | Load timing | `loading: :lazy` |
| `target` | Navigation target | `target: "_top"` |
| `disabled` | Disable frame | `disabled: true` |

## Padrões Comuns

### Carregamento lento

```erb
<%# Load content when frame enters viewport %>
<%= turbo_frame_tag "comments",
    src: post_comments_path(@post),
    loading: :lazy do %>
  <p>Loading comments...</p>
<% end %>
```

### Saindo do quadro

```erb
<%# Link navigates full page, not just frame %>
<%= link_to "View All", posts_path, data: { turbo_frame: "_top" } %>

<%# Or in the frame tag %>
<%= turbo_frame_tag "modal", target: "_top" do %>
  ...
<% end %>
```

### Visando quadros diferentes

```erb
<%# Link updates a different frame %>
<%= link_to "Details", post_path(@post), data: { turbo_frame: "post_details" } %>

<%# This frame will be updated %>
<%= turbo_frame_tag "post_details" do %>
  <p>Select a post to see details</p>
<% end %>
```

### Padrão de edição embutido

```erb
<%# Show mode %>
<%= turbo_frame_tag dom_id(post) do %>
  <div class="post">
    <h3><%= post.title %></h3>
    <p><%= post.body %></p>
    <%= link_to "Edit", edit_post_path(post) %>
  </div>
<% end %>

<%# Edit mode (edit.html.erb) %>
<%= turbo_frame_tag dom_id(@post) do %>
  <%= form_with model: @post, data: { turbo_frame: dom_id(@post) } do |f| %>
    <%= f.text_field :title %>
    <%= f.text_area :body %>
    <%= f.submit "Save" %>
    <%= link_to "Cancel", @post %>
  <% end %>
<% end %>
```

### Padrão Modal

```erb
<%# Trigger link %>
<%= link_to "New Post", new_post_path, data: { turbo_frame: "modal" } %>

<%# Modal frame (in layout) %>
<%= turbo_frame_tag "modal" %>

<%# new.html.erb %>
<%= turbo_frame_tag "modal" do %>
  <div class="modal-backdrop">
    <div class="modal-content">
      <h2>New Post</h2>
      <%= form_with model: @post do |f| %>
        ...
      <% end %>
      <%= link_to "Close", root_path, data: { turbo_frame: "modal" } %>
    </div>
  </div>
<% end %>
```

### Navegação por guias

```erb
<nav>
  <%= link_to "Details", post_details_path(@post), data: { turbo_frame: "tab_content" } %>
  <%= link_to "Comments", post_comments_path(@post), data: { turbo_frame: "tab_content" } %>
  <%= link_to "History", post_history_path(@post), data: { turbo_frame: "tab_content" } %>
</nav>

<%= turbo_frame_tag "tab_content" do %>
  <%= render "details" %>
<% end %>
```

## Eventos de quadro

```javascript
// Listen for frame events
document.addEventListener("turbo:frame-load", (event) => {
  console.log("Frame loaded:", event.target.id)
})

document.addEventListener("turbo:frame-missing", (event) => {
  console.log("Frame not found in response:", event.target.id)
  event.preventDefault() // Handle gracefully
})
```

## Solução de problemas

| Issue | Cause | Solution |
|-------|-------|----------|
| Frame not updating | ID mismatch | Ensure frame IDs match exactly |
| Full page reload | Missing frame in response | Add matching frame tag |
| Content disappears | Empty frame returned | Check controller response |
| Wrong frame updates | Multiple frames with same ID | Use unique IDs |
