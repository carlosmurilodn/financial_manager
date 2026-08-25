# Cores semânticas nas linhas de cartões e categorias

## Objetivo

Padronizar métricas e ação de pagamento das linhas de cartões e categorias com cores semânticas do sistema, sem herdar cor configurada no cartão.

## Cartões

- `Limite total`: azul primário.
- `Disponível`: verde.
- `Utilizado`: vermelho.
- `Total do mês`: amarelo de aviso.
- `Pagar fatura`: fundo azul primário, texto branco, ícone branco, cursor de botão e estados visíveis de hover/foco.

## Categorias

- `Receitas`: verde.
- `Despesas`: vermelho.

## Tratamento visual

Cada métrica aplica cor semântica no valor, borda e fundo suave. Rótulos permanecem neutros para legibilidade. Tokens de tema são usados quando disponíveis, preservando temas claro/noturno.

Classes modificadoras explícitas serão adicionadas ao ERB. Não serão usados `nth-child`, cores do cartão ou estilos inline para controlar semântica.

## Escopo

- `app/views/cards/_card_row.html.erb`
- `app/views/categories/_category_row.html.erb`
- `app/assets/stylesheets/pages/_expenses.scss`

Estrutura, responsividade, cálculos e comportamento de pagamento permanecem inalterados.

## Validação

Verificar sintaxe ERB, cascata CSS, cursor/hover/foco, delimitadores e integridade do diff. Testes automatizados não serão executados sem solicitação do usuário.
