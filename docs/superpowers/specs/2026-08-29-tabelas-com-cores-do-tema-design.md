# Tabelas com cores do tema

## Objetivo

Padronizar cabeçalhos e linhas zebradas das listagens de despesas, cartões e categorias com os tokens do tema ativo, sem herdar a cor individual da categoria ou do cartão.

## Interface

Os cabeçalhos usarão fundo sólido baseado em `var(--nav-active-bar)`: azul no tema claro e rosa no tema noturno. O texto do cabeçalho usará uma cor com contraste apropriado.

As linhas pares receberão fundo suave derivado de `var(--nav-active-icon-color)`. Hover e demais destaques da tabela seguirão a mesma família temática.

Cores com significado funcional serão preservadas, incluindo cores de status, receita e despesa. Ícones e badges que identificam uma categoria ou cartão também poderão manter suas cores próprias; somente a estrutura visual da tabela será padronizada.

## Implementação

Os estilos compartilhados das listagens serão ajustados para usar tokens semânticos do tema. As variáveis inline `--expense-category-color` continuarão disponíveis aos elementos de identidade, mas não controlarão cabeçalho, zebra ou destaque estrutural das linhas.

A mudança não exige alterações em models, controllers, rotas, banco de dados ou JavaScript.

## Responsividade

O comportamento responsivo existente será preservado. Quando a tabela assumir apresentação em cards ou linhas compactas, os fundos alternados continuarão usando os mesmos tokens temáticos.

## Validação

Por regra do projeto, testes só serão executados mediante solicitação explícita. A validação manual deve conferir as três listagens nos temas claro e noturno, incluindo cabeçalho, linhas pares, hover, contraste e preservação das cores semânticas.
