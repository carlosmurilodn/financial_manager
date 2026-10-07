---
name: action-mailer-patterns
description: >-
  Implements transactional emails with Action Mailer and TDD. Use ao criar models de
  e-mail, e-mails de notificação, redefinições de senha, views de e-mail ou quando o
  usuário mencionar mailer, e-mail, notificações ou e-mails transacionais.
license: MIT
compatibility: Ruby 3.3+, Rails 8.1+, Action Mailer
metadata:
  author: ThibautBaissac
  version: "1.0"
---

# Padrões Action Mailer para Rails 8

## Visão geral

Action Mailer lida com emails transacionais em Rails:
- Models de email em HTML e texto
- Layouts para um estilo consistente
- Pré-views para desenvolvimento
- Entrega em segundo plano via Active Job
- E-mails internacionalizados

## Início rápido

```bash
# Generate mailer
bin/rails generate mailer User welcome password_reset

# This creates:
# - app/mailers/user_mailer.rb
# - app/views/user_mailer/welcome.html.erb
# - app/views/user_mailer/welcome.text.erb
# - spec/mailers/user_mailer_spec.rb (if using RSpec)
```

## Estrutura do Projeto

```
app/
├── mailers/
│   ├── application_mailer.rb    # Base mailer
│   └── user_mailer.rb
├── views/
│   ├── layouts/
│   │   └── mailer.html.erb      # Email layout
│   └── user_mailer/
│       ├── welcome.html.erb
│       ├── welcome.text.erb
│       ├── password_reset.html.erb
│       └── password_reset.text.erb
spec/
├── mailers/
│   ├── user_mailer_spec.rb
│   └── previews/
│       └── user_mailer_preview.rb
```

## Fluxo de trabalho TDD

```
Mailer Progress:
- [ ] Step 1: Write mailer spec (RED)
- [ ] Step 2: Run spec (fails)
- [ ] Step 3: Create mailer method
- [ ] Step 4: Create email templates
- [ ] Step 5: Run spec (GREEN)
- [ ] Step 6: Create preview
- [ ] Step 7: Test delivery integration
```

## Configuração

### Configuração básica

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.default_url_options = { host: "example.com" }
config.action_mailer.smtp_settings = {
  address: "smtp.example.com",
  port: 587,
  user_name: Rails.application.credentials.smtp[:user_name],
  password: Rails.application.credentials.smtp[:password],
  authentication: "plain",
  enable_starttls_auto: true
}
```

### Aplicativo Mailer

```ruby
# app/mailers/application_mailer.rb
class ApplicationMailer < ActionMailer::Base
  default from: "noreply@example.com"
  layout "mailer"

  helper_method :app_name

  private

  def app_name
    Rails.application.class.module_parent_name
  end
end
```

## Testando Mailers

### Especificação Mailer

```ruby
# spec/mailers/user_mailer_spec.rb
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#welcome" do
    let(:user) { create(:user, email_address: "user@example.com", name: "John") }
    let(:mail) { described_class.welcome(user) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("user_mailer.welcome.subject"))
      expect(mail.to).to eq(["user@example.com"])
      expect(mail.from).to eq(["noreply@example.com"])
    end

    it "renders the HTML body" do
      expect(mail.html_part.body.to_s).to include("John")
      expect(mail.html_part.body.to_s).to include("Welcome")
    end

    it "renders the text body" do
      expect(mail.text_part.body.to_s).to include("John")
      expect(mail.text_part.body.to_s).to include("Welcome")
    end

    it "includes login link" do
      expect(mail.html_part.body.to_s).to include(new_session_url)
    end
  end

  describe "#password_reset" do
    let(:user) { create(:user) }
    let(:token) { "reset-token-123" }
    let(:mail) { described_class.password_reset(user, token) }

    it "renders the headers" do
      expect(mail.subject).to eq(I18n.t("user_mailer.password_reset.subject"))
      expect(mail.to).to eq([user.email_address])
    end

    it "includes reset link with token" do
      expect(mail.html_part.body.to_s).to include(token)
    end

    it "expires link information" do
      expect(mail.html_part.body.to_s).to include("24 hours")
    end
  end
end
```

### Teste de entrega

```ruby
# spec/services/user_registration_service_spec.rb
RSpec.describe UserRegistrationService do
  describe "#call" do
    it "sends welcome email" do
      expect {
        described_class.new.call(user_params)
      }.to have_enqueued_mail(UserMailer, :welcome)
    end
  end
end

# Integration test
RSpec.describe "User Registration", type: :request do
  it "sends welcome email after registration" do
    expect {
      post registrations_path, params: valid_params
    }.to have_enqueued_mail(UserMailer, :welcome)
  end
end
```

## Implementação Mailer

### Mailer básico

```ruby
# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    @login_url = new_session_url

    mail(
      to: @user.email_address,
      subject: t(".subject")
    )
  end

  def password_reset(user, token)
    @user = user
    @token = token
    @reset_url = edit_password_url(token: token)
    @expires_in = "24 hours"

    mail(
      to: @user.email_address,
      subject: t(".subject")
    )
  end
end
```

### Mailer com anexos

```ruby
class ReportMailer < ApplicationMailer
  def monthly_report(user, report)
    @user = user
    @report = report

    attachments["report-#{Date.current}.pdf"] = report.to_pdf
    attachments.inline["logo.png"] = File.read(Rails.root.join("app/assets/images/logo.png"))

    mail(to: @user.email_address, subject: t(".subject"))
  end
end
```

### Mailer com remetente dinâmico

```ruby
class NotificationMailer < ApplicationMailer
  def notify(recipient, sender, message)
    @recipient = recipient
    @sender = sender
    @message = message

    mail(
      to: @recipient.email_address,
      from: "#{@sender.name} <notifications@example.com>",
      reply_to: @sender.email_address,
      subject: t(".subject", sender: @sender.name)
    )
  end
end
```

## Models de e-mail

Sempre crie versões HTML e texto. Use I18n para todo o conteúdo de texto.

Ver [templates.md](references/templates.md) para models HTML completos, models de texto e exemplos de layout de e-mail.

## Prévias

Crie views para verificar visualmente os e-mails durante o desenvolvimento sem enviá-los.

Ver [previews.md](references/previews.md) para views básicas e views com vários estados.

## Internacionalização

Use `I18n.with_locale` dentro do método mailer para enviar e-mails no idioma de preferência do usuário.

Ver [i18n.md](references/i18n.md) para exemplos de arquivos de localidade (EN/FR) e implementação de entrega localizada.

## Métodos de entrega

### Entrega Imediata (Evitar na produção)

```ruby
UserMailer.welcome(user).deliver_now
```

### Entrega em segundo plano (preferencial)

```ruby
# Uses Active Job
UserMailer.welcome(user).deliver_later

# With options
UserMailer.welcome(user).deliver_later(wait: 5.minutes)
UserMailer.welcome(user).deliver_later(wait_until: Date.tomorrow.noon)
UserMailer.welcome(user).deliver_later(queue: :mailers)
```

### Dos serviços

```ruby
class UserRegistrationService
  def call(params)
    user = User.create!(params)
    UserMailer.welcome(user).deliver_later
    success(user)
  end
end
```

## Padrões Comuns

### E-mails condicionais

```ruby
class NotificationMailer < ApplicationMailer
  def daily_digest(user)
    @user = user
    @notifications = user.notifications.unread.today

    return if @notifications.empty?

    mail(to: @user.email_address, subject: t(".subject"))
  end
end
```

### E-mails em massa com lote

```ruby
class NewsletterJob < ApplicationJob
  def perform
    User.subscribed.find_each(batch_size: 100) do |user|
      NewsletterMailer.weekly(user).deliver_later
    end
  end
end
```

### Callbacks por e-mail

```ruby
class ApplicationMailer < ActionMailer::Base
  after_action :log_delivery

  private

  def log_delivery
    Rails.logger.info("Sending #{action_name} to #{mail.to}")
  end
end
```

## Lista de verificação

- [] Especificação Mailer escrita primeiro (RED)
- [] Método Mailer criado
- [] Model HTML criado
- [] Model de texto criado
- [] Usa I18n para todo o texto
- [] View criada
- [] Usa `deliver_later` (não `deliver_now`)
- [] Layout de e-mail estilizado
- [] Todas as specs GREEN

## Referências

- [templates.md](references/templates.md) — Model HTML, model de texto e exemplos de layout de e-mail
- [previews.md](references/previews.md) — ActionMailer::Preview examples com estados únicos e múltiplos
- [i18n.md](references/i18n.md) — Exemplos de arquivos locais e entrega de e-mail localizada
