module HealthDiaryContent
  METRICS = { energy: "Energia", mood: "Humor", routine_satisfaction: "Satisfação com a rotina", anxiety: "Ansiedade/tensão", overload: "Sobrecarga" }.freeze
  NEEDS = %w[Descanso Apoio Espaço Segurança Diversão Conexão Reconhecimento Organização Silêncio Autonomia Outro].freeze
  DAILY = {
    feelings: ["Como me senti na maior parte deste dia?", "Você esteve mais tranquilo, ansioso, irritado, animado, triste, cansado ou esperançoso? Alguma emoção apareceu várias vezes? Houve mudanças fortes ao longo do dia?"],
    worked_well: ["Quais momentos, pessoas ou coisas me fizeram bem hoje?", "Pense em momentos em que você se sentiu mais leve, tranquilo, interessado, conectado ou satisfeito. Pode ser algo grande ou uma coisa bem pequena. O que estava acontecendo? Com quem você estava? O que você estava fazendo?"],
    obstacles: ["O que mais me incomodou, preocupou ou drenou minha energia hoje?", "Houve algum problema que ficou voltando à sua cabeça? Alguma frustração, cobrança, conflito, medo ou preocupação? Algo pequeno acabou ocupando um espaço maior do que você gostaria?"],
    needs_response: ["Do que eu mais precisei hoje?", "Consegui atender essa necessidade? O que dificultou? Você pode selecionar necessidades abaixo e escrever sobre o que fez falta."],
    recognition: ["O que eu fiz bem ou gostaria de reconhecer em mim hoje?", "Pode ser uma decisão, um limite que colocou, algo que terminou, uma conversa, ter cuidado de si, ter enfrentado algo difícil ou simplesmente ter continuado num dia ruim."]
  }.freeze
  WEEKLY = {
    feelings: ["Como eu me senti na maior parte deste período?", "Você esteve mais tranquilo, ansioso, irritado, animado, triste, cansado, esperançoso? Alguma emoção apareceu várias vezes? Houve mudanças fortes ao longo do período?"],
    worked_well: ["Quais momentos, pessoas ou coisas me fizeram bem?", "Pense em momentos em que você se sentiu mais leve, tranquilo, interessado, conectado ou satisfeito. Pode ser algo grande ou uma coisa bem pequena. O que estava acontecendo? Com quem você estava? O que você estava fazendo?"],
    obstacles: ["O que mais me incomodou, preocupou ou drenou minha energia?", "Houve algum problema que ficou voltando à sua cabeça? Alguma frustração, cobrança, conflito, medo ou preocupação? Algo pequeno acabou ocupando um espaço muito maior do que você gostaria?"],
    thoughts: ["Que pensamentos apareceram com frequência?", "Houve alguma frase que sua cabeça repetiu? ‘Eu deveria...’, ‘eu nunca...’, ‘vai dar errado...’, ‘eu estraguei...’, ‘preciso resolver...’. Você acreditou totalmente nesses pensamentos ou consegue enxergá-los de outra forma agora?"],
    insights: ["O que percebi sobre mim neste período?", "Alguma reação sua te surpreendeu? Percebeu uma necessidade, limite, medo ou desejo? Notou algo que costuma se repetir? Descobriu alguma coisa sobre o que é importante para você?"],
    within_control: ["O que nessa situação dependia de mim — e o que não dependia?", "Há algo que você realmente poderia ter feito diferente? Está se cobrando por alguma coisa que não controlava? Existe alguma ação possível agora ou o problema já terminou e sua mente continua tentando resolvê-lo?"],
    needs_response: ["Do que eu mais precisei neste período?", "Consegui atender essa necessidade? O que dificultou? Selecione as necessidades que fizeram sentido e escreva sobre elas."],
    recognition: ["O que eu fiz bem ou gostaria de reconhecer em mim?", "Pode ser uma decisão, um limite que colocou, algo que terminou, uma conversa, ter cuidado de si, ter enfrentado algo difícil ou simplesmente ter continuado num dia ruim."],
    next_adjustments: ["Depois de olhar para tudo isso, o que quero fazer diferente ou continuar fazendo?", "Existe algo que vale repetir? Algo que você quer parar de alimentar? Uma conversa que precisa ter? Um problema concreto para resolver? Qual seria uma mudança pequena e realista?"]
  }.freeze
  THEMES = {
    feelings: "Como foi estar na minha própria cabeça?",
    worked_well: "O que me fez bem?",
    obstacles: "O que pesou em mim?",
    thoughts: "O que minha mente ficou me dizendo?",
    insights: "O que isso revela sobre mim?",
    within_control: "O que estava e não estava nas minhas mãos?",
    needs_response: "Do que eu precisava?",
    recognition: "Do que eu me orgulho?",
    next_adjustments: "O que quero levar comigo?"
  }.freeze
  SCENARIOS = {
    "Dia difícil" => "O que mais pesou? O que ajudou a atravessar o dia? Do que preciso agora?",
    "Conquista ou momento bom" => "O que aconteceu? O que quero reconhecer em mim? O que vale repetir?",
    "Rotina corrida" => "O que consumiu minha energia? Qual limite ou ajuda faria diferença?",
    "Desânimo" => "Houve algum momento de alívio? Qual passo parece possível?",
    "Mudança de hábito" => "O que facilitou? O que dificultou? Que ajuste pequeno quero experimentar?",
    "Conflito ou preocupação" => "O que ficou na minha cabeça? O que depende de mim agora?",
    "Reflexão livre" => "Escreva sobre o que importa neste momento, sem roteiro."
  }.freeze
end
