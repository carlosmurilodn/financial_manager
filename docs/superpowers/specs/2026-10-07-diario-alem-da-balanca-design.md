# Além da Balança: diário pessoal com fechamento semanal

## Estado e objetivo

Especificação proposta para implementação futura. Este documento não representa uma funcionalidade já entregue nem autoriza, por si só, alterações no código.

Unificar **Além da Balança** e **Perguntas** em um diário pessoal: registros diários leves, reflexão semanal aprofundada e histórico integrado. A experiência deve ajudar a registrar sentimentos, acontecimentos, necessidades e ações possíveis, sem exigir o preenchimento de um questionário completo.

Nome do módulo: **Além da Balança**. Descrição: **Meu diário e reflexão semanal**.

## Situação atual

- `WeeklyWellbeing` registra energia, humor e satisfação com a rotina, de 1 a 5, além de observação opcional. Atualmente os três indicadores são obrigatórios e existe um registro por usuário e semana.
- `WeeklyHealthReview` permite registros diários e semanais com cinco respostas: o que funcionou, obstáculos, controle, ajustes e meta mínima. Permite respostas parciais, exigindo pelo menos uma resposta.
- As duas experiências possuem entradas distintas no menu e registros separados.

A proposta integra a medição de como o período foi com a reflexão sobre o que influenciou essa experiência.

## Estrutura da experiência

### Tela inicial

Uma única entrada no menu, **Além da Balança**, reúne:

- Ação **Registrar meu dia**.
- Ação **Fazer fechamento semanal**.
- Visão da semana selecionada, com dias registrados e fechamento, quando existir.
- Indicadores agregados com a quantidade de registros utilizada em cada cálculo.
- Histórico em ordem cronológica decrescente, com filtros por período e tipo de registro.

Se o dia ou a semana já tiver registro, a ação abre a edição. Não criar duplicatas para o mesmo usuário, tipo e período.

### Diário

Um registro por dia, com data editável. Fluxo:

1. Selecionar data e preencher indicadores desejados.
2. Escrever relato livre ou responder perguntas curtas.
3. Opcionalmente selecionar um cenário para receber ajuda de escrita.
4. Salvar parcialmente ou revisar o registro.

O diário deve permitir uso rápido, sem exigir passar por todas as perguntas. O usuário pode escrever somente no relato livre, responder uma pergunta ou registrar um indicador.

### Fechamento semanal

Um fechamento por semana, de segunda a domingo. Pode ser criado mesmo sem registros diários e editado posteriormente.

O fluxo apresenta primeiro o resumo dos registros daquela semana e depois os nove temas de reflexão. Os registros diários permanecem acessíveis durante o fechamento, sem perder o texto em edição.

O resumo automático contém somente dados objetivos: dias registrados, médias e acesso aos relatos. As conclusões, interpretações e o próximo passo são escritos pelo usuário. Não gerar interpretações psicológicas automaticamente.

## Indicadores

Todos os indicadores são opcionais, tanto no diário quanto no fechamento:

| Indicador | Escala de 1 a 5 |
| --- | --- |
| Energia | Muito baixa → muito alta |
| Humor | Muito baixo → muito alto |
| Satisfação com a rotina | Muito baixa → muito alta |
| Ansiedade/tensão | Muito baixa → muito alta |
| Sobrecarga | Muito baixa → muito alta |

Exibir os extremos de cada escala e permitir limpar a escolha. Ansiedade e sobrecarga têm sentido diferente de energia e humor: notas maiores não representam melhora. Não somar indicadores em uma nota geral.

Na visão semanal, médias vêm exclusivamente dos registros diários. A avaliação preenchida no fechamento representa a percepção da semana e aparece separadamente. Ausência de resposta não equivale a zero.

## Perguntas do diário

Relato livre: **O que quero registrar sobre hoje?**

Quatro perguntas opcionais, com ajudas de escrita:

| Pergunta | Ajuda |
| --- | --- |
| Como me senti hoje? | Que emoções apareceram? Houve alguma mudança ao longo do dia? |
| O que me fez bem? | Pense em uma pessoa, atividade, conversa ou pequeno momento que trouxe leveza. |
| O que pesou em mim? | Algo incomodou, preocupou ou consumiu energia? O que aconteceu e como isso afetou você? |
| Do que eu precisei hoje? | Descanso, apoio, espaço, organização ou outra necessidade? Conseguiu atender isso? |

O usuário pode registrar também **Algo que reconheço em mim hoje** e **Meu próximo pequeno passo**, como aprofundamentos opcionais.

## Cenários e ajuda de escrita

Selecionar um cenário é opcional. Ele oferece sugestões, sem adicionar campos obrigatórios nem apagar respostas existentes. A pergunta continua disponível com ou sem cenário.

| Cenário | Sugestões de reflexão |
| --- | --- |
| Dia difícil | O que mais pesou? O que ajudou a atravessar o dia? Do que preciso agora? |
| Conquista ou momento bom | O que aconteceu? O que quero reconhecer em mim? O que vale repetir? |
| Rotina corrida | O que consumiu minha energia? Qual limite ou ajuda faria diferença? |
| Desânimo | Como isso apareceu no meu dia? Houve algum momento de alívio? Qual passo parece possível? |
| Mudança de hábito | O que facilitou? O que dificultou? Que ajuste pequeno quero experimentar? |
| Conflito ou preocupação | O que aconteceu? O que ficou na minha cabeça? O que depende de mim agora? |
| Reflexão livre | Escreva sobre o que importa neste momento, sem roteiro. |

As sugestões funcionam como apoio de escrita. Não são diagnóstico, avaliação clínica ou recomendações de tratamento. Associações com técnicas e conteúdos do Manual só devem ser adicionadas depois de conferir as fontes originais; as referências incompletas do texto de inspiração não são requisitos desta versão.

## Perguntas do fechamento semanal

Todas as respostas são opcionais. A versão semanal oferece maior profundidade que o diário.

### 1. Como foi estar na minha própria cabeça?

**Como me senti na maior parte desta semana?**

Ajuda: estive mais tranquilo, ansioso, irritado, animado, triste, cansado ou esperançoso? Alguma emoção se repetiu? Houve mudanças ao longo da semana?

### 2. O que me fez bem?

**Quais momentos, pessoas ou coisas me fizeram bem?**

Ajuda: quando me senti mais leve, conectado ou satisfeito? O que estava acontecendo? Pode ser algo pequeno.

### 3. O que pesou em mim?

**O que mais me incomodou, preocupou ou drenou minha energia?**

Ajuda: houve cobrança, conflito, medo ou frustração? O que aconteceu e o que continuou ocupando minha cabeça depois?

### 4. O que minha mente ficou me dizendo?

**Que pensamentos apareceram com frequência?**

Ajuda: alguma frase se repetiu, como “eu deveria”, “vai dar errado” ou “preciso resolver”? Consigo olhar para esse pensamento de outra forma agora?

### 5. O que percebi sobre mim?

**O que percebi sobre mim nesta semana?**

Ajuda: notei uma necessidade, limite, medo ou desejo? Alguma reação me surpreendeu? O que parece se repetir? O que foi importante para mim?

### 6. O que estava nas minhas mãos?

**O que dependia de mim e o que não dependia?**

Ajuda: existe algo que eu poderia fazer diferente? Estou me cobrando por algo que não controlava? Há alguma ação possível agora?

### 7. Do que eu precisava?

**Do que mais precisei nesta semana? Consegui atender essa necessidade?**

Sugestões selecionáveis, permitindo múltiplas escolhas: descanso, apoio, espaço, segurança, diversão, conexão, reconhecimento, organização, silêncio, autonomia e outro. A opção “outro” permite descrição livre.

Ajuda: o que dificultou atender essas necessidades? O que poderia ajudar na próxima semana?

### 8. Do que eu me orgulho?

**O que fiz bem ou gostaria de reconhecer em mim?**

Ajuda: uma decisão, um limite, uma conversa, um cuidado comigo ou ter continuado em um dia difícil.

### 9. O que quero levar comigo?

**O que quero continuar fazendo ou fazer diferente?**

Ajuda: o que vale repetir? Existe uma conversa ou problema concreto para resolver? Qual mudança pequena parece realista?

Campo separado: **Meu próximo pequeno passo**.

## Navegação e salvamento

- Mostrar uma pergunta por etapa no modo guiado, com indicação da posição e acesso direto às demais etapas.
- Oferecer **Anterior**, **Pular**, **Salvar e continuar** e **Salvar e sair**.
- Oferecer **Ver todas as perguntas** para leitura e edição conjunta.
- Pular mantém eventuais respostas já preenchidas; limpar uma resposta exige editar o campo.
- Salvar não exige completar todas as etapas. Deve existir pelo menos um indicador, texto não vazio ou necessidade selecionada; cenário sozinho não constitui registro.
- Cada campo de texto aceita até 2.000 caracteres, seguindo o limite atual das respostas e observações.
- Validar indicadores como inteiros de 1 a 5 e datas válidas. Semanas são identificadas pela segunda-feira.
- Se o salvamento falhar, manter os dados em tela e mostrar o erro junto ao campo ou uma mensagem geral quando não houver campo correspondente.
- Avançar sem salvar não deve ser apresentado como dado persistido. Ao sair com alterações não salvas, pedir confirmação para evitar perda acidental.
- Não usar percentual de completude como medida de desempenho pessoal: respostas parciais são registros válidos.

## Histórico e resumo semanal

Cada semana agrupa os registros diários e o fechamento. Exibir:

- Período da semana e quantidade de dias registrados.
- Média de cada indicador, com uma casa decimal e quantidade de respostas consideradas.
- Percepção semanal preenchida no fechamento, separada das médias diárias.
- Trechos das respostas sobre o que fez bem, o que pesou, percepção pessoal e próximo passo, quando preenchidas.
- Acesso ao conteúdo completo e à edição dos registros.

As médias se atualizam ao editar ou excluir um diário. O texto já escrito no fechamento permanece como reflexão do usuário; não é reescrito automaticamente.

Não inferir tendências a partir de texto livre. Comparações numéricas devem informar a cobertura dos períodos e evitar rótulos de melhora ou piora quando não houver dados suficientes para a comparação. Um indicador sem resposta aparece como **Sem registro**.

## Dados e arquitetura proposta

A interface será única, com uma representação persistente para registros diários e semanais. A definição exata de nomes de tabela e classes pertence ao plano de implementação.

Cada registro deve armazenar:

- Usuário, tipo diário ou semanal e data de referência.
- Cinco indicadores opcionais.
- Relato livre, respostas por tema, necessidades selecionadas, descrição de outra necessidade e próximo passo.
- Cenário opcional e identificação dos dados migrados, quando aplicável.
- Datas de criação e atualização.

Garantir unicidade por usuário, tipo e data de referência também no banco. No semanal, a referência é sempre a segunda-feira. A data do diário segue a convenção de data e fuso já utilizada pela aplicação.

Separar responsabilidades: persistência e validações no modelo, catálogo de perguntas e ajudas de escrita em uma estrutura própria, agregação semanal em consulta dedicada e apresentação em componentes ou parciais seguindo os padrões existentes. Não concentrar perguntas, migração, cálculos e interface no controller.

Todos os acessos e agregações devem ser limitados ao usuário autenticado, incluindo edição, exclusão e migração de dados.

## Preservação dos registros existentes

Migrar sem descartar conteúdo:

| Origem | Destino |
| --- | --- |
| Bem-estar semanal: energia, humor e satisfação | Indicadores da percepção semanal |
| Bem-estar semanal: observação | Relato livre do fechamento |
| Perguntas diárias ou semanais: `worked_well` | O que me fez bem |
| `obstacles` | O que pesou em mim |
| `within_control` | O que estava nas minhas mãos |
| `next_adjustments` | O que quero levar comigo |
| `minimum_goal` | Meu próximo pequeno passo |

Respostas antigas mantêm identificação como conteúdo importado de perguntas anteriores, pois a redação original pode diferir das novas perguntas. Respostas diárias antigas sobre controle e ajustes devem continuar visíveis em uma seção de conteúdo anterior, mesmo quando não fazem parte do roteiro diário curto.

Se houver bem-estar e reflexão na mesma semana, combinar indicadores e respostas no mesmo fechamento. Não preencher novos indicadores artificialmente. Manter observações e respostas em campos distintos, preservando seus limites individuais.

A migração deve ser transacional, verificável e segura para reexecução, com rastreabilidade dos registros de origem. Não remover tabelas ou dados antigos antes da conferência da conversão. O plano de implementação deve definir reversão e tratamento de conflitos sem sobrescrever conteúdo do usuário.

Links antigos devem continuar levando ao registro correspondente ou à área unificada. Remover a entrada **Perguntas** do menu somente quando a nova experiência e o acesso ao conteúdo anterior estiverem disponíveis.

## Limites desta versão

- Sem interpretação por IA, diagnóstico, pontuação geral de saúde mental ou geração automática de conclusões.
- Sem lembretes, notificações, exportação de relatório ou anexos nesta primeira versão.
- Sem exigência de registros diários para fazer um fechamento semanal.
- Sem novas dependências ou alterações em módulos financeiros como parte desta fusão.

## Critérios de aceitação para implementação

1. Uma entrada no menu oferece diário, fechamento semanal e histórico.
2. É possível salvar um diário com apenas um indicador ou uma resposta e retomá-lo depois.
3. É possível fazer fechamento sem diário, pular etapas e revisar todas as perguntas.
4. Indicadores ausentes não entram nas médias; percepção semanal não entra na média diária.
5. Editar um diário atualiza os agregados sem reescrever a reflexão semanal.
6. Todos os registros antigos continuam acessíveis, incluindo respostas sem equivalente no roteiro diário curto.
7. Registros simultâneos de bem-estar e reflexão da mesma semana são integrados sem perda ou duplicação.
8. Nenhum usuário consegue acessar registros ou agregados de outro usuário.
9. Erros de validação e persistência preservam o conteúdo digitado.
10. Interface funciona em dispositivos móveis e por teclado, com rótulos claros, foco adequado entre etapas e indicadores de progresso compreensíveis sem depender de cor.

Esses critérios orientam a revisão da futura implementação. Criação e execução de testes dependem de solicitação explícita do usuário, conforme `AGENTS.md`.
