# 🪞 Autoconhecimento — Especificação de Estrutura e Fluxos

## 1. Objetivo

Refatorar e fundir os módulos atuais:

- **Perguntas**
- **Além da Balança**

em um único módulo chamado:

# 🪞 Autoconhecimento

O novo módulo deve reunir:

1. **📝 Diário**
2. **🔎 Revisão Semanal**
3. **📊 Minha Evolução**

A filosofia do módulo deve ser:

> **Hoje eu registro → no fim da semana eu interpreto → com o tempo eu identifico padrões.**

Não criar Diário e Revisão Semanal como dois formulários praticamente iguais.

Eles possuem funções diferentes:

- **Diário:** registrar acontecimentos, emoções, pensamentos e necessidades daquele dia.
- **Revisão Semanal:** analisar padrões, aprendizados e direção a partir da semana inteira.
- **Minha Evolução:** acompanhar métricas e registros ao longo do tempo.

---

## 2. Navegação

Remover do menu lateral as entradas independentes:

- Além da Balança
- Perguntas

Adicionar uma única entrada:

**Autoconhecimento**

Ícone sugerido:

`psychology_alt`

ou, caso não esteja disponível:

`self_improvement`

Ao acessar:

`/progresso/autoconhecimento`

mostrar a página principal do módulo com três áreas/tabs:

- Diário
- Revisão Semanal
- Minha Evolução

Preferencialmente usar navegação interna em abas/pills seguindo o design atual do sistema.

URLs sugeridas:

```text
/progresso/autoconhecimento
/progresso/autoconhecimento/diario
/progresso/autoconhecimento/semanas
/progresso/autoconhecimento/evolucao
```

A URL raiz de Autoconhecimento pode redirecionar ou abrir diretamente o Diário.

---

## 3. Estrutura conceitual

### 📝 Diário

Pergunta:

> **O que aconteceu comigo hoje?**

O Diário deve ser rápido o suficiente para ser utilizado frequentemente.

Não deve parecer uma avaliação psicológica extensa.

Tempo esperado de preenchimento:

**3 a 8 minutos.**

### 🔎 Revisão Semanal

Pergunta:

> **O que esta semana está me mostrando sobre mim?**

É uma reflexão mais profunda.

Ela deve aproveitar os registros realizados no Diário durante a semana e apresentar um pequeno resumo antes das perguntas.

Tempo esperado:

**10 a 20 minutos.**

### 📊 Minha Evolução

Pergunta:

> **O que vem mudando ao longo do tempo?**

Não é um formulário.

É uma área de histórico, indicadores e padrões.

---

# 4. DIÁRIO

## 4.1 Cabeçalho

Mostrar:

```text
📝 Diário

Hoje, 07 de outubro de 2026

Um espaço para registrar como foi o seu dia.
Não existe resposta certa e você não precisa responder tudo.
```

Permitir escolher outra data.

Deve existir no máximo **um Diário por usuário por data**.

Caso exista registro:

- abrir o registro existente para edição;
- não criar duplicata.

---

# 5. Termômetro do dia

Antes das perguntas, mostrar uma seção visual chamada:

## 🌡️ Como estou hoje?

Usar escala de **1 a 5**.

### Humor

```text
1 — Muito baixo
2 — Baixo
3 — Intermediário
4 — Bom
5 — Muito bom
```

Dica exibida:

> Pense no tom emocional geral do seu dia, não apenas no que está sentindo neste exato momento.

### Energia

```text
1 — Muito baixa
2 — Baixa
3 — Intermediária
4 — Boa
5 — Muito boa
```

Dica:

> Considere disposição física e mental para fazer as coisas, e não apenas cansaço corporal.

### Tensão / Ansiedade

```text
1 — Muito baixa
2 — Baixa
3 — Moderada
4 — Alta
5 — Muito alta
```

Dica:

> Pense em preocupação, inquietação, tensão corporal, sensação de alerta ou dificuldade de desligar a cabeça.

Importante: nesta métrica, número maior significa **mais tensão**, ao contrário de Humor e Energia.

A interface deve deixar isso claro.

---

# 6. Perguntas fixas do Diário

As dicas abaixo **fazem parte da interface e devem ser exibidas abaixo da pergunta** em `<small>`, texto auxiliar ou componente equivalente.

Não remover as dicas.

Cada campo textual:

- opcional;
- máximo de 2.000 caracteres;
- permitir salvar registro parcial.

## Pergunta 1 — 🧠 O que mais ocupou minha cabeça hoje?

**Campo:** `main_thought`

**Dica:**

> Pode ser uma preocupação, uma conversa, algo que aconteceu, uma decisão, uma lembrança, algo que você está esperando ou até uma coisa boa que ficou voltando à sua mente.

Placeholder:

> O que ficou passando pela minha cabeça hoje...

## Pergunta 2 — 🌊 O que aconteceu que mais mexeu comigo?

**Campo:** `meaningful_event`

**Dica:**

> Pense em algum acontecimento que mudou seu humor ou chamou sua atenção. Pode ter sido algo grande ou aparentemente pequeno: uma conversa, uma notícia, um problema, uma conquista ou um momento específico do dia.

Placeholder:

> Hoje aconteceu...

## Pergunta 3 — ❤️ O que eu senti diante disso?

**Campo:** `emotions`

**Dica:**

> Tente ir além de “bem” ou “mal”. Houve ansiedade, irritação, tristeza, alívio, culpa, vergonha, alegria, orgulho, frustração, esperança, medo ou outra emoção? Você pode registrar mais de uma.

Placeholder:

> Percebi que estava me sentindo...

## Pergunta 4 — 🌱 Teve algo bom que eu quero guardar deste dia?

**Campo:** `positive_moment`

**Dica:**

> Pode ser uma conquista, algo que funcionou, um momento agradável, uma conversa, alguma coisa que você fez por si mesmo ou simplesmente um pequeno instante que vale lembrar.

Placeholder:

> Uma coisa boa de hoje foi...

---

# 7. Necessidade do dia

Adicionar:

## 🤲 Do que eu mais precisei hoje?

Permitir seleção opcional de um ou mais chips:

- Descanso
- Apoio
- Espaço
- Segurança
- Diversão
- Conexão
- Reconhecimento
- Organização
- Silêncio
- Autonomia
- Movimento
- Companhia
- Tempo sozinho
- Outro

Campo opcional:

`needs_notes`

Pergunta auxiliar:

> **Consegui atender essa necessidade?**

Dica:

> Você não precisa ter conseguido. A intenção aqui é perceber do que estava precisando e o que facilitou ou dificultou conseguir isso.

---

# 8. Perguntas rotativas do Diário

Depois das perguntas principais, mostrar uma seção:

## 💭 Uma pergunta para pensar

Escolher **uma pergunta complementar por dia**.

Não mudar a pergunta ao recarregar a página.

A pergunta escolhida deve ser determinada pela data para que seja estável naquele dia.

Banco inicial:

### 1
**Você se cobrou por alguma coisa hoje?**

Dica:

> Pense se você exigiu de si algo que talvez não exigisse de outra pessoa na mesma situação.

### 2
**Teve alguma coisa que você evitou hoje?**

Dica:

> Pode ser uma tarefa, decisão, conversa, sentimento ou situação que você foi adiando ou tentando não enfrentar.

### 3
**Teve algum momento em que você se sentiu mais você mesmo?**

Dica:

> Pense em algum momento em que você se sentiu espontâneo, confortável ou conectado com quem você é.

### 4
**O que eu gostaria que alguém tivesse entendido sobre mim hoje?**

Dica:

> Pense em algo que você sentiu, precisou ou tentou comunicar e que talvez tenha passado despercebido.

### 5
**Alguma coisa foi melhor do que eu esperava?**

Dica:

> Pode ter sido algo que você antecipou negativamente e acabou sendo mais simples, tranquilo ou agradável.

### 6
**O que eu gostaria de repetir amanhã?**

Dica:

> Pense em uma atitude, hábito, decisão ou momento de hoje que merece aparecer novamente.

### 7
**Minha mente transformou algum problema pequeno em algo muito maior?**

Dica:

> Pense se alguma preocupação continuou ocupando sua cabeça mesmo depois de você já não ter nada concreto para fazer a respeito.

### 8
**Eu fiz alguma coisa hoje mesmo sem estar com vontade?**

Dica:

> Pode ser algo pequeno. Às vezes agir apesar da falta de motivação também merece ser reconhecido.

### 9
**Teve algo que eu queria controlar, mas não dependia de mim?**

Dica:

> Pense em comportamentos de outras pessoas, resultados, imprevistos ou situações sobre as quais você tinha pouca influência real.

### 10
**Do que eu me orgulho hoje?**

Dica:

> Não precisa ser uma grande conquista. Pode ser ter tentado, colocado um limite, terminado algo, cuidado de si ou atravessado um dia difícil.

Campo:

`reflection_answer`

Também armazenar identificador da pergunta apresentada:

`reflection_prompt_key`

---

# 9. Campo livre do Diário

No final:

## ✍️ Quer deixar mais alguma coisa registrada?

Campo:

`notes`

Dica:

> Este espaço é livre. Use para registrar alguma coisa que não coube nas perguntas anteriores ou simplesmente escrever sobre o seu dia.

Não obrigatório.

---

# 10. Salvamento do Diário

Botões:

```text
Cancelar
Salvar Diário
```

Permitir salvar mesmo sem preencher todas as perguntas.

Para evitar registros completamente vazios, exigir pelo menos:

- uma métrica;

OU

- uma resposta textual;

OU

- uma necessidade selecionada.

Mensagem:

> Diário salvo com sucesso.

---

# 11. Histórico do Diário

Na aba Diário, abaixo ou em uma seção separada, mostrar registros anteriores.

Exemplo:

```text
07 OUT
Humor 3 • Energia 4 • Tensão 4

“Fiquei pensando bastante no problema...”

Ver registro
```

Exibir inicialmente:

- data;
- humor;
- energia;
- tensão;
- pequeno trecho de `main_thought`, caso exista.

Ações:

- visualizar;
- editar;
- excluir.

Filtros:

- De;
- Até.

Manter padrão atual de paginação do projeto.

---

# 12. REVISÃO SEMANAL

A Revisão Semanal deve ser **diferente do Diário**.

Ela não pergunta novamente “o que aconteceu hoje?”.

Sua função é:

- consolidar;
- comparar;
- identificar recorrências;
- produzir aprendizado;
- definir direção.

Deve existir no máximo:

**uma Revisão Semanal por usuário por semana.**

Semana:

segunda-feira → domingo.

---

# 13. Cabeçalho da Revisão Semanal

Exemplo:

```text
🔎 Revisão Semanal

Semana de 05/10/2026 a 11/10/2026

Olhe para a semana como um todo.
A ideia não é julgar se ela foi boa ou ruim,
mas perceber o que ela pode ensinar sobre você.
```

---

# 14. Resumo automático da semana

Antes das perguntas, utilizar os Diários daquele período.

Exemplo:

```text
📊 Sua semana até aqui

4 dias registrados

Humor médio       3,2 / 5
Energia média     3,6 / 5
Tensão média      4,0 / 5

Melhor humor      quinta-feira
Maior tensão      terça-feira
```

Quando houver dados suficientes, também mostrar:

```text
Humor
Seg  3
Ter  2
Qua  —
Qui  4
Sex  4
Sáb  —
Dom  —
```

Não inventar interpretações psicológicas automáticas.

Nesta primeira versão, apenas apresentar os dados registrados.

Se não existirem Diários:

> Você ainda não registrou nenhum Diário nesta semana. Tudo bem: ainda é possível fazer sua revisão semanal normalmente.

---

# 15. Perguntas da Revisão Semanal

Todas as perguntas continuam opcionais.

Máximo:

2.000 caracteres por resposta.

As dicas abaixo devem permanecer visíveis.

## 1 — 🔁 O que mais se repetiu nesta semana?

Campo:

`recurring_patterns`

Dica:

> Pense em situações, pensamentos, emoções, preocupações ou comportamentos que apareceram em vários dias. Existe algo que parece estar se tornando um padrão?

## 2 — 🌤️ O que mais me fez bem?

Campo:

`what_helped`

Dica:

> Pense em pessoas, lugares, atividades, hábitos ou momentos em que você se sentiu mais tranquilo, interessado, conectado, satisfeito ou com mais energia.

## 3 — 🌧️ O que mais drenou minha energia ou pesou em mim?

Campo:

`what_drained`

Dica:

> Houve algum problema, conflito, cobrança, preocupação ou frustração que ocupou muito espaço? Alguma situação continuou na sua cabeça mesmo quando já não havia nada para resolver naquele momento?

## 4 — 💭 Que padrão percebi nos meus pensamentos?

Campo:

`thought_patterns`

Dica:

> Alguma frase apareceu várias vezes na sua cabeça? Por exemplo: “eu deveria...”, “vai dar errado...”, “eu nunca...”, “preciso resolver isso...”, “eu estraguei tudo...”. Tente perceber o padrão sem precisar decidir agora se ele está certo ou errado.

## 5 — 🚧 O que eu evitei, adiei ou tentei controlar demais?

Campo:

`avoidance_and_control`

Dica:

> Pense em tarefas, decisões, conversas, sentimentos ou situações que você evitou. Também observe se gastou muita energia tentando controlar alguma coisa que talvez não estivesse totalmente nas suas mãos.

## 6 — 🪞 O que percebi sobre mim nesta semana?

Campo:

`self_discovery`

Dica:

> Alguma reação sua chamou atenção? Você percebeu uma necessidade, limite, medo, desejo ou comportamento recorrente? Descobriu alguma coisa sobre como costuma reagir a determinadas situações?

## 7 — 🤲 Do que eu mais precisei nesta semana?

Campo:

`weekly_needs`

Permitir os mesmos chips utilizados no Diário.

Dica:

> Pense no que parece ter feito falta ou no que mais ajudou: descanso, apoio, espaço, conexão, segurança, autonomia, organização, diversão, silêncio ou outra necessidade.

Campo complementar:

`weekly_needs_notes`

## 8 — 🎛️ O que estava sob meu controle e o que não estava?

Campo:

`control_reflection`

Dica:

> Existe alguma coisa concreta que você poderia fazer diferente? E existe algo pelo qual está se cobrando mesmo não dependendo realmente de você? Diferencie responsabilidade de tentativa de controlar o incontrolável.

## 9 — 🏆 Do que eu me orgulho nesta semana?

Campo:

`proud_of`

Dica:

> Não procure apenas grandes conquistas. Pode ser uma decisão, uma conversa difícil, ter colocado um limite, cuidado de si, cumprido algo pequeno ou simplesmente continuado apesar de uma semana complicada.

## 10 — 🧠 O que aprendi sobre mim?

Campo:

`weekly_learning`

Dica:

> Depois de olhar para a semana inteira, existe alguma conclusão que você gostaria de lembrar no futuro? Algo sobre seus limites, necessidades, pensamentos, relacionamentos, rotina ou maneira de lidar com problemas?

## 11 — 🌱 O que quero continuar fazendo?

Campo:

`keep_doing`

Dica:

> Identifique algo que funcionou e merece continuar. Pode ser pequeno: uma rotina, atitude, comportamento, limite, hábito ou forma de pensar.

## 12 — 🔧 O que quero fazer diferente na próxima semana?

Campo:

`change_next_week`

Dica:

> Não tente consertar tudo de uma vez. Escolha uma mudança que pareça útil, possível e proporcional ao que você percebeu nesta revisão.

## 13 — 👣 Qual é meu próximo pequeno passo?

Campo:

`next_small_step`

Dica:

> Transforme sua intenção em uma ação concreta e pequena. Em vez de “me organizar melhor”, prefira algo como “domingo à noite vou separar as três prioridades da semana”.

Essa resposta deve ganhar destaque visual no `show` da Revisão Semanal.

---

# 16. Navegação da Revisão Semanal

Não mostrar as 13 caixas enormes simultaneamente se isso deixar a página excessivamente pesada.

Preferência de UX:

dividir em etapas.

### Etapa 1 — Minha semana

- resumo automático;
- o que se repetiu;
- o que fez bem;
- o que pesou.

### Etapa 2 — Entendendo meus padrões

- pensamentos;
- evitação/controle;
- percepção sobre mim;
- necessidades;
- controle.

### Etapa 3 — Levando algo comigo

- orgulho;
- aprendizado;
- continuar;
- mudar;
- próximo pequeno passo.

Mostrar indicador:

```text
1 ●━━○━━○ 3
```

ou equivalente seguindo o design atual.

Botões:

```text
← Voltar
Salvar e continuar →
```

Na última etapa:

```text
Salvar revisão
```

As respostas precisam ser preservadas ao navegar entre etapas.

Pode ser feito inicialmente em uma única página com JS escondendo/exibindo as etapas, sem necessidade de persistência intermediária no servidor.

---

# 17. Visualização de uma Revisão Semanal

Organizar o `show` em blocos, não simplesmente imprimir pergunta → resposta treze vezes.

Exemplo:

```text
🔎 Semana de 05 a 11 de outubro

📊 Como foi a semana
Humor 3,2
Energia 3,6
Tensão 4,0

🔁 O que apareceu várias vezes
...

🌤️ O que me fez bem
...

🌧️ O que pesou
...

🪞 O que percebi sobre mim
...

🏆 Algo que reconheço em mim
...

🌱 Quero continuar
...

🔧 Quero mudar
...

👣 MEU PRÓXIMO PASSO
Fazer ...
```

---

# 18. MINHA EVOLUÇÃO

Criar a terceira aba:

# 📊 Minha Evolução

Essa área substitui conceitualmente o antigo **Além da Balança**.

Ela deve mostrar a evolução do usuário sem focar em peso corporal.

---

# 19. Cards principais

No topo:

```text
Humor médio
Energia média
Tensão média
Dias registrados
```

Permitir período:

```text
30 dias
3 meses
6 meses
1 ano
Tudo
```

---

# 20. Gráfico de Humor

Eixo X:

data.

Eixo Y:

1–5.

Mostrar evolução do humor dos registros diários.

---

# 21. Gráfico de Energia

Mesmo padrão.

---

# 22. Gráfico de Tensão

Mesmo padrão.

Lembrar visualmente:

**quanto maior, maior a tensão.**

---

# 23. Satisfação com a rotina

O sistema atual já possui:

`routine_satisfaction`

Não perder esse dado.

Na nova arquitetura, transformar essa informação em uma pergunta **semanal curta**, antes da reflexão:

## Como você avalia sua satisfação com a rotina desta semana?

1 — Muito insatisfeito  
2 — Insatisfeito  
3 — Intermediário  
4 — Satisfeito  
5 — Muito satisfeito

Dica:

> Pense na sua rotina como um todo: organização, ritmo, obrigações, descanso e espaço para coisas importantes para você.

Armazenar na Revisão Semanal.

Isso preserva conceitualmente o indicador existente do módulo Além da Balança.

---

# 24. Necessidades mais frequentes

Na Evolução, mostrar:

## 🤲 Do que tenho precisado?

Exemplo:

```text
Descanso       12
Espaço          8
Organização     7
Conexão         5
```

Usar exclusivamente as necessidades selecionadas explicitamente pelo usuário.

Não tentar inferir necessidades a partir do texto.

---

# 25. Histórico de próximos passos

Criar seção:

## 👣 Passos que eu escolhi

Listar os `next_small_step` das revisões semanais.

Exemplo:

```text
05–11 OUT
Separar no domingo as três prioridades da semana.

28 SET–04 OUT
Conversar sobre...
```

Isso permite perceber se as mesmas intenções aparecem repetidamente.

---

# 26. Arquitetura de dados

O projeto atualmente possui:

- `WeeklyHealthReview`
- `WeeklyWellbeing`

Evitar manter dois conceitos paralelos depois da refatoração.

A arquitetura desejada é:

```text
HealthJournalEntry
    ↓
registros diários

HealthWeeklyReflection
    ↓
revisões semanais
```

OU nomes equivalentes consistentes com a convenção atual do projeto.

Não é obrigatório utilizar exatamente esses nomes se renomear os models existentes representar risco desnecessário.

Priorizar migração segura dos dados.

---

# 27. Dados do Diário

Estrutura sugerida:

```text
health_journal_entries

id
user_id
entry_date

mood
energy
tension

main_thought
meaningful_event
emotions
positive_moment

needs
needs_notes

reflection_prompt_key
reflection_answer

notes

created_at
updated_at
```

Índice único:

```text
[user_id, entry_date]
```

Escalas:

```text
mood    1..5
energy  1..5
tension 1..5
```

`needs` pode ser:

- array PostgreSQL;
- JSONB;

preferir a solução mais consistente com o projeto.

---

# 28. Dados da Revisão Semanal

Estrutura sugerida:

```text
health_weekly_reflections

id
user_id
week_start

routine_satisfaction

recurring_patterns
what_helped
what_drained
thought_patterns
avoidance_and_control
self_discovery

weekly_needs
weekly_needs_notes

control_reflection
proud_of
weekly_learning
keep_doing
change_next_week
next_small_step

created_at
updated_at
```

Índice único:

```text
[user_id, week_start]
```

`week_start` obrigatoriamente segunda-feira.

---

# 29. Migração dos dados existentes

## WeeklyHealthReview

Existem atualmente registros:

```text
review_kind = daily
review_kind = weekly
```

Não descartar essas informações.

### Registros daily

Migrar da melhor forma possível:

```text
worked_well
→ positive_moment

obstacles
→ meaningful_event ou notes

within_control
→ notes

next_adjustments
→ notes

minimum_goal
→ notes
```

Como não existe correspondência perfeita, **não inventar significado**.

Se necessário, criar em `notes` uma seção do tipo:

```text
Dados importados do formato anterior

O que atrapalhou:
...

Controle:
...

Mudança:
...

Meta:
...
```

para preservar integralmente o conteúdo.

### Registros weekly

Mapeamento sugerido:

```text
worked_well
→ what_helped

obstacles
→ what_drained

within_control
→ control_reflection

next_adjustments
→ change_next_week

minimum_goal
→ next_small_step
```

---

# 30. Migração de WeeklyWellbeing

Preservar:

```text
energy
mood
routine_satisfaction
notes
```

Os registros históricos de `WeeklyWellbeing` são semanais, enquanto as novas métricas de humor e energia serão principalmente diárias.

Portanto:

**não transformar artificialmente uma média semanal antiga em Diário de um dia específico.**

Preservar os registros antigos como dados históricos semanais.

Pode ser necessário manter uma tabela histórica ou importar as métricas para uma estrutura compatível com a aba Evolução.

A aba Minha Evolução deve conseguir exibir esses dados anteriores identificando-os como:

**Registro semanal legado**

quando necessário.

Não perder histórico.

---

# 31. Não fazer nesta versão

Não implementar ainda:

- diagnóstico automático;
- interpretação psicológica por IA;
- geração automática de “você está ansioso porque...”;
- análise de sentimento;
- diagnóstico de depressão/ansiedade;
- identificação automática de padrões a partir do conteúdo textual;
- conselho terapêutico automático.

Nesta fase, o sistema deve:

**organizar e devolver ao usuário aquilo que ele próprio registrou.**

---

# 32. UX das perguntas

Requisito importante:

## As dicas não podem desaparecer.

Estrutura esperada:

```text
O que mais ocupou minha cabeça hoje?

Pode ser uma preocupação, uma conversa, algo que aconteceu,
uma decisão, uma lembrança...

┌──────────────────────────────────────────────┐
│ O que ficou passando pela minha cabeça...    │
│                                              │
└──────────────────────────────────────────────┘
```

Não utilizar apenas `placeholder` para as dicas.

O placeholder desaparece assim que o usuário começa a escrever.

A dica deve permanecer visível durante todo o preenchimento.

Pode usar:

```html
<small class="...">
```

ou componente visual equivalente já utilizado no sistema.

---

# 33. Tom dos textos

O módulo deve falar de maneira:

- humana;
- acolhedora;
- simples;
- não clínica;
- não infantil;
- sem julgamento.

Evitar textos como:

> Avalie sua condição psicológica.

Preferir:

> Como estou hoje?

Evitar:

> Descreva fatores desencadeadores.

Preferir:

> O que aconteceu que mais mexeu comigo?

---

# 34. Página principal de Autoconhecimento

Ao acessar `/progresso/autoconhecimento`, mostrar algo semelhante a:

```text
🪞 Autoconhecimento

Um espaço para registrar o presente,
entender sua semana e perceber mudanças ao longo do tempo.

[ 📝 Diário ]
Registre como foi seu dia.
Hoje: ainda não preenchido

[ 🔎 Revisão Semanal ]
Olhe para os padrões da sua semana.
Semana atual: ainda não preenchida

[ 📊 Minha Evolução ]
Veja como humor, energia e tensão vêm mudando.
```

Se o Diário de hoje já existir:

```text
Hoje: ✓ registrado
[Ver / editar]
```

Se a Revisão Semanal existir:

```text
Semana atual: ✓ revisada
[Ver revisão]
```

---

# 35. Fluxo principal

```text
                    🪞 AUTOCONHECIMENTO
                            │
          ┌─────────────────┼─────────────────┐
          │                 │                 │
          ▼                 ▼                 ▼
      📝 DIÁRIO       🔎 REVISÃO        📊 EVOLUÇÃO
          │              SEMANAL              │
          │                 │                 │
          ▼                 ▼                 ▼
   Como estou hoje?   Resumo dos dias     Indicadores
          │                 │                 │
          ▼                 ▼                 ├─ Humor
    O que aconteceu?   O que se repetiu?      ├─ Energia
          │                 │                 ├─ Tensão
          ▼                 ▼                 ├─ Necessidades
     O que senti?      O que aprendi?          └─ Próximos passos
          │                 │
          ▼                 ▼
   Do que precisei?    O que quero mudar?
          │                 │
          ▼                 ▼
  Pergunta rotativa    Próximo pequeno passo
          │
          ▼
        Salvar
```

---

# 36. Relação entre as três áreas

O comportamento mais importante do novo módulo é:

```text
DIÁRIO
produz dados
      ↓
REVISÃO SEMANAL
ajuda o usuário a interpretar os dados
      ↓
MINHA EVOLUÇÃO
permite enxergar mudanças ao longo do tempo
```

Não duplicar perguntas entre Diário e Revisão Semanal sem necessidade.

---

# 37. Integração com o dashboard Progresso

O dashboard `ProgressController` atualmente utiliza:

- `WeeklyHealthReview`
- `WeeklyWellbeing`

Atualizar os cards/partials correspondentes.

No lugar de:

```text
Progresso além da balança
Perguntas da semana
```

mostrar um bloco único:

## 🪞 Autoconhecimento

Exemplo:

```text
Esta semana

Humor médio: 3,4
Energia média: 3,6
Tensão média: 3,9

Diários: 4 de 7 dias
Revisão semanal: Ainda não realizada

[Registrar hoje]
[Revisar semana]
```

Não penalizar visualmente dias sem Diário.

`4 de 7` é apenas informação, não progresso obrigatório.

---

# 38. Compatibilidade visual

Reutilizar:

- `app-page`
- `app-page__hero`
- `app-panel`
- `app-form-control`
- `app-form-select`
- `app-btn`
- padrões de filtros;
- paginação;
- cards;
- Material Symbols;
- estilo responsivo existente.

Não introduzir framework visual novo.

Manter coerência com as demais páginas de Saúde e Bem-Estar.

---

# 39. Responsividade

Em mobile:

- métricas 1–5 devem continuar fáceis de tocar;
- chips de necessidades devem quebrar linha;
- perguntas devem ocupar 100% da largura;
- gráficos devem permitir leitura sem scroll horizontal sempre que possível;
- navegação Diário / Revisão / Evolução deve permanecer clara.

---

# 40. Validações

## Diário

- usuário obrigatório;
- data obrigatória;
- único por usuário/data;
- métricas opcionais, mas se preenchidas devem estar entre 1 e 5;
- texto máximo 2.000 caracteres;
- pelo menos algum conteúdo deve existir.

## Semanal

- usuário obrigatório;
- `week_start` obrigatório;
- `week_start` deve ser segunda-feira;
- único por usuário/semana;
- `routine_satisfaction`: opcional ou 1..5;
- texto máximo 2.000 caracteres;
- permitir revisão parcial.

---

# 41. Testes

Criar/ajustar testes para:

### Models

- unicidade Diário/data;
- unicidade Revisão/semana;
- escalas 1..5;
- semana começando segunda-feira;
- registros parciais;
- limites de caracteres.

### Requests/controllers

- criar Diário;
- editar Diário existente;
- impedir duplicação;
- criar Revisão Semanal;
- editar;
- excluir;
- filtrar histórico;
- acesso restrito aos registros do `current_user`.

### Migração

Garantir que:

- conteúdo antigo não seja perdido;
- registros semanais continuem associados à semana correta;
- registros diários mantenham a data original;
- WeeklyWellbeing histórico continue acessível.

---

# 42. Prioridade de implementação

Executar nesta ordem:

### Etapa 1
Estrutura de dados e migração.

### Etapa 2
Diário.

### Etapa 3
Revisão Semanal.

### Etapa 4
Página inicial de Autoconhecimento.

### Etapa 5
Minha Evolução.

### Etapa 6
Integração no dashboard Progresso.

### Etapa 7
Remover rotas, menus, controllers e views antigos somente depois de confirmar que os dados foram migrados e as novas telas funcionam.

---

# 43. Regra de segurança da refatoração

**Não apagar `weekly_health_reviews` ou `weekly_wellbeings` antes de migrar e validar os dados existentes.**

A implementação deve preservar o histórico.

Se houver dúvida entre:

- fazer uma migração destrutiva;
- manter temporariamente uma estrutura antiga;

preferir a segunda opção.

---

# 44. Resultado final esperado

O usuário não deve mais enxergar:

```text
Além da Balança
Perguntas
```

como funcionalidades separadas.

Ele deve perceber um fluxo único:

```text
🪞 Autoconhecimento

📝 Diário
“O que aconteceu comigo hoje?”

🔎 Revisão Semanal
“O que esta semana está me mostrando sobre mim?”

📊 Minha Evolução
“O que vem mudando ao longo do tempo?”
```

O Diário deve incentivar expressão.

A Revisão Semanal deve incentivar compreensão.

A Evolução deve facilitar percepção de padrões.

As **dicas das perguntas são parte essencial da funcionalidade e não devem ser removidas, resumidas ou substituídas apenas por placeholders.**
