# Ordenação de categorias por total de despesas

## Objetivo

Permitir ordenar a listagem de categorias pelo total de despesas do período filtrado, preservando a ordenação alfabética atual como padrão.

## Interface

O formulário de filtros da página de categorias receberá o campo `Ordenar`, com três opções:

- `Nome (A–Z)`, selecionada por padrão;
- `Maior despesa`;
- `Menor despesa`.

A opção será enviada junto dos demais parâmetros do formulário e permanecerá selecionada após a aplicação dos filtros.

## Regra de ordenação

`Categories::IndexQuery` receberá a opção escolhida e ordenará as categorias após calcular os totais de despesas do período:

- `Nome (A–Z)`: nome normalizado em ordem crescente;
- `Maior despesa`: total de despesas decrescente;
- `Menor despesa`: total de despesas crescente.

Categorias sem despesas terão total zero. Empates por valor serão resolvidos pelo nome normalizado em ordem crescente. Opções ausentes ou inválidas usarão `Nome (A–Z)`.

## Fluxo de dados

`CategoriesController` lerá `params[:sort_option]` e o repassará à query. A query reutilizará o agrupamento de despesas empregado na exibição dos totais, evitando cálculo divergente. A view apenas exibirá as categorias na ordem retornada.

## Escopo

A mudança afeta somente a listagem de categorias. Criação, edição, exclusão e tela de detalhe permanecem inalteradas. O período considerado continuará sendo definido pelos filtros de mês e ano existentes.

## Verificação

Verificar que a ordenação alfabética permanece padrão, que as duas ordenações por despesa respeitam os totais exibidos, que totais iguais usam nome como desempate e que parâmetro inválido volta ao padrão. Testes automatizados somente serão escritos ou executados mediante pedido do usuário.
