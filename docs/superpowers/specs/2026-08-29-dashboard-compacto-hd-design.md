# Dashboard compacto no HD

## Objetivo

Reduzir altura ocupada pelo hero e pelos KPIs do dashboard em telas HD, corrigindo quebra visual das informações de clima.

## Escopo

Aplicar mudanças somente entre `1200px` e `1440px` de largura. Full HD, tablet e mobile mantêm layout atual.

## Hero

No intervalo HD, hero mantém título e descrição à esquerda. Bloco informativo da direita passa a uma coluna:

```text
Título e descrição | Data
                     | Clima
```

- Data fica acima do clima.
- Clima usa apresentação horizontal compacta.
- Condição, temperatura, cidade, mínima e máxima permanecem visíveis.
- Padding, gaps, ícone e tipografia secundária podem ser reduzidos somente o necessário para diminuir altura total e impedir quebras.
- Markup ERB e atualização JavaScript dos dados meteorológicos permanecem inalterados.

## KPIs

- Quatro KPIs ficam na mesma linha, usando grade de quatro colunas.
- Valores monetários usam aproximadamente metade do tamanho atual no HD: `0.75rem` (`12px` com fonte-base de `16px`).
- Labels, ícones e textos auxiliares permanecem visíveis e legíveis.
- Cards aceitam quebra controlada do valor caso algum número ainda exceda largura disponível.

## Limites

Sem alterações em cálculos, dados, rotas, controllers ou integração meteorológica. Mudança restrita ao SCSS responsivo do breakpoint HD.

## Verificação

Conferir em `1366×768`:

- clima abaixo da data, sem texto cortado ou sobreposto;
- hero mais baixo que layout anterior;
- quatro KPIs na mesma linha;
- valores monetários em `0.75rem` e sem colisão;
- ausência de mudanças fora do intervalo HD.

Testes automatizados e comandos de teste não serão executados sem solicitação do usuário.
