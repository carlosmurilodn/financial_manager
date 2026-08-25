# Criação de despesa no contexto do cartão

## Objetivo

Permitir criar despesas diretamente no show de um cartão, reutilizando o modal existente e vinculando todas as despesas criadas ao cartão aberto.

## Entrada

O cabeçalho da fatura recebe botão `Nova despesa`. O link abre `ExpensesController#new` no frame modal e envia:

- `card_id`: cartão aberto;
- `month` e `year`: período exibido na fatura.

O backend localiza o cartão somente dentro de `current_user.cards`. Parâmetros inválidos ou cartões de outro usuário não ativam contexto fixo.

## Modal

O formulário atual de criação múltipla será reutilizado.

Quando aberto pelo show do cartão:

- cartão aparece identificado e não pode ser trocado;
- cada linha envia `card_id` em campo oculto;
- forma de pagamento começa em `Crédito à vista`;
- forma de pagamento permite somente `Crédito à vista` e `Crédito parcelado`;
- data da despesa começa com `Date.current`, mas permanece editável;
- mês de balanço começa no mês exibido na fatura, mas permanece editável;
- linhas adicionadas pelo botão `Inserir Despesa` recebem os mesmos padrões;
- em reexibição por erro, valores informados pelo usuário são preservados, mantendo cartão fixo.

No modal aberto fora do cartão, comportamento atual não muda.

## Segurança e consistência

O contexto do cartão é reenviado no submit e revalidado no backend. Durante criação, `card_id` de cada linha será sobrescrito pelo cartão validado do contexto. Assim, alteração manual do HTML não permite vincular despesa a outro cartão.

O backend aceita apenas as duas formas de crédito no contexto fixo. Requisição adulterada com outra forma será normalizada para `Crédito à vista` ou rejeitada de forma controlada, conforme padrão atual de validação do formulário. A implementação adotará normalização para manter fluxo previsível.

## Sucesso e erros

Após criação bem-sucedida, a resposta Turbo fecha o modal e recarrega a URL atual do show. No fallback HTML, o backend reconstrói a URL do cartão com o período validado. Assim:

1. modal fecha;
2. navegador visita show do cartão;
3. `month` e `year` da fatura são preservados;
4. nova despesa aparece nos totais e tabela correspondentes ao mês de balanço escolhido quando ele coincide com filtro aberto.

Se usuário editar mês de balanço para outro período, retorno continua no período originalmente aberto; despesa estará disponível no período escolhido por ela.

Em erro, modal permanece aberto com mensagens, valores e contexto do cartão.

## Escopo técnico

- Show e estilos do cartão para novo botão.
- Inicialização contextual em `ExpensesController`.
- Partials do formulário e linhas dinâmicas.
- JavaScript do formulário apenas onde necessário para herança dos padrões.
- Resposta Turbo/redirect contextual após criação.
- Sem migration, nova rota ou alteração de cálculos financeiros.

## Validação

Testes automatizados somente serão escritos ou executados mediante solicitação do usuário, conforme regra do projeto. Validação estática deve cobrir sintaxe, parâmetros permitidos, propriedade do cartão, preservação do retorno e funcionamento do template de novas linhas.
