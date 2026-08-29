# Menu lateral compacto no HD

## Objetivo

Evitar sobreposição dos últimos elementos da sidebar aberta em telas HD com pouca altura útil, preservando todos os itens visíveis e legíveis.

## Escopo

Aplicar compactação somente entre `1200px` e `1440px` de largura. Mobile, tablets e telas acima de `1440px` mantêm espaçamentos atuais.

## Comportamento

- Manter sidebar aberta, com ícones e textos.
- Reduzir espaço vertical entre links de navegação de `4px` para `2px`.
- Reduzir padding vertical dos links de `10px` para `4px`.
- Manter links com altura visual próxima de `44px`, preservando área de clique adequada.
- Reduzir gap interno da sidebar de `16px` para `8px`.
- Reduzir margem superior da navegação de `8px` para `2px`.
- Compactar levemente cabeçalho e seletor de tema sem ocultar conteýo.
- Não adicionar rolagem interna enquanto todos os itens couberem no viewport HD.

## Limites

Nenhum item, texto ou ação será removido. Estrutura ERB, rotas, preferência de tema e comportamento da sidebar fora do breakpoint HD permanecem inalterados.

## Verificação

Conferir em `1366×768` que links, seletor de tema e saída não se sobrepõem. Confirmar legibilidade, alinhamento e ausência de alterações fora do intervalo HD.

Testes automatizados e comandos de teste não serão executados sem solicitação do usuário.
