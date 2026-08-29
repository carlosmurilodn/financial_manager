# KPIs da tela do cartão

## Objetivo

Reforçar hierarquia visual dos KPIs da tela de detalhes do cartão com ícones e as mesmas variantes semânticas usadas no dashboard.

## Variantes e ícones

| KPI | Variante | Ícone |
| --- | --- | --- |
| Limite Total | primary | `account_balance_wallet` |
| Utilizado | danger | `credit_card` |
| Disponível | success | `savings` |
| Uso do Limite | warning | `donut_large` |
| Fechamento | neutral | `event_available` |
| Vencimento | neutral | `event_upcoming` |
| Total da Fatura | primary | `receipt_long` |
| Pago | success | `check_circle` |
| Pendente | danger | `schedule` |

## Interface

Cada KPI terá um ícone em bloco próprio, alinhado ao rótulo e ao valor. As variantes `primary`, `success`, `danger` e `warning` reutilizarão os tokens `--stat-*-bg` e `--stat-*-icon-bg` do dashboard. A variante neutra continuará baseada nos tokens de superfície e texto do tema.

O indicador de Uso do Limite manterá sua barra de progresso. Layout responsivo existente será preservado.

## Implementação

A view `app/views/cards/show.html.erb` receberá classes de variante e os ícones Material Symbols. Os estilos de `app-show-kpi` em `app/assets/stylesheets/pages/_expenses.scss` serão ampliados com estrutura interna e variantes reutilizáveis.

Não haverá mudanças em controller, model, rotas, banco de dados ou JavaScript.

## Validação

Por regra do projeto, testes só serão executados mediante solicitação explícita. A validação manual deve conferir todos os nove KPIs nos temas claro e noturno, incluindo alinhamento, contraste, barra de progresso e responsividade.
