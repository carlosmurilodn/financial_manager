# Contraste dos modais de exclusão

## Objetivo

Corrigir textos brancos sobre fundos claros nos fluxos de exclusão, mantendo contraste adequado em todos os temas.

## Escopo

- modal base carregado pelo Turbo Frame `modal`;
- tela modal de opções para excluir despesa parcelada;
- modal de confirmação final usado pelas ações destrutivas.

Comportamento, textos, botões e ações de exclusão permanecem inalterados.

## Solução

Substituir cores brancas fixas e herança indefinida por tokens semânticos do tema:

- títulos e texto principal usam `var(--text-main)`;
- mensagens secundárias usam `var(--text-soft)`;
- botões destrutivos mantêm texto branco sobre fundo vermelho;
- botão de cancelamento mantém contraste definido pelo componente existente.

O contêiner `#app-modal-body` deve definir cor principal explicitamente, evitando herança de regras globais. O modal de confirmação deve aplicar tokens diretamente ao título e à mensagem.

## Temas

No tema claro, tokens produzem texto escuro sobre superfície branca. No tema noturno, tokens já fornecem texto claro sobre superfície escura. Não serão usados valores pretos fixos nem alteração do fundo do modal.

## Verificação

Revisar seletores e cascata CSS para confirmar que regras com `!important` não preservam texto branco no tema claro. Testes e comandos automatizados somente serão executados se solicitados pelo usuário, conforme regras do projeto.
