module Health
  module SelfKnowledgeContent
    NEEDS = %w[Descanso Apoio Espaço Segurança Diversão Conexão Reconhecimento Organização Silêncio Autonomia Movimento Companhia].freeze + ["Tempo sozinho", "Outro"]
    METRICS = { mood: ["Humor", "Pense no tom emocional geral do seu dia, não apenas no que está sentindo neste exato momento.", ["Muito baixo", "Baixo", "Intermediário", "Bom", "Muito bom"]], energy: ["Energia", "Considere disposição física e mental para fazer as coisas, e não apenas cansaço corporal.", ["Muito baixa", "Baixa", "Intermediária", "Boa", "Muito boa"]], tension: ["Tensão / Ansiedade", "Pense em preocupação, inquietação, tensão corporal, sensação de alerta ou dificuldade de desligar a cabeça. Quanto maior o número, maior a tensão.", ["Muito baixa", "Baixa", "Moderada", "Alta", "Muito alta"]] }.freeze
    DAILY = {
      main_thought: ["O que mais ocupou minha cabeça hoje?", "Pode ser uma preocupação, uma conversa, algo que aconteceu, uma decisão, uma lembrança, algo que você está esperando ou até uma coisa boa que ficou voltando à sua mente.", "O que ficou passando pela minha cabeça hoje..."],
      meaningful_event: ["O que aconteceu que mais mexeu comigo?", "Pense em algum acontecimento que mudou seu humor ou chamou sua atenção. Pode ter sido algo grande ou aparentemente pequeno: uma conversa, uma notícia, um problema, uma conquista ou um momento específico do dia.", "Hoje aconteceu..."],
      emotions: ["O que eu senti diante disso?", "Tente ir além de “bem” ou “mal”. Houve ansiedade, irritação, tristeza, alívio, culpa, vergonha, alegria, orgulho, frustração, esperança, medo ou outra emoção? Você pode registrar mais de uma.", "Percebi que estava me sentindo..."],
      positive_moment: ["Teve algo bom que eu quero guardar deste dia?", "Pode ser uma conquista, algo que funcionou, um momento agradável, uma conversa, alguma coisa que você fez por si mesmo ou simplesmente um pequeno instante que vale lembrar.", "Uma coisa boa de hoje foi..."]
    }.freeze
    WEEKLY = {
      recurring_patterns: ["O que mais se repetiu nesta semana?", "Pense em situações, pensamentos, emoções, preocupações ou comportamentos que apareceram em vários dias. Existe algo que parece estar se tornando um padrão?"],
      what_helped: ["O que mais me fez bem?", "Pense em pessoas, lugares, atividades, hábitos ou momentos em que você se sentiu mais tranquilo, interessado, conectado, satisfeito ou com mais energia."],
      what_drained: ["O que mais drenou minha energia ou pesou em mim?", "Houve algum problema, conflito, cobrança, preocupação ou frustração que ocupou muito espaço? Alguma situação continuou na sua cabeça mesmo quando já não havia nada para resolver naquele momento?"],
      thought_patterns: ["Que padrão percebi nos meus pensamentos?", "Alguma frase apareceu várias vezes na sua cabeça? Por exemplo: “eu deveria...”, “vai dar errado...”, “eu nunca...”, “preciso resolver isso...”, “eu estraguei tudo...”. Tente perceber o padrão sem precisar decidir agora se ele está certo ou errado."],
      avoidance_and_control: ["O que eu evitei, adiei ou tentei controlar demais?", "Pense em tarefas, decisões, conversas, sentimentos ou situações que você evitou. Também observe se gastou muita energia tentando controlar alguma coisa que talvez não estivesse totalmente nas suas mãos."],
      self_discovery: ["O que percebi sobre mim nesta semana?", "Alguma reação sua chamou atenção? Você percebeu uma necessidade, limite, medo, desejo ou comportamento recorrente? Descobriu alguma coisa sobre como costuma reagir a determinadas situações?"],
      weekly_needs: ["Do que eu mais precisei nesta semana?", "Pense no que parece ter feito falta ou no que mais ajudou: descanso, apoio, espaço, conexão, segurança, autonomia, organização, diversão, silêncio ou outra necessidade."],
      control_reflection: ["O que estava sob meu controle e o que não estava?", "Existe alguma coisa concreta que você poderia fazer diferente? E existe algo pelo qual está se cobrando mesmo não dependendo realmente de você? Diferencie responsabilidade de tentativa de controlar o incontrolável."],
      proud_of: ["Do que eu me orgulho nesta semana?", "Não procure apenas grandes conquistas. Pode ser uma decisão, uma conversa difícil, ter colocado um limite, cuidado de si, cumprido algo pequeno ou simplesmente continuado apesar de uma semana complicada."],
      weekly_learning: ["O que aprendi sobre mim?", "Depois de olhar para a semana inteira, existe alguma conclusão que você gostaria de lembrar no futuro? Algo sobre seus limites, necessidades, pensamentos, relacionamentos, rotina ou maneira de lidar com problemas?"],
      keep_doing: ["O que quero continuar fazendo?", "Identifique algo que funcionou e merece continuar. Pode ser pequeno: uma rotina, atitude, comportamento, limite, hábito ou forma de pensar."],
      change_next_week: ["O que quero fazer diferente na próxima semana?", "Não tente consertar tudo de uma vez. Escolha uma mudança que pareça útil, possível e proporcional ao que você percebeu nesta revisão."],
      next_small_step: ["Qual é meu próximo pequeno passo?", "Transforme sua intenção em uma ação concreta e pequena. Em vez de “me organizar melhor”, prefira algo como “domingo à noite vou separar as três prioridades da semana”."]
    }.freeze
    ROTATING = {
      "reflection_1" => ["Você se cobrou por alguma coisa hoje?", "Pense se você exigiu de si algo que talvez não exigisse de outra pessoa na mesma situação."],
      "reflection_2" => ["Teve alguma coisa que você evitou hoje?", "Pode ser uma tarefa, decisão, conversa, sentimento ou situação que você foi adiando ou tentando não enfrentar."],
      "reflection_3" => ["Teve algum momento em que você se sentiu mais você mesmo?", "Pense em algum momento em que você se sentiu espontâneo, confortável ou conectado com quem você é."],
      "reflection_4" => ["O que eu gostaria que alguém tivesse entendido sobre mim hoje?", "Pense em algo que você sentiu, precisou ou tentou comunicar e que talvez tenha passado despercebido."],
      "reflection_5" => ["Alguma coisa foi melhor do que eu esperava?", "Pode ter sido algo que você antecipou negativamente e acabou sendo mais simples, tranquilo ou agradável."],
      "reflection_6" => ["O que eu gostaria de repetir amanhã?", "Pense em uma atitude, hábito, decisão ou momento de hoje que merece aparecer novamente."],
      "reflection_7" => ["Minha mente transformou algum problema pequeno em algo muito maior?", "Pense se alguma preocupação continuou ocupando sua cabeça mesmo depois de você já não ter nada concreto para fazer a respeito."],
      "reflection_8" => ["Eu fiz alguma coisa hoje mesmo sem estar com vontade?", "Pode ser algo pequeno. Às vezes agir apesar da falta de motivação também merece ser reconhecido."],
      "reflection_9" => ["Teve algo que eu queria controlar, mas não dependia de mim?", "Pense em comportamentos de outras pessoas, resultados, imprevistos ou situações sobre as quais você tinha pouca influência real."],
      "reflection_10" => ["Do que eu me orgulho hoje?", "Não precisa ser uma grande conquista. Pode ser ter tentado, colocado um limite, terminado algo, cuidado de si ou atravessado um dia difícil."]
    }.freeze
    STAGES = {
      "Minha semana" => %i[recurring_patterns what_helped what_drained],
      "Entendendo meus padrões" => %i[thought_patterns avoidance_and_control self_discovery weekly_needs control_reflection],
      "Levando algo comigo" => %i[proud_of weekly_learning keep_doing change_next_week next_small_step]
    }.freeze
  end
end
