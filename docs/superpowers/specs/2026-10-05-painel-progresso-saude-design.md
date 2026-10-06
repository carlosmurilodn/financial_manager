# Painel separado de progresso de saúde

## Contexto

O sistema financeiro terá uma área separada para acompanhar progresso de saúde e rotina. A proposta vem de um MVP deliberadamente pequeno: um painel de progresso, não um aplicativo completo de dieta, treino ou controle de peso.

A balança deve ser uma métrica dentro do contexto maior, sem virar a avaliação principal do esforço semanal.

## Problema

O usuário quer transformar a ideia em um menu próprio do sistema, acessado por uma rota separada, sem misturar esse fluxo com o dashboard financeiro.

O primeiro passo precisa entregar navegação e estrutura visual suficiente para validar a ideia antes de criar persistência, formulários ou regras mais complexas.

## Solução aprovada

Criar uma nova seção chamada **Progresso**, acessível pelo menu lateral e por rota própria.

A tela inicial será estática no MVP e deverá apresentar as principais camadas do conceito:

- objetivo maior;
- metas de processo;
- indicadores de progresso;
- revisão semanal;
- vitórias que a balança não mostra.

Essa tela servirá como base visual e funcional para uma próxima etapa com registros reais.

## Rota e navegação

A aplicação terá uma rota dedicada:

- `GET /progresso`

O menu lateral ganhará um item **Progresso**, separado dos itens financeiros atuais. O item deverá ficar visível para usuários autenticados junto aos demais atalhos da aplicação.

O estado ativo do menu deverá funcionar quando o usuário estiver na rota de progresso.

## Estrutura da tela

A primeira versão da tela deverá seguir o padrão visual das páginas internas já existentes, com hero, blocos e cards simples.

Conteúdo sugerido:

- objetivo: chegar abaixo de 100 kg;
- referência inicial: aproximadamente 120 a 121 kg;
- marco atual: 115 kg;
- próximos marcos: 110, 105 e 99,9 kg;
- metas semanais de processo, como treino, alimentação planejada, marmitas, registro e caminhada;
- indicadores por categoria: corpo, treino, alimentação e bem-estar;
- perguntas da revisão semanal;
- lista de vitórias comportamentais.

Os textos devem evitar tom punitivo. O foco é mostrar avanço, consistência e comportamento executado.

## Decisões técnicas

Usar um controller dedicado para manter a seção isolada do dashboard financeiro.

A implementação inicial não terá banco de dados novo, models, migrations nem formulários persistentes. Os dados exibidos serão estáticos, suficientes para validar layout, rota e navegação.

Estilos específicos podem ficar em um arquivo de página próprio, importado pelo stylesheet principal, seguindo a organização atual de `app/assets/stylesheets/pages/`.

## Critérios de aceite

- `/progresso` abre uma tela própria de progresso.
- O menu lateral exibe o item **Progresso**.
- O item **Progresso** fica ativo quando a rota atual for `/progresso`.
- A tela não altera dados financeiros nem cálculos existentes.
- A tela comunica que o foco principal são metas de processo, não apenas peso.
- O conteúdo fica legível nos layouts desktop e mobile existentes.

## Fora do escopo

- Criar cadastro de peso, treino, refeições ou medidas.
- Criar tabelas, models, migrations ou seeds.
- Criar check-in diário funcional.
- Criar revisão semanal persistente.
- Criar gráficos reais.
- Integrar com dispositivos, dieta, fotos ou histórico de treino.

## Validação prevista

Validar manualmente:

- rota `/progresso`;
- item novo no menu;
- estado ativo do menu;
- renderização da página em desktop e mobile.

Testes automatizados só serão adicionados se solicitados.
