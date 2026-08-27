# Contraste dos modais de exclusão

## Objetivo

Corrigir textos brancos sobre fundos claros nos fluxos de exclusão, mantendo contraste adequado em todos os temas.

## Escopo

- modal base carregado pelo Turbo Frame `modal`;
- tela modal de opções para excluir despesa parcelada;
- modal de confirmação final usado pelas ações destrutivas.

As regras de exclusão permanecem inalteradas.

## Solução

Substituir cores brancas fixas e herança indefinida por tokens semânticos do tema:

- títulos e texto principal usam `var(--text-main)`;
- mensagens secundárias usam `var(--text-soft)`;
- botões destrutivos mantêm texto branco sobre fundo vermelho;
- botão de cancelamento mantém contraste definido pelo componente existente.

O contêiner `#app-modal-body` deve definir cor principal explicitamente, evitando herança de regras globais. O modal de confirmação deve aplicar tokens diretamente ao título e à mensagem.

## Modal de exclusão parcelada

O modal deve seguir componentes e hierarquia visual do sistema:

- cabeçalho com ícone de alerta, título, identificação da parcela e grupo em badge;
- texto curto explicando que usuário deve escolher alcance da exclusão;
- duas opções apresentadas como cartões com ícone, título, descrição e ação;
- opção `Somente esta parcela` informa que parcelas seguintes serão preservadas;
- opção `Esta e próximas` informa que sequência a partir da parcela atual será excluída;
- rodapé com ação `Cancelar`;
- cartões lado a lado no desktop e empilhados em telas menores.

Botões das opções usam componentes `app-btn` e executam exclusão diretamente. Seus atributos `turbo_confirm` devem ser removidos, pois próprio modal já representa confirmação consciente do alcance. Exclusões iniciadas fora desse fluxo continuam usando modal de confirmação padrão.

## Temas

No tema claro, tokens produzem texto escuro sobre superfície branca. No tema noturno, tokens já fornecem texto claro sobre superfície escura. Não serão usados valores pretos fixos nem alteração do fundo do modal.

## Verificação

Revisar seletores e cascata CSS para confirmar que regras com `!important` não preservam texto branco no tema claro. Testes e comandos automatizados somente serão executados se solicitados pelo usuário, conforme regras do projeto.
