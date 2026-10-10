# Financial Manager

Aplicacao Rails para gerenciamento financeiro pessoal. O sistema organiza despesas,
receitas, cartoes, categorias, metas financeiras e relatorios, alem do acompanhamento
de saude fisica com alimentacao, calorias, pesagens e exercicios. Usa autenticacao
via Devise e interface server-rendered com Hotwire.

## Fontes

- Repositorio oficial: https://github.com/carlosmurilodn/financial_manager

## Stack

- Ruby on Rails 8.0.3
- PostgreSQL
- Devise
- Hotwire: Turbo e Stimulus
- Propshaft
- Bootstrap 5
- Chart.js
- Solid Cache, Solid Queue e Solid Cable
- Active Storage com disco local em desenvolvimento e Supabase Storage em producao
- PDFKit com wkhtmltopdf
- Kamal, Docker e Thruster para deploy/container
- RSpec, Minitest, Capybara, RuboCop Omakase e Brakeman

## Funcionalidades

- Login, logout e sessoes de usuario com Devise
- Dashboard financeiro
- Cadastro, filtro, ordenacao e paginacao de despesas
- Cadastro, filtro, ordenacao e paginacao de receitas
- Marcacao de despesas e receitas como pagas
- Controle de despesas parceladas
- Cadastro e pagamento de cartoes
- Cadastro de categorias com icones e cores
- Cadastro e acompanhamento de metas financeiras
- Relatorios financeiros e previsao financeira
- Exportacao de relatorios em PDF
- Acompanhamento semanal da alimentacao com status diario da dieta e consumo de calorias
- Perfil de saude e registro de pesagens
- Registro de exercicios com detalhes do treino, grupos musculares, series e imagens
- Suporte a PWA via manifesto e service worker do Rails

### Alimentacao e exercicios

Em Alimentacao, abra uma semana e selecione o status de cada dia: dieta seguida
totalmente, parcialmente ou nao seguida. A opcao "Selecione" limpa o status.
A selecao salva automaticamente e atualiza o contador semanal, que considera
somente os dias com dieta totalmente seguida. O consumo de calorias tem seu proprio
botao Salvar. Falhas de validacao do status exibem uma mensagem na pagina da semana.

Em Exercicios, clique na data do card para abrir os detalhes do treino. A pagina
mostra duracao, intensidade e observacoes; nos itens de treino, tambem apresenta
grupos musculares, exercicios, series e imagens disponiveis. As acoes Editar e
Duplicar ficam acessiveis nessa pagina.

## Requisitos

- Ruby compativel com Rails 8
- PostgreSQL
- Bundler
- Node.js e Yarn
- wkhtmltopdf, necessario para gerar PDFs

## Configuracao

O banco principal usa PostgreSQL. Configure as variaveis abaixo para desenvolvimento
e teste, conforme `config/database.yml`:

```bash
DEV_USERNAME=
DEV_HOST=
DEV_PASSWORD=
DEV_PORT=

TEST_USERNAME=
TEST_HOST=
TEST_PASSWORD=
TEST_PORT=
```

Em producao, a aplicacao usa a mesma URL de PostgreSQL para os bancos `primary`,
`cache`, `queue` e `cable`:

```bash
DATABASE_URL_FINANCIAL_MANAGER=
```

Uploads em producao usam Supabase Storage via compatibilidade S3:

```bash
SUPABASE_S3_ACCESS_KEY_ID=
SUPABASE_S3_SECRET_ACCESS_KEY=
SUPABASE_S3_REGION=us-east-1
SUPABASE_STORAGE_BUCKET=
SUPABASE_S3_ENDPOINT=
```

Outras variaveis relevantes:

```bash
RAILS_MAX_THREADS=5
RAILS_LOG_LEVEL=info
PORT=3000
SOLID_QUEUE_IN_PUMA=
JOB_CONCURRENCY=1
```

## Instalacao

```bash
git clone https://github.com/carlosmurilodn/financial_manager.git
cd financial_manager

bundle install
yarn install --check-files
bin/rails db:prepare
```

Tambem e possivel usar o script do Rails:

```bash
bin/setup
```

## Execucao local

Use `bin/dev` para subir Rails e build JavaScript em modo watch:

```bash
bin/dev
```

A aplicacao fica disponivel em:

```text
http://localhost:3000
```

Para subir apenas o servidor Rails:

```bash
bin/rails server
```

## Banco de dados

Comandos principais:

```bash
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

O projeto tambem inclui `yaml_db`, usado para carga e exportacao de dados em YAML
quando necessario.

## Testes e qualidade

O projeto possui suites em RSpec e Minitest.

```bash
bundle exec rspec
bin/rails test
bin/rubocop
bin/brakeman
```

## Rotas principais

### Autenticacao

- Rotas Devise de usuario, incluindo `/users/sign_in` e `/users/sign_out`
- Sessoes customizadas em `Users::SessionsController`

### Financeiro

- `GET /`
- `GET /expenses`
- `GET /expenses/report`
- `GET /expenses/report_pdf`
- `GET /expenses/:id/delete_options`
- `GET /expenses/:id/toggle_paid_options`
- `PATCH /expenses/:id/toggle_paid`
- `DELETE /expenses/clear_filters`
- `GET /incomes`
- `PATCH /incomes/:id/toggle_paid`
- `DELETE /incomes/clear_filters`
- `GET /cards`
- `POST /cards/:id/pay`
- `DELETE /cards/clear_filters`
- `GET /categories`
- `GET /financial_goals`
- `DELETE /financial_goals/clear_filters`
- `GET /reports`
- `GET /reports/forecast`
- `GET /reports/forecast_pdf`

### Saude fisica

- `GET /progresso`
- `GET /progresso/perfil`
- `GET /progresso/alimentacao`
- `GET /progresso/alimentacao/nova`
- `GET /progresso/alimentacao/:week_start`
- `PATCH /progresso/alimentacao/:week_start/dia`
- `GET /progresso/calorias/:occurred_on`
- `POST /progresso/calorias`
- `GET /progresso/pesagens`
- `GET /progresso/exercicios`
- `GET /progresso/exercicios/:id`
- `GET /progresso/exercicios/:id/edit`
- `GET /progresso/exercicios/:id/duplicar`

Os parametros `week_start` e `occurred_on` usam datas no formato `AAAA-MM-DD`.
O status diario recebe `occurred_on` e `diet_status` (`full`, `partial`, `none`
ou vazio para limpar).

### PWA

- `GET /manifest`
- `GET /service-worker`

## Estrutura

```text
app/
  controllers/
  models/
  views/
  javascript/
  assets/
config/
db/
spec/
test/
```

- `app/controllers`: fluxo HTTP, filtros, ordenacao e respostas Turbo
- `app/models`: regras de dominio, validacoes e associacoes
- `app/views`: telas HTML renderizadas pelo Rails
- `app/javascript`: Stimulus, Bootstrap, Chart.js e scripts da interface
- `config`: rotas, ambiente, banco, storage, fila e deploy
- `db`: migrations, schemas dos bancos Solid e seeds
- `spec` e `test`: suites de teste em RSpec e Minitest

## Docker e deploy

O projeto tem `Dockerfile`, `bin/docker-entrypoint` e configuracao Kamal em
`config/deploy.yml`.

Build local da imagem:

```bash
docker build -t financial_manager .
```

Execucao local da imagem:

```bash
docker run -p 3000:3000 financial_manager
```

Antes de publicar em producao, configure as variaveis de banco, storage e segredos
necessarias no ambiente de deploy.

## Convencoes de manutencao

- Manter autenticacao centralizada com Devise
- Usar variaveis de ambiente para configuracoes sensiveis
- Evitar versionar segredos, tokens e credenciais
- Preferir controllers simples e regras de negocio nos models/services existentes
- Reutilizar concerns e padroes ja presentes no projeto
- Atualizar este README quando mudar onboarding, comandos essenciais, ambiente ou
  fluxo principal

## Autor

Carlos Novais
