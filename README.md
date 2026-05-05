# Financial Manager API

API para gerenciamento financeiro, com autenticação integrada via Keycloak.

## 🚀 Tecnologias

- Ruby on Rails
- PostgreSQL
- Keycloak (OpenID Connect)
- Docker (opcional)

---

## 📦 Funcionalidades

- Autenticação via Keycloak
- Consulta de dados financeiros:
  - Contracheque
  - Funcional recente
- API versionada (`/api/v1`)
- Separação entre Web e Mobile

---

## 🔐 Autenticação

A autenticação é feita via Keycloak utilizando OpenID Connect.

Fluxos disponíveis:

- Login via `/api/auth/login`
- Troca de token mobile `/api/auth/mobile/exchange`
- Endpoint autenticado `/api/v1/auth/me`

---

## 🛠️ Setup do projeto

### Pré-requisitos

- Ruby (verificar versão no `.ruby-version`)
- PostgreSQL
- Bundler

### Instalação

```bash
git clone https://github.com/carlosmurilodn/financial_manager.git
cd financial_manager

bundle install
```

### Configuração

Crie um arquivo `.env` baseado no `.env.example` (se aplicável) e configure:

- Credenciais do banco
- Configurações do Keycloak

---

## 🗄️ Banco de dados

```bash
rails db:create
rails db:migrate
```

---

## ▶️ Rodando a aplicação

```bash
rails s
```

A API estará disponível em:

```text
http://localhost:3000
```

---

## 🧪 Testes

```bash
rails test
```

---

## 📡 Principais endpoints

### Autenticação

- `POST /api/auth/login`
- `POST /api/auth/mobile/exchange`
- `GET /api/v1/auth/me`

### Financeiro

- `GET /api/v1/financeiros/funcional_recente`
- `GET /api/v1/financeiros/contracheque`
- `GET /api/v1/financeiros/contracheque/pdf`

---

## 🏗️ Estrutura do projeto

```text
app/
  controllers/
  models/
  services/
  concerns/
```

- Controllers: camada fina (HTTP)
- Services: regras de negócio
- Models: acesso a dados

---

## 🐳 Docker (opcional)

Caso utilize Docker:

```bash
docker-compose up --build
```

---

## 🚀 Deploy

- Configurar variáveis de ambiente
- Garantir acesso ao Keycloak
- Rodar migrations

---

## 📌 Boas práticas do projeto

- Evitar refatorações desnecessárias
- Reutilizar código existente
- Controllers finos
- Lógica em services
- Segurança via Keycloak

---

## 👨‍💻 Autor

Carlos Novais
