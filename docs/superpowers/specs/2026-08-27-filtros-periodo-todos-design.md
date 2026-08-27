# Filtro de período com opção Todos

## Objetivo

Permitir que páginas com filtros de mês e ano mantenham a opção `Todos`, sem substituí-la automaticamente pelo mês ou ano atual.

## Escopo

Aplicar comportamento nas listagens de:

- receitas;
- despesas e relatório de despesas;
- cartões;
- categorias.

Telas de detalhe de cartões e categorias permanecem inalteradas, pois usam navegação entre meses e não oferecem a opção `Todos`.

## Comportamento

- Na primeira visita, sem filtro salvo na sessão, usar mês e ano atuais.
- Quando usuário selecionar `Todos` para mês, manter mês sem filtro.
- Quando usuário selecionar `Todos` para ano, manter ano sem filtro.
- Permitir combinações como todos os meses de um ano e um mês em todos os anos.
- Persistir seleção na sessão durante navegação.
- Ao limpar filtros, remover valores da sessão; visita seguinte volta ao período atual.

## Implementação

Controladores devem distinguir ausência de chave na sessão de valor explícito `0`, enviado pelas opções `Todos`. Valor `0` será normalizado para `nil` para consumo pelas consultas e seleção das views, mas não receberá fallback para período atual quando resultar de escolha explícita.

Views e queries existentes já representam `Todos` com `0` e ignoram período quando mês ou ano são `nil`; portanto, não precisam mudar salvo ajuste descoberto durante implementação.

## Tratamento de casos limite

- Parâmetros vazios ou inválidos equivalentes a zero representam `Todos`.
- Filtro parcial continua válido: somente mês ou somente ano pode ficar sem restrição.
- Ações que dependem de período concreto, como pagar fatura, mantêm fallback atual e não passam a operar sobre todos os períodos.

## Verificação

Confirmar manualmente, pelo fluxo do código, que cada controlador diferencia primeira visita de seleção explícita de `Todos`. Testes automatizados e comandos de teste somente serão executados se solicitados pelo usuário, conforme regras do projeto.
