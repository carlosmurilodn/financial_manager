# Linhas responsivas de cartões e categorias

## Entrega

Os índices de cartões e categorias usam linhas verticais alinhadas à identidade visual de despesas e receitas. A superfície, borda colorida, ícones, pills e botões seguem os componentes visuais já existentes, enquanto cada recurso possui grid próprio para seus dados.

Cartões exibem limite total, limite disponível, limite utilizado e total do mês selecionado. Categorias exibem receitas e despesas do período filtrado. A ação de pagar fatura fica no show do cartão e usa o mês e ano da fatura aberta.

## Responsividade

- Desktop distribui identidade, métricas e ações em colunas.
- Telas intermediárias movem métricas para uma segunda faixa.
- Em até `576px`, métricas usam duas colunas e editar/excluir usam botões de ícone.
- Valores e nomes longos quebram dentro do componente, sem posicionamento absoluto.

## Arquivos principais

- `app/views/cards/_card_row.html.erb`
- `app/views/categories/_category_row.html.erb`
- `app/assets/stylesheets/pages/_expenses.scss`

Não houve alteração em cálculos financeiros, endpoints ou persistência.
