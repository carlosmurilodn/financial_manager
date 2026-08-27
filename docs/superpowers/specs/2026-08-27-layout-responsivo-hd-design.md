# Layout responsivo para telas HD

## Objetivo

Adaptar sistema para telas HD, especialmente `1366×768`, eliminando cortes, sobreposições e rolagem horizontal sem degradar desktop Full HD ou navegação móvel.

## Escopo

Aplicar camada responsiva às páginas de Dashboard, Despesas, Receitas, Cartões, Categorias, Objetivos e Relatórios. Ajustes ficam concentrados em estilos e comportamento visual; regras de negócio e dados permanecem inalterados.

## Breakpoints

- Entre `1200px` e `1440px`: ativar layout HD compacto.
- Até `1199px`: preservar regras responsivas existentes, complementando apenas quando necessário para evitar conflito.
- Até `991px`: preservar navegação móvel atual.
- Acima de `1440px`: manter layout desktop atual.

## Sidebar

No intervalo HD, sidebar deve assumir largura compacta equivalente ao estado recolhido:

- exibir logo e ícones de navegação;
- esconder título, textos dos links e conteúdo textual do rodapé;
- manter nomes acessíveis por atributos existentes, como `title` e `aria-label`;
- ajustar margem esquerda do conteúdo para largura compacta;
- não sobrescrever preferência salva usada fora do intervalo HD.

## Cabeçalhos e KPIs

- Cabeçalhos devem permitir quebra interna sem ultrapassar contêiner.
- Ação principal permanece visível e legível.
- Grupos com quatro KPIs passam para grade `2×2` no intervalo HD.
- Cards de KPI devem aceitar quebra de valores e rótulos sem corte.
- Dashboard também organiza indicadores em grade `2×2`, sem rolagem horizontal.

## Filtros

- Manter quatro colunas quando largura útil permitir.
- Permitir quebra das ações para nova linha sem sobreposição.
- Controles de ordenação, paginação e exportação devem respeitar largura disponível.
- Nenhum filtro deve ser ocultado.

## Linhas de recursos

Linhas de despesas, receitas e cartões passam a duas faixas no intervalo HD:

- primeira faixa contém identidade, descrição, badges e valor principal;
- segunda faixa contém datas, métricas e ações;
- textos e rótulos das ações permanecem visíveis;
- áreas usam `min-width: 0` e quebra controlada para impedir colisões;
- layout de celular existente permanece separado.

Categorias e objetivos devem seguir mesma regra quando suas linhas excederem largura disponível.

## Dashboard

- Hero deve conter título, descrição, relógio e clima sem cortar lateral direita.
- Cards de resumo usam grade `2×2` em HD.
- Painéis principais quebram para uma coluna quando duas colunas não couberem na área útil.
- Conteúdo interno não deve criar largura mínima maior que viewport.

## Verificação

Verificar visualmente `1366×768` nos temas claro e noturno, cobrindo páginas principais e ausência de rolagem horizontal. Testes automatizados e comandos de teste somente serão executados se solicitados pelo usuário, conforme regras do projeto.
