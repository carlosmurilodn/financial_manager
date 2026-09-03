# Status visual das movimentações no dashboard

## Comportamento

O card **Movimentações do Período** mostra o estado de cada lançamento sem depender apenas da cor:

- movimentações concluídas recebem faixa lateral verde, ícone de confirmação e badge `Pago` ou `Recebido`;
- movimentações pendentes recebem faixa lateral vermelha, ícone de espera e badge `Pendente`;
- os sinais `+` e `-` identificam respectivamente receitas e despesas;
- valores usam cor neutra;
- ícone e nome da categoria preservam a cor própria da categoria.

Em telas menores, o badge ocupa uma segunda linha para preservar descrição e valor. Os estilos usam tokens semânticos existentes, compatíveis com os temas claro e noturno.

## Dados

O status usa o atributo `paid` já existente em receitas e despesas. A consulta de despesas do dashboard seleciona esse atributo explicitamente. Nenhuma migração ou nova regra financeira foi introduzida.

## Limites

O dashboard apenas informa o status. Alterações de pagamento ou recebimento continuam nas telas específicas de receitas e despesas.

## Referência

- [Especificação de design](../superpowers/specs/2026-09-02-status-movimentacoes-dashboard-design.md)

