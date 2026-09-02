# Status visual das movimentações no dashboard

## Contexto

O card **Movimentações do Período** usa atualmente verde para receitas e vermelho para despesas. Essa associação informa o tipo da movimentação, mas não mostra se a receita foi recebida ou se a despesa foi paga.

Receitas e despesas já possuem o atributo booleano `paid`. O dashboard também já diferencia os tipos pelos sinais `+` e `-`, portanto as cores podem representar o estado financeiro sem perder essa informação.

## Problema

O usuário precisa identificar rapidamente quais movimentações do período foram concluídas e quais continuam pendentes, sem abrir cada registro.

## Solução aprovada

Cada item do card terá dois indicadores complementares de status:

- faixa lateral verde para movimentação concluída;
- faixa lateral vermelha para movimentação pendente;
- badge com ícone e texto, evitando depender somente da cor.

Os sinais permanecem responsáveis pelo tipo:

- `+` para receita;
- `-` para despesa.

O valor monetário passa a usar cor neutra. As cores próprias das categorias continuam no ícone e no nome da categoria.

## Textos e ícones

| Tipo | Concluída | Pendente |
| --- | --- | --- |
| Receita | ícone `check`, texto `Recebido` | ícone `schedule`, texto `Pendente` |
| Despesa | ícone `check`, texto `Pago` | ícone `schedule`, texto `Pendente` |

## Comportamento

- O status será apenas informativo no dashboard.
- Clicar no título continuará abrindo os detalhes da movimentação.
- Alterar o status continuará sendo responsabilidade das telas de receitas e despesas.
- Não haverá nova coluna, migração ou regra de persistência.
- Temas claro e noturno deverão manter contraste suficiente.
- Em telas menores, badge e valor não deverão encobrir descrição, categoria ou data.

## Dados e implementação

O partial `app/views/home/_movimentacoes_periodo.html.erb` deverá aplicar classes de status derivadas de `paid?` e renderizar o badge adequado ao tipo.

A consulta `Home::DashboardQuery#recent_expenses` deverá incluir `paid` na lista explícita de colunas selecionadas. As receitas já são carregadas sem uma seleção restritiva e disponibilizam o atributo.

Os estilos ficarão junto aos estilos existentes do feed em `app/assets/stylesheets/dashboard/_cards_categories_movements.scss`, reutilizando as variáveis de sucesso e perigo já adotadas pela aplicação sempre que oferecerem contraste adequado.

## Critérios de aceite

- Receita recebida exibe faixa verde e badge `Recebido` com ícone de confirmação.
- Receita não recebida exibe faixa vermelha e badge `Pendente` com ícone de espera.
- Despesa paga exibe faixa verde e badge `Pago` com ícone de confirmação.
- Despesa não paga exibe faixa vermelha e badge `Pendente` com ícone de espera.
- Valores de receitas e despesas usam cor neutra e preservam os sinais `+` e `-`.
- Cores das categorias continuam independentes do status.
- Informação de status permanece compreensível sem percepção de cores.
- Layout permanece legível nos temas claro e noturno e nos breakpoints existentes.

## Fora do escopo

- Alterar o status diretamente pelo dashboard.
- Adicionar filtros por status ao card.
- Alterar cálculos financeiros ou regras de pagamento.
- Criar novos estados além de concluída e pendente.

## Validação prevista

- Cobrir a renderização dos quatro cruzamentos entre tipo e status no nível de teste já adotado pelo projeto para o dashboard.
- Fazer verificação visual nos temas claro e noturno.
- Fazer verificação responsiva nos breakpoints existentes.

