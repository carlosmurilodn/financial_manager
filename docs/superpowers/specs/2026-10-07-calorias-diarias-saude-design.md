# Perfil de Saúde e cálculo diário de calorias

## Estado e objetivo

Especificação aprovada durante definição do fluxo. A funcionalidade descrita ainda será implementada.

Adicionar acompanhamento de calorias à área de Saúde e Bem-Estar do Gerenciador Pessoal. O usuário informa o consumo diário; o sistema estima gasto total e déficit usando perfil, pesagens e marcações diárias das metas semanais.

Os resultados são estimativas para acompanhamento, sem prescrição alimentar ou promessa de perda de peso. Os fatores abaixo são regras escolhidas para este produto, não medições do gasto real de cada exercício.

## Perfil de Saúde

Criar um perfil de Saúde por usuário, separado das informações financeiras e vinculado à mesma conta autenticada.

Campos:

- altura, em centímetros;
- data de nascimento;
- opção da fórmula: masculino ou feminino.

A idade corresponde aos anos completos na data do registro diário, inclusive para registros passados e futuros.

O menu de Saúde e Bem-Estar terá um item **Perfil de Saúde**, próximo ao final. O bloco de calorias mostrará **Configurar perfil** enquanto faltarem informações necessárias ao cálculo.

Validar altura positiva, data de nascimento válida e não futura, e opção pertencente aos dois valores aceitos. Não calcular registros anteriores ao nascimento.

## Localização e interação

Adicionar o bloco **Calorias da semana** abaixo das metas na tela de Metas que Dependem de Você. O bloco acompanha a semana de segunda-feira a domingo de cada plano exibido.

Cada dia permite informar e editar as calorias consumidas pela alimentação, em kcal. A marcação de alimentação planejada continua independente desse valor.

Apresentar por dia:

- data;
- calorias consumidas;
- peso usado e data da pesagem;
- atividades identificadas e fator aplicado;
- gasto basal estimado (BMR);
- gasto total estimado (TDEE);
- déficit, equilíbrio ou superávit estimado;
- indicação de cálculo pendente ou de estimativa futura, quando aplicável.

Usar classes próprias de Saúde e layout `display: flex`, com quebra e organização mobile. Não reutilizar classes dos cards financeiros.

A persistência é independente de cada meta: um único registro por usuário e data. Excluir uma meta ou plano semanal não exclui o consumo já registrado.

## Consumo e datas

- Consumo é informado manualmente, sem cadastro de alimentos ou refeições.
- Valor ausente significa **Sem registro**, nunca zero assumido.
- Zero informado explicitamente é diferente de ausência de informação.
- Aceitar valores não negativos, incluindo zero; apresentação em kcal.
- Permitir datas passadas, atuais e futuras.
- Identificar resultados de datas futuras como **Estimativa futura**.
- Permitir salvar consumo mesmo sem perfil completo ou pesagem disponível.
- Ausência de consumo impede calcular déficit, mesmo que gasto estimado esteja disponível.

## Peso de referência

Para a data D:

1. Usar a pesagem do próprio dia, se existir.
2. Caso contrário, usar a última pesagem anterior a D.
3. Mostrar a data da medição usada, inclusive quando for anterior.
4. Não usar pesagem posterior a D para preencher dias passados.
5. Sem pesagem elegível, manter consumo salvo e cálculo pendente.

Para datas futuras, usar a última pesagem disponível até aquela data, conforme os registros que o sistema efetivamente possui. A funcionalidade não exige permitir pesagens futuras.

## Identificação das atividades

Usar exclusivamente metas do usuário e da semana correspondente à data calculada, com marcação diária concluída naquela data.

Reconhecer palavras completas no nome da meta, ignorando maiúsculas e minúsculas:

- treino: **Treinar** ou **Treino**;
- caminhada: **Caminhar** ou **Caminhada**.

Nomes podem conter outros termos, como “Treinar musculação” ou “Caminhada no parque”. Não reconhecer fragmentos dentro de palavras diferentes. Não acrescentar sinônimos automaticamente.

Se houver várias metas reconhecidas do mesmo tipo, basta uma concluída no dia para considerar a atividade realizada. Duplicatas não multiplicam gasto nem fator.

Uma meta cujo nome contenha palavras dos dois tipos participa das duas verificações. Sua conclusão identifica ambas as atividades.

Metas não reconhecidas não afetam o cálculo. Metas sem marcação concluída, planos inexistentes ou ainda não salvos não indicam atividade realizada.

## Fator de atividade

| Treino concluído | Caminhada concluída | Classificação | Fator |
| --- | --- | --- | --- |
| Não | Não | Sedentário | 1,2 |
| Não | Sim | Levemente ativo | 1,375 |
| Sim | Não | Moderadamente ativo | 1,55 |
| Sim | Sim | Muito ativo | 1,725 |

O fator é automático; não existe seleção manual nesta etapa. Metas quantitativas semanais e percentual de conclusão não determinam o fator: a fonte são as marcações da data.

## Fórmulas e apresentação

Aplicar Mifflin-St Jeor conforme opção do perfil:

```text
Masculino: BMR = 10 × peso_kg + 6,25 × altura_cm − 5 × idade + 5
Feminino:  BMR = 10 × peso_kg + 6,25 × altura_cm − 5 × idade − 161

TDEE = BMR × fator_de_atividade
Déficit = TDEE − calorias_consumidas
```

- Resultado positivo: déficit estimado.
- Resultado zero: equilíbrio estimado.
- Resultado negativo: superávit estimado, apresentado com magnitude positiva e rótulo próprio.
- Não somar gasto de exercício separado: a atividade já entra pelo fator de TDEE.
- Usar precisão decimal na persistência e no cálculo, arredondando apenas para apresentação em kcal inteiras.
- Se a combinação de entradas produzir BMR não positivo, mostrar cálculo pendente por dados incompatíveis, sem persistir gasto ou déficit como resultados válidos.

O bloco poderá apresentar resumo semanal de consumo e déficit dos dias calculados, sempre indicando a quantidade de dias incluídos. Não interpretar dias ausentes como zero nem apresentar semana incompleta como total de sete dias.

## Persistência proposta

### Perfil

Entidade própria associada ao usuário, com unicidade por usuário e os campos descritos acima.

### Registro diário

Entidade própria associada ao usuário, com unicidade por usuário e data. Persistir:

- data e calorias consumidas, permitindo ausência explícita;
- peso usado e data da pesagem de referência;
- altura, nascimento, idade calculada e opção da fórmula utilizados;
- indicadores de treino e caminhada realizados;
- fator aplicado;
- BMR, TDEE e déficit calculados, permitindo resultados ausentes quando pendentes;
- situação do cálculo e data/hora da última atualização.

Os dados usados permitem entender a última versão do cálculo. Não haverá histórico imutável de revisões nesta etapa: recálculos atualizam o registro existente.

Restringir leituras e alterações ao usuário autenticado. Incluir chaves estrangeiras, índices de unicidade e constraints pertinentes. Seguir padrão existente de habilitação de RLS nas tabelas de Saúde.

## Recálculo e consistência

Recalcular automaticamente os registros diários existentes afetados por:

- criação ou edição do consumo diário;
- marcação ou desmarcação de treino/caminhada;
- criação, renomeação ou exclusão de metas reconhecidas;
- alteração da semana ou exclusão de um plano semanal;
- criação, correção, mudança de data ou exclusão de pesagem;
- alterações de altura, nascimento ou opção da fórmula no perfil.

Escopo:

- Marcações: recalcular o dia alterado.
- Alterações de metas: recalcular a semana afetada; se o plano mudar de semana, considerar semana anterior e nova.
- Pesagens: recalcular dias cujo peso de referência possa mudar, considerando data anterior e nova quando uma medição for movida.
- Perfil: recalcular todos os registros do usuário, incluindo passados e futuros.

Ao perder dados necessários, limpar resultados antigos e mostrar pendência. Preservar calorias informadas. Quando os dados forem completados, recalcular os registros pendentes elegíveis.

Centralizar fórmula, resolução de peso e identificação de atividades em serviços de Saúde reutilizáveis. Coordenar alterações e recálculos com transações para não deixar resultados antigos após uma operação concluída. Não duplicar fórmula em controllers ou JavaScript.

## Fora do escopo

- Cadastro de alimentos, refeições, macros ou receitas.
- Gasto específico por modalidade, duração ou dispositivo.
- Seleção manual de fator de atividade.
- Metas de ingestão ou recomendações de déficit.
- Estimativa de perda de peso a partir do déficit.
- Auditoria imutável de versões anteriores dos cálculos.
- Alterações em regras ou registros financeiros.

## Critérios de aceite e validação prevista

- Perfil acessível pelo menu de Saúde e pelo convite de configuração no bloco de calorias.
- Consumo salvo uma única vez por usuário/data, com edição e ausência distinguida de zero.
- Sete dias da semana apresentados com layout flex adaptado a desktop e mobile.
- Peso da data ou última pesagem anterior corretamente identificado.
- Quatro combinações de atividade aplicam os fatores acordados.
- Nomes reconhecidos com palavras completas, sem diferenciar maiúsculas/minúsculas.
- Fórmulas masculina e feminina usam idade na data do registro.
- Datas futuras aceitas e identificadas como estimativas.
- Registros incompletos preservam consumo e mostram pendências.
- Alterações de perfil, pesagens e metas atualizam registros afetados, inclusive histórico.
- Exclusão de metas/planos não apaga registros de calorias.
- Dados de um usuário não são consultados ou alterados por outro.
- Resumo semanal informa cobertura dos dias registrados/calculados.

Validação manual e compilação dos assets serão previstas na implementação. Testes automatizados serão criados e executados somente mediante solicitação explícita do usuário, conforme `AGENTS.md`.

## Referências do projeto

- [Painel de progresso de Saúde](2026-10-05-painel-progresso-saude-design.md).
- [Separação entre Financeiro e Saúde e Bem-Estar](2026-10-06-separacao-financeiro-saude-design.md).
