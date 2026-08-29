# Link pelo identificador da parcela

## Objetivo

Permitir navegação direta entre parcelas do mesmo grupo na tela de detalhes de uma despesa parcelada.

## Interface

Na tabela **Parcelas do grupo**, o identificador da parcela, como `2/8`, será exibido como badge clicável para a tela de detalhes daquela despesa. A linha da parcela atualmente exibida continuará com seu destaque visual.

O mês de referência continuará como texto comum. Quando estiver ausente, a célula exibirá `—`.

## Implementação

A view `app/views/expenses/show.html.erb` usará `link_to` no identificador da parcela, apontando para `expense_path(installment)`. O badge será estilizado em `app/assets/stylesheets/pages/_expenses.scss` com fundo suave, formato arredondado e estados de hover e foco.

Não serão necessárias mudanças em rotas, controller, model ou banco de dados.

## Tratamento de erros

O comportamento atual para mês ausente será preservado. Como cada item da tabela é uma instância persistida de `Expense`, a rota de detalhes será gerada pelo helper existente.

## Validação

Por orientação do projeto, testes automatizados só serão executados mediante solicitação explícita. A implementação poderá ser validada manualmente clicando no badge de outra parcela e conferindo se o `show` correspondente é aberto.
