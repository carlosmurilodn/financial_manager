# Linhas responsivas de cartões e categorias

## Objetivo

Manter cartões e categorias em listas verticais com mesma identidade visual de despesas e receitas, sem forçar dados e ações diferentes dentro do layout específico de lançamentos.

## Escopo

- Refatorar somente linhas dos índices de cartões e categorias e CSS diretamente relacionado.
- Preservar filtros, paginação, Turbo, temas e regras de negócio existentes.
- Restaurar na linha de cartão: limite total, disponível, utilizado, total do mês selecionado e pagamento da fatura.
- Manter na linha de categoria: receitas, despesas e acesso à página de detalhes.
- Não alterar models, banco de dados ou cálculos financeiros.

## Arquitetura visual

As linhas continuam usando `.expense-card` como superfície visual compartilhada: borda lateral colorida, ícone circular, tipografia, pills e cores. Cada recurso recebe modificador próprio:

- `.card-row`: identidade, datas, quatro métricas e ações do cartão.
- `.category-row`: identidade, cor, duas métricas e ações da categoria.

O layout usa CSS Grid. Totais deixam de usar posicionamento absoluto, evitando colisões com nomes, badges e ações.

## Desktop

### Cartões

1. Identidade: imagem/ícone, nome e número mascarado.
2. Datas: fechamento e vencimento.
3. Métricas: limite total, disponível, utilizado e total do mês selecionado.
4. Ações: pagar fatura, editar e excluir.

### Categorias

1. Identidade: ícone, nome e cor.
2. Métricas: receitas e despesas do período filtrado.
3. Ações: editar e excluir.

## Celular

Em até `576px`:

- identidade ocupa primeira faixa;
- ações editar/excluir usam somente ícones, com `title` e `aria-label`;
- métricas formam grade de duas colunas;
- rótulos permanecem visíveis para não depender apenas de cor ou ícone;
- botão de pagamento do cartão ocupa largura total;
- textos longos podem quebrar sem gerar rolagem horizontal;
- alvos interativos mantêm tamanho mínimo próximo de 44px.

Em `577px–991px`, grid reduz colunas gradualmente, sem sobreposição.

## Comportamento

- Nome do cartão e da categoria continua abrindo página de detalhes.
- Editar continua abrindo modal Turbo.
- Excluir mantém confirmação e respostas Turbo atuais.
- Pagamento envia mês e ano selecionados, como componente anterior.
- Imagem de cartão recebe texto alternativo com nome do cartão.
- Temas claro e noturno continuam usando tokens existentes.

## Validação

Inspeção estática verificará ERB, seletores e integração Turbo. Testes automatizados não serão executados nesta tarefa, conforme instrução do usuário/projeto. Validação visual recomendada posteriormente nas larguras 320, 375, 576, 768 e desktop, nos temas claro e noturno.

## Fora do escopo

- Redesenho dos heróis, filtros ou páginas de detalhes.
- Mudanças nos cálculos de limite e totais.
- Novos endpoints, migrations ou dependências.
