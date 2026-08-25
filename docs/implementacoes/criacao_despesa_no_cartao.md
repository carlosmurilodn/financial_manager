# Criação de despesa no cartão

## Comportamento

O show do cartão oferece ação `Nova despesa` no cabeçalho da fatura. A página dedicada de nova despesa é aberta com contexto do cartão e do período visível.

Nesse contexto:

- cartão fica fixo e é validado dentro dos cartões do usuário;
- pagamento inicia como `Crédito à vista` e permite troca para `Crédito parcelado`;
- data inicia no dia atual;
- mês de balanço inicia no período da fatura;
- novas linhas inseridas no formulário herdam os mesmos padrões;
- cartão e forma de pagamento são normalizados no backend;
- sucesso recarrega o show, preservando mês e ano da fatura.

A página aberta pelo índice geral de despesas mantém seleção livre de pagamento e cartão. As coleções exibidas no formulário são limitadas ao usuário atual.

## Arquivos principais

- `app/controllers/expenses_controller.rb`
- `app/views/cards/show.html.erb`
- `app/views/expenses/_form.html.erb`
- `app/views/expenses/_form_row.html.erb`
- `app/assets/stylesheets/pages/_expenses.scss`
- `app/assets/stylesheets/pages/_expenses.scss`

Não houve nova rota, migration ou mudança nos cálculos financeiros.
