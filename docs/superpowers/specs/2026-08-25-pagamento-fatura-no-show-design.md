# Pagamento da fatura no show do cartão

## Objetivo

Mover ação `Pagar fatura` da linha do índice de cartões para cabeçalho da fatura mensal no show do cartão.

## Comportamento

- Índice mantém somente ações de editar e excluir.
- Show exibe `Pagar fatura` ao lado de `Nova despesa`.
- Formulário envia mês e ano atualmente visualizados.
- Confirmação informa período que será pago.
- Backend marca como pagas somente despesas pendentes do cartão e período enviados, preservando serviço atual.
- Após sucesso ou erro, usuário retorna ao show do cartão no mesmo mês e ano.

## Visual

Botão mantém azul primário, texto/ícone brancos, cursor e estados de hover/foco já definidos. No celular, ações ocupam largura disponível e navegação mensal permanece em faixa própria.

## Escopo

- Remover formulário de `app/views/cards/_card_row.html.erb`.
- Adicionar formulário em `app/views/cards/show.html.erb`.
- Ajustar redirect de `CardsController#pay`.
- Adaptar estilos em `app/assets/stylesheets/pages/_expenses.scss`.
- Não alterar serviço `Cards::PayInvoice`, rota ou regra financeira.

## Validação

Verificar sintaxe Ruby/ERB, parâmetros do período, redirect, responsividade e integridade do diff. Testes automatizados não serão executados sem solicitação do usuário.
