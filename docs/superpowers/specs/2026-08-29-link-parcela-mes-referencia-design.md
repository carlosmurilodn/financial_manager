# Link da parcela pelo mês de referência

## Objetivo

Permitir navegação direta entre parcelas do mesmo grupo na tela de detalhes de uma despesa parcelada.

## Interface

Na tabela **Parcelas do grupo**, o mês de referência de cada parcela será um link para a tela de detalhes daquela despesa. A linha da parcela atualmente exibida continuará com seu destaque visual.

Quando a parcela não possuir mês de referência, a célula continuará exibindo `—`, sem link.

## Implementação

A alteração ficará restrita à view `app/views/expenses/show.html.erb`. O texto formatado como `MM/AAAA` será envolvido por `link_to`, usando `expense_path(installment)`.

Não serão necessárias mudanças em rotas, controller, model ou banco de dados.

## Tratamento de erros

O comportamento atual para mês ausente será preservado. Como cada item da tabela é uma instância persistida de `Expense`, a rota de detalhes será gerada pelo helper existente.

## Validação

Por orientação do projeto, testes automatizados só serão executados mediante solicitação explícita. A implementação poderá ser validada manualmente clicando no mês de referência de outra parcela e conferindo se o `show` correspondente é aberto.
