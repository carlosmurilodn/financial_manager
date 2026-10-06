# Separacao entre Financeiro e Saude e Bem-Estar

## Contexto

O aplicativo passou a ter dois dominios principais:

- **Financeiro**, com o sistema ja existente de dashboard, despesas, receitas, cartoes, categorias, objetivos financeiros e relatorios.
- **Saude e Bem-Estar**, com o fluxo de progresso corporal, metas de processo, revisoes semanais e registros de vitorias.

Os dois dominios devem continuar dentro do mesmo produto, usando a mesma autenticacao, sessao de usuario e base visual. A separacao desejada e de navegacao e contexto, nao de aplicacoes independentes.

## Objetivo

Criar uma entrada inicial na raiz da aplicacao com dois cards de navegacao:

- **Gerenciador Financeiro**
- **Saude e Bem-Estar**

Cada card leva o usuario para a respectiva area. A raiz deixa de abrir diretamente o dashboard financeiro e passa a funcionar como seletor de contexto.

## Navegacao geral

### Raiz

A rota raiz deve exibir apenas a escolha entre as duas areas principais. A tela deve ser simples, direta e autenticada, preservando o usuario dentro do mesmo aplicativo.

Cards previstos:

- **Gerenciador Financeiro**: abre o sistema financeiro existente.
- **Saude e Bem-Estar**: abre o dashboard principal de saude.

### Financeiro

Ao entrar no Financeiro, o usuario deve ver o sistema ja existente, com menu lateral e todas as opcoes atuais do dominio financeiro.

O item **Progresso** deve sair do menu financeiro, pois passara a pertencer ao dominio de Saude e Bem-Estar.

### Saude e Bem-Estar

Ao entrar em Saude, o usuario deve ver um menu lateral proprio, com titulo **Saude e Bem-Estar**.

Menu previsto:

- Progresso, como dashboard principal.
- Historico de Peso.
- Objetivos por Etapa.
- Progresso Alem da Balanca.
- Metas que Dependem de Voce.
- Perguntas da Semana.
- Como Foi sua Semana?
- Vitorias que a Balanca Nao Mostra.
- Sair.

O alterador de temas deve ficar no final do menu, mantendo o comportamento global de tema da aplicacao.

## Rotas sugeridas

As rotas podem ser organizadas por contexto para deixar clara a separacao:

- `/financeiro`: dashboard financeiro atual.
- `/saude`: dashboard principal de Saude e Bem-Estar.
- `/saude/peso`: historico de peso.
- `/saude/objetivos`: objetivos por etapa.
- `/saude/alem-da-balanca`: progresso alem da balanca.
- `/saude/metas`: metas que dependem de voce.
- `/saude/perguntas`: perguntas da semana.
- `/saude/revisao`: como foi sua semana.
- `/saude/vitorias`: vitorias que a balanca nao mostra.

As rotas atuais de saude sob `/progresso` podem ser migradas ou redirecionadas em etapa propria para preservar navegacao existente durante a transicao.

## Layouts e responsabilidades

A aplicacao deve ter separacao clara entre:

- tela de escolha de contexto;
- layout/menu financeiro;
- layout/menu de Saude e Bem-Estar.

O dominio financeiro nao deve carregar itens de saude no menu. O dominio de saude nao deve carregar atalhos financeiros, exceto a saida do contexto quando definida.

Componentes compartilhados, como tema, flash messages, autenticacao e base responsiva, devem continuar reutilizados.

## Decisoes de produto

- Financeiro e Saude ficam juntos no mesmo app.
- A raiz vira seletor de contexto.
- O menu financeiro permanece como hoje, exceto pela remocao de **Progresso**.
- Saude ganha menu proprio com titulo **Saude e Bem-Estar**.
- Progresso vira dashboard principal da area de Saude.
- O tema continua global e fica no final do menu.

## Fora do escopo desta etapa

- Separar bancos, usuarios ou autenticacao.
- Criar novo app Rails.
- Alterar regras financeiras existentes.
- Criar novas tabelas para itens de saude que ainda nao existam.
- Implementar permissoes diferentes por dominio.
- Reescrever dashboard financeiro.

## Criterios de aceite

- A raiz apresenta dois cards: Financeiro e Saude e Bem-Estar.
- Card Financeiro abre o dashboard financeiro existente.
- Card Saude abre a area de Saude e Bem-Estar.
- Menu financeiro nao exibe **Progresso**.
- Menu de Saude exibe titulo **Saude e Bem-Estar**.
- Menu de Saude contem os itens definidos.
- Alterador de temas aparece no final do menu de Saude.
- Rotas existentes de saude continuam acessiveis ou recebem redirecionamento adequado.

## Validacao prevista

Validar manualmente:

- acesso autenticado a raiz;
- navegacao pelos dois cards;
- menu financeiro sem **Progresso**;
- menu de Saude com todos os itens;
- comportamento do botao **Sair**;
- alteracao de tema no menu de Saude;
- responsividade em desktop e mobile.

Testes automatizados devem ser criados apenas se solicitados.
