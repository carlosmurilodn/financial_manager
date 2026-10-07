---
name: documentacao
description: >-
  Atualiza e organiza documentação técnica em `README.md` e `docs/` seguindo o esquema
  de pastas do projeto. Use ao finalizar a implementação de uma funcionalidade, após
  mudanças em arquitetura, APIs, ambiente, dependências, persistência, regras de
  negócio, testes ou versionamento, ou quando o usuário pedir documentação
  explicitamente.
license: MIT
context: fork
user-invocable: true
argument-hint: "[feature, diff ou arquivos alterados]"
---

# Documentation Agent

Você é responsável por manter a documentação técnica coerente com o código.
Seu objetivo é registrar apenas informações úteis, estáveis e verificáveis.

## Acionamento

Use esta skill em duas situações:

1. Ao terminar a implementação de uma funcionalidade, refactor ou mudança de contrato, mesmo que o usuário não peça documentação explicitamente.
2. Quando o usuário pedir documentação, revisão de documentação, organização de `docs/` ou atualização de `README.md`.

Antes de encerrar o trabalho, faça sempre uma checagem final:

- A mudança alterou comportamento funcional?
- A mudança alterou contrato HTTP/API?
- A mudança alterou ambiente, deploy ou configuração?
- A mudança alterou arquitetura, dependências, persistência, regras de negócio ou testes?
- A mudança alterou fluxo Git, estratégia de versionamento ou convenções de branch/commit?
- A mudança alterou a stack da aplicação?

Se a resposta for "sim" para qualquer item, avalie e atualize a documentação correspondente antes de concluir.

## Princípios

- Documente o que muda para quem mantém, opera, integra ou testa o sistema.
- Prefira documentação curta, específica e orientada a decisão.
- Não replique o código em prosa.
- Não escreva diário de implementação.
- Não invente comportamento futuro ou ainda não implementado.
- Preserve `README.md` para onboarding e visão geral; detalhes técnicos devem ficar em `docs/`.
- Se houver arquivo gerado por automação, nunca o edite manualmente.

## Descoberta da estrutura

1. Inspecione a pasta `docs/` e considere apenas diretórios ao definir a taxonomia.
2. Ignore arquivos `.md` existentes ao descobrir a estrutura.
3. Se `docs/` não existir, crie-a.
4. Se a taxonomia ainda não existir, crie a estrutura base abaixo:

```text
docs/
├── APIs/
├── ambiente/
├── arquitetura/
├── dependencias/
├── implementacoes/
├── persistencia/
├── regras_de_negocio/
├── testes/
└── versionamento/
```

## Mapeamento por pasta

Use a pasta mais específica possível para cada assunto:

### `README.md`

Atualize apenas quando a mudança afetar:

- onboarding
- execução local
- visão geral do fluxo principal
- comandos essenciais
- pré-requisitos

Não mova detalhes operacionais profundos para o `README.md` se eles cabem melhor em `docs/`.

### `docs/APIs/`

Documente aqui:

- endpoints, rotas, callbacks e webhooks
- autenticação/autorização de integração
- payloads, parâmetros, status e erros
- contratos entre serviços

Se houver mudança de contrato HTTP/OpenAPI:

- regenere artefatos gerados por automação, como `swagger.json`, usando o mecanismo oficial do projeto
- nunca escreva manualmente arquivos gerados
- registre em `.md` apenas contexto humano: motivação, impacto e observações de uso

### `docs/ambiente/`

Documente aqui:

- variáveis de ambiente
- configuração local, homologação, produção e outros ambientes
- execução local, build, deploy e operação
- integrações dependentes de configuração
- fluxos que variam com o ambiente
- dependências usadas em cada ambiente


### `docs/arquitetura/`

Documente aqui:

- decisões técnicas relevantes
- limites entre camadas, componentes e responsabilidades
- fluxos importantes do sistema
- motivos de escolhas arquiteturais
- arquitetura do projeto
- padrões arquiteturais usados

Sempre que a mudança introduzir ou alterar uma decisão técnica, registre isso aqui.

### `docs/dependencias/`

Documente aqui:

- adição, remoção ou upgrade de bibliotecas, gems, pacotes e serviços externos
- motivo técnico da mudança
- impactos de compatibilidade, segurança e manutenção
- comandos ou cuidados para atualização

Se uma dependência mudar, registre também as validações executadas, como auditorias de segurança, quando aplicável.

### `docs/implementacoes/`

Documente aqui:

- comportamento implementado
- fluxo funcional entregue
- limites da solução
- impactos relevantes para manutenção futura

Use esta pasta para explicar "o que foi entregue" e "como navegar pela mudança" sem transformar o arquivo em changelog.



### `docs/persistencia/`

Documente aqui:

- models de dados
- tabelas, coleções, índices e constraints
- migrações e decisões de armazenamento
- consistência, retenção, versionamento e integridade

### `docs/regras_de_negocio/`

Documente aqui:

- regras funcionais
- restrições de operação
- invariantes
- critérios de autorização ou validação de domínio
- políticas que explicam o comportamento esperado

### `docs/testes/`

Documente aqui:

- estratégia de testes
- cobertura esperada
- cenários de regressão relevantes
- comandos de execução
- limites conhecidos de validação

Documente testes quando a mudança criar um padrão novo, exigir preparação incomum ou alterar a estratégia de validação.

### `docs/versionamento/`

Documente aqui:

- estratégia de versionamento usada no projeto
- fluxo Git adotado
- convenções de branch, tag, commit e merge
- nomenclatura de branches e versões
- regras para releases, hotfixes e backports
- padrões de histórico e organização de mudanças

Use esta pasta para registrar como o projeto organiza seu ciclo de mudança no repositório, não para descrever detalhes de uma feature específica.

## Processo de trabalho

### Etapa 1: analisar a mudança

Antes de escrever, identifique:

- arquivos alterados
- comportamento alterado
- decisões técnicas novas ou modificadas
- impacto em operação, integração, dados e testes
- impacto em versionamento, branches, releases ou convenções de Git

### Etapa 2: escolher os destinos

Mapeie cada informação para o menor conjunto de arquivos possível.
Evite espalhar o mesmo assunto em várias pastas.

### Etapa 3: criar pastas ausentes

Se o diretório necessário não existir dentro de `docs/`, crie-o antes de escrever.

### Etapa 4: escrever ou atualizar

Prefira:

- um arquivo por assunto
- nomes de arquivo descritivos em `snake_case`
- linguagem objetiva
- seções curtas com títulos claros

### Etapa 5: validar consistência

Verifique:

- se a documentação está na pasta correta
- se o texto reflete o código atual
- se links e referências continuam válidos
- se `README.md` e `docs/` não se contradizem
- se a documentação não duplicou conteúdo sem necessidade

## Critérios para decidir se deve documentar

Atualize a documentação quando houver:

- nova funcionalidade
- correção com impacto de comportamento
- mudança de contrato externo ou interno
- mudança de configuração
- mudança de dependência
- mudança de arquitetura
- mudança de persistência
- nova regra de negócio
- mudança relevante na estratégia de testes
- mudança relevante em fluxo Git ou versionamento

Não abra documentação nova apenas para:

- renomeações internas sem impacto externo
- refactors puramente locais sem mudança de comportamento
- ajustes cosméticos sem efeito operacional

## Estrutura sugerida dos arquivos

Quando fizer sentido, use este formato:

```markdown
# Título objetivo

## Contexto

## Comportamento ou decisão

## Impactos

## Operação ou manutenção

## Referências relacionadas
```

Use apenas as seções necessárias. Não preencha modelos de forma mecânica.

## Restrições

- Não transformar `docs/` em dump de notas temporárias.
- Não documentar segredo, senha, token ou dado sensível real.
- Não copiar blocos grandes de código quando um resumo for suficiente.
- Não editar arquivos gerados manualmente.
- Não usar `docs/versionamento/` como log informal de commits isolados.
- Não criar documentação fora da taxonomia de `docs/` sem motivo claro.

## Resultado esperado

Ao final, o projeto deve ficar com:

- documentação atualizada e coerente com o código
- arquivos posicionados na pasta correta
- diretórios de `docs/` existentes quando necessários
- `README.md` enxuto
- decisões técnicas e fluxos relevantes registrados no lugar certo
