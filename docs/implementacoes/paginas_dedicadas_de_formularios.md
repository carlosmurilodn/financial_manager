# Páginas dedicadas de formulários

## Comportamento

Criação e edição de despesas, receitas, cartões, categorias e objetivos financeiros usam páginas dedicadas. Cada página possui título, contexto, retorno explícito, mensagens de validação e ações de salvar e cancelar.

Confirmações curtas, como operações sobre parcelas, continuam usando modal. Despesas abertas a partir da fatura preservam cartão fixo, crédito à vista inicial e mês de balanço da fatura selecionada.

## Decisão

Formulários de domínio não dependem mais do Turbo Frame `modal`. O envio usa fluxo HTML e os controllers mantêm redirecionamento após sucesso ou renderização da mesma página após erro. Um layout parcial compartilhado padroniza cabeçalho, painel e erros sem duplicar os campos específicos de cada recurso.

## Responsividade

Em telas maiores, campos de despesas usam até três colunas. Em tablets, passam para duas; em celulares, uma. Ações ocupam largura total no celular. Demais formulários aproveitam o grid responsivo existente e os controles visuais do sistema.

## Manutenção

- Estrutura comum: `app/views/shared/_form_page.html.erb`.
- Estilos: `app/assets/stylesheets/pages/_expenses.scss`, sob `.app-form-page`.
- Regras específicas permanecem nos partials `_form` de cada recurso.
- Modais vazios foram removidos dos índices que não possuem mais ações modais.
