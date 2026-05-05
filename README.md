# Financial Manager

Aplicação Rails para gerenciamento financeiro pessoal, com autenticação via Devise e recursos para controle de despesas, receitas, cartões, categorias, metas financeiras e relatórios.

## 🚀 Tecnologias

- Ruby on Rails 8
- PostgreSQL
- Devise
- Hotwire (Turbo + Stimulus)
- Propshaft
- Solid Cache, Solid Queue e Solid Cable
- PDFKit + wkhtmltopdf
- AWS SDK S3
- Docker/Kamal (opcional)

---

## 📦 Funcionalidades

- Autenticação de usuários com Devise
- Controle de despesas
- Controle de receitas
- Cadastro e gerenciamento de categorias
- Cadastro e acompanhamento de metas financeiras
- Gerenciamento de cartões
- Marcação de despesas e receitas como pagas
- Importação e análise de faturas
- Relatórios financeiros
- Geração de relatórios em PDF
- Previsão financeira
- Suporte a PWA

---

## 🔐 Autenticação

A autenticação é feita com Devise.

Rotas principais:

- Login de usuários
- Logout de usuários
- Sessões customizadas em `Users::SessionsController`

---

## 🛠️ Setup do projeto

### Pré-requisitos

- Ruby compatível com Rails 8
- PostgreSQL
- Bundler
- wkhtmltopdf, para geração de PDFs quando necessário

### Instalação

```bash
git clone https://github.com/carlosmurilodn/financial_manager.git
cd financial_manager

bundle install
```

### Configuração

Configure as variáveis de ambiente necessárias para o projeto, especialmente:

- Credenciais do banco de dados
- Configurações de armazenamento, quando usar S3
- Configurações específicas para geração/importação de arquivos, se aplicável

---

## 🗄️ Banco de dados

```bash
rails db:create
rails db:migrate
```

---

## ▶️ Rodando a aplicação

```bash
rails server
```

A aplicação estará disponível em:

```text
http://localhost:3000
```

---

## 🧪 Testes

```bash
rails test
```

---

## 📡 Principais rotas

### Autenticação

- Rotas Devise para usuários (`/users/sign_in`, `/users/sign_out`, etc.)

### Financeiro

- `GET /expenses`
- `GET /expenses/report`
- `GET /expenses/report_pdf`
- `POST /expenses/analyze_invoice`
- `POST /expenses/confirm_invoice_import`
- `GET /expenses/import_invoice`
- `PATCH /expenses/:id/toggle_paid`
- `GET /incomes`
- `PATCH /incomes/:id/toggle_paid`
- `GET /cards`
- `POST /cards/:id/pay`
- `GET /categories`
- `GET /financial_goals`
- `GET /reports`
- `GET /reports/forecast`
- `GET /reports/forecast_pdf`

---

## 🏗️ Estrutura do projeto

```text
app/
  controllers/
  models/
  views/
  javascript/
  assets/
```

- Controllers: fluxo HTTP e orquestração das ações
- Models: regras de domínio, validações, associações e acesso a dados
- Views: telas HTML renderizadas pelo Rails
- JavaScript: comportamentos com Stimulus
- Assets: estilos, imagens e arquivos estáticos

---

## 🐳 Docker e deploy

O projeto possui suporte para deploy com Kamal e execução em container Docker, conforme configuração do Rails.

Com Docker, o fluxo básico é:

```bash
docker build -t financial_manager .
docker run -p 3000:3000 financial_manager
```

Para deploy com Kamal, configure os arquivos e variáveis necessários antes de executar os comandos de deploy.

---

## 📌 Boas práticas do projeto

- Manter autenticação centralizada com Devise
- Evitar versionar segredos, tokens e credenciais
- Usar variáveis de ambiente para configurações sensíveis
- Reutilizar métodos, helpers e padrões já existentes
- Evitar refatorações amplas quando uma alteração localizada resolver o problema
- Manter controllers simples sempre que possível
- Criar services apenas quando houver complexidade real de regra de negócio

---

## 👨‍💻 Autor

Carlos Novais
