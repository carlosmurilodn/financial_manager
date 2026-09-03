# Plano de implementação: status visual das movimentações

## Objetivo

Mostrar no card **Movimentações do Período** se cada receita foi recebida e se cada despesa foi paga, mantendo `+` e `-` como indicadores do tipo da movimentação.

## Arquivos envolvidos

- `app/queries/home/dashboard_query.rb`
- `app/views/home/_movimentacoes_periodo.html.erb`
- `app/assets/stylesheets/dashboard/_cards_categories_movements.scss`
- `test/controllers/home_controller_test.rb`

## Etapas

### 1. Disponibilizar status das despesas

- Incluir `:paid` no `select` explícito de `Home::DashboardQuery#recent_expenses`.
- Manter ordenação, intervalo e eager loading atuais.
- Não alterar consulta de receitas, pois ela já carrega todos os atributos.

### 2. Adicionar semântica de status ao item

- Derivar de `record.paid?` uma classe `dashboard-movement-item--paid` ou `dashboard-movement-item--pending`.
- Preservar classes de tipo `--income` e `--expense` para semântica estrutural, sem usá-las para cor do valor.
- Renderizar badge após conteúdo principal e antes do valor:
  - receita concluída: `check` + `Recebido`;
  - despesa concluída: `check` + `Pago`;
  - qualquer movimentação aberta: `schedule` + `Pendente`.
- Manter link, data, descrição, categoria, cor da categoria e sinais dos valores.

### 3. Aplicar apresentação visual

- Expandir grid do item para acomodar badge e valor.
- Adicionar faixa lateral de status com pseudo-elemento ou borda interna, sem alterar cor da categoria.
- Usar tokens de sucesso para concluído e perigo para pendente.
- Tornar valor neutro para ambos os tipos.
- Estilizar badge com ícone, texto, contraste e espaçamento consistentes.
- Ajustar breakpoint móvel para evitar colisões; quando necessário, reduzir badge mantendo ícone e texto acessível.
- Confirmar compatibilidade com temas claro e noturno usando tokens existentes.

### 4. Validar comportamento

- Cobrir receita recebida e pendente.
- Cobrir despesa paga e pendente.
- Confirmar presença dos sinais `+` e `-` e textos corretos.
- Confirmar que consulta restrita de despesas entrega `paid`.
- Adicionar os cenários ao teste de integração do `HomeController`, que já valida o HTML renderizado pelo dashboard.
- Fazer inspeção visual nos temas claro/noturno e layout móvel.

Testes automatizados e validação visual só serão executados mediante solicitação explícita do usuário, conforme regra do projeto.

## Limites

- Nenhuma alteração de banco de dados.
- Nenhuma ação para alternar status dentro do dashboard.
- Nenhum filtro novo.
- Nenhuma mudança nos cálculos financeiros.
