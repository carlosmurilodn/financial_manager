# Refinamentos do layout HD

Esta especificação substitui as definições de Sidebar e Cabeçalhos/KPIs do documento `2026-08-27-layout-responsivo-hd-design.md`.

## Objetivo

Refinar distribuição visual em telas HD, especialmente `1366×768`, preservando espaço útil, hierarquia dos cabeçalhos e leitura das tabelas no celular.

## Escopo

Alterar somente apresentação das páginas de Despesas, Receitas, Cartões, Categorias e Objetivos, formulários New/Edit, sidebar no intervalo HD e tabela de despesas no Show de Cartões. Regras de negócio, consultas, rotas e dados permanecem inalterados.

## Breakpoints

- Entre `1200px` e `1440px`: aplicar refinamentos HD dos heroes, formulários e sidebar.
- Até `767px`: preservar tabela da fatura do cartão com rolagem horizontal.
- Entre `768px` e `1199px`, e acima de `1440px`: preservar comportamento visual atual.

## Heroes das listagens

Nas listagens de Despesas, Receitas, Cartões, Categorias e Objetivos, o hero HD usará três colunas e duas linhas:

```text
Título      | KPI 1 | KPI 2
Botão Novo  | KPI 3 | KPI 4
```

- Título e botão ficam na primeira coluna, alinhados à esquerda.
- Botão Novo mantém largura e altura naturais; não preenche toda a célula.
- KPIs ocupam as duas colunas restantes com larguras equilibradas.
- Quando houver somente três KPIs, a posição inferior direita permanece vazia.
- Estrutura deve separar semanticamente a ação de cadastro dos KPIs, sem duplicar links.

## Formulários New/Edit

- Link Voltar mantém largura e altura naturais no intervalo HD.
- Aparência e alinhamento seguem o padrão compacto usado nos heroes das telas Show.
- Link não deve esticar para preencher a segunda coluna do cabeçalho.

## Sidebar no HD

- Sidebar permanece aberta, usando largura normal e exibindo textos dos itens.
- Conteúdo principal usa margem compatível com a sidebar aberta.
- Preferência salva de recolhimento não deve forçar sidebar compacta dentro do intervalo HD.
- Navegação móvel e comportamento fora do intervalo HD permanecem inalterados.

## Tabela da fatura no celular

- Tabela de despesas no Show de Cartões continua sendo uma tabela até `767px`.
- Cabeçalho, linhas e colunas permanecem visíveis na estrutura tabular.
- Contêiner recebe rolagem horizontal e tabela mantém largura mínima suficiente para leitura.
- Conversão atual das linhas em cards empilhados deixa de ser aplicada somente a essa tabela.

## Verificação

Conferir visualmente:

- heroes das cinco listagens em `1366×768`;
- formulários New e Edit em `1366×768`;
- sidebar aberta e conteúdo sem sobreposição no intervalo HD;
- tabela da fatura em viewport móvel, com rolagem horizontal;
- ausência de regressão nas faixas fora do escopo.

Testes automatizados e comandos de teste não serão executados sem solicitação do usuário, conforme regras do projeto.
