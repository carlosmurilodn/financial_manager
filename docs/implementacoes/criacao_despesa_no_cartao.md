# Criação de despesa no cartão

## Comportamento

O show do cartão oferece ação `Nova despesa` no cabeçalho da fatura. O modal de despesas existente é aberto com contexto do cartão e do período visível.

Nesse contexto:

- cartão fica fixo e é validado dentro dos cartões do usuário;
- pagamento inicia como `Crédito à vista` e permite troca para `Crédito parcelado`;
- data inicia no dia atual;
- mês de balanço inicia no período da fatura;
- novas linhas inseridas no modal herdam os mesmos padrões;
- cartão e forma de pagamento são normalizados no backend;
- sucesso recarrega o show, preservando mês e ano da fatura.

O modal aberto pela página geral de despesas mantém seleção livre de pagamento e cartão. As coleções exibidas no formulário são limitadas ao usuário atual.

## Arquivos principais

- `app/controllers/expenses_controller.rb`
- `app/views/cards/show.html.erb`
- `app/views/expenses/_form.html.erb`
- `app/views/expenses/_form_row.html.erb`
- `app/assets/stylesheets/pages/_expenses.scss`
- `app/assets/stylesheets/modals.css`

Não houve nova rota, migration ou mudança nos cálculos financeiros.
