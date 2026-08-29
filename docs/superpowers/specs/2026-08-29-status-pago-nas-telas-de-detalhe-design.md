# Status de pagamento nas telas de detalhe

## Objetivo

Permitir alterar o status de pagamento diretamente nas telas de detalhe de despesas e receitas, usando o selo exibido no cabeçalho do card e mantendo o usuário na mesma tela após a alteração.

## Comportamento

- O selo `Pago`/`Pendente` da despesa será clicável.
- O selo `Recebida`/`Pendente` da receita será clicável.
- Receitas e despesas não parceladas alternarão o status diretamente.
- Despesas parceladas abrirão o mesmo modal usado na listagem, permitindo alterar somente a parcela atual ou a parcela atual e as seguintes.
- Depois da alteração, a aplicação redirecionará para a tela de detalhe do lançamento atualizado e exibirá a mensagem de sucesso existente.
- Aparência, textos e classes visuais atuais dos selos serão preservados.
- Links terão rótulos acessíveis coerentes com o status atual.

## Implementação

As telas de detalhe reutilizarão as rotas `toggle_paid` e `toggle_paid_options` existentes. Um parâmetro explícito de retorno identificará ações iniciadas no detalhe. Os controllers usarão esse parâmetro somente para escolher entre redirecionar ao `show` ou ao índice. O modal de despesas parceladas propagará esse contexto até a ação final.

O fluxo da listagem permanecerá inalterado, incluindo suas respostas Turbo Stream e atualização dos KPIs.

## Tratamento de erros

Será mantido o tratamento atual dos endpoints. Nenhum novo estado persistido ou nova regra de negócio será criado.

## Verificação

Verificações previstas, sem execução automática nesta tarefa:

- receita pendente e recebida alternam o status no detalhe;
- despesa simples pendente e paga alternam o status no detalhe;
- despesa parcelada abre o modal e suporta os dois escopos;
- cada fluxo retorna ao detalhe correto;
- ações iniciadas nas listagens continuam retornando às listagens.
