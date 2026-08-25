# Páginas dedicadas de formulários

## Comportamento

Criação e edição de despesas, receitas, cartões, categorias e objetivos financeiros usam páginas dedicadas. Cada página possui título, contexto, retorno explícito, mensagens de validação e ações de salvar e cancelar.

Confirmações curtas, como operações sobre parcelas, continuam usando modal. Despesas abertas a partir da fatura preservam cartão fixo, crédito à vista inicial e mês de balanço da fatura selecionada.

Na criação de receitas, a página aceita várias linhas no mesmo envio. Cada linha possui descrição, repetição, valor, status de recebimento, categoria, data e mês do balanço. O usuário pode adicionar ou remover linhas antes de salvar; o lote é persistido em uma transação, evitando criação parcial quando alguma receita for inválida. A edição permanece individual.

## Decisão

Formulários de domínio não dependem mais do Turbo Frame `modal`. O envio usa fluxo HTML e os controllers mantêm redirecionamento após sucesso ou renderização da mesma página após erro. Um layout parcial compartilhado padroniza cabeçalho, painel e erros sem duplicar os campos específicos de cada recurso.

## Responsividade

Em telas maiores, despesas e receitas agrupam descrição e repetição na primeira linha e os detalhes financeiros na segunda. Em tablets, os detalhes passam para três colunas; em celulares, todos os campos ficam em uma coluna. Ações ocupam largura total no celular. Demais formulários aproveitam o grid responsivo existente e os controles visuais do sistema.

## Manutenção

- Estrutura comum: `app/views/shared/_form_page.html.erb`.
- Estilos: `app/assets/stylesheets/pages/_expenses.scss`, sob `.app-form-page`.
- Regras específicas permanecem nos partials `_form` de cada recurso.
- Modais vazios foram removidos dos índices que não possuem mais ações modais.
