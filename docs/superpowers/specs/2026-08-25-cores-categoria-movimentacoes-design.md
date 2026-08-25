# Cores de categoria nas movimentações do período

## Objetivo

Fazer ícone e nome da categoria, no card `Movimentações do Período`, herdarem a cor configurada na categoria.

## Implementação

Cada item define variável CSS `--movement-category-color` com `category.display_color`. Ícone e nome da categoria consomem essa variável por classes específicas do card.

Movimentações sem categoria usam cor neutra existente como fallback. Descrição, valor, data, bordas e diferenciação entre receita e despesa permanecem inalterados.

## Escopo

- Alterar `app/views/home/_movimentacoes_periodo.html.erb`.
- Alterar estilos do feed em `app/assets/stylesheets/dashboard/_cards_categories_movements.scss`.
- Manter comportamento responsivo e temas existentes.
- Não alterar outros cards de movimentações, dados ou regras financeiras.

## Validação

Verificar sintaxe ERB, seletor CSS, fallback sem categoria e integridade do diff. Testes automatizados não serão executados sem solicitação do usuário.
