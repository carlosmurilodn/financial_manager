# Servidor MCP — Fundação 7.1

## Escopo

Servidor na aplicação Rails 8.0.3/Ruby 3.3.4, SDK oficial `mcp` 1.7.0,
Streamable HTTP sem estado, resposta JSON e negociação MCP 2025-11-25
(SDK também reconhece versões anteriores compatíveis).
Única ferramenta: `get_server_info`. Não consulta livros ou manuscritos.
Autenticação: Doorkeeper 5.9.9, login Devise e consentimento explícito.
Não há uso de API de modelos OpenAI nem aplicação separada.

## Habilitar

Configure variáveis no ambiente do Rails e reinicie o servidor:

```dotenv
MCP_ENABLED=true
MCP_BASE_URL=https://gerenciador.example.com
MCP_ALLOWED_ORIGINS=https://chatgpt.com
```

`MCP_BASE_URL` é uma origem, sem path, query ou credenciais.
Recurso/audiência: `MCP_BASE_URL/mcp`. Origens extras são opcionais,
separadas por vírgulas e devem ser estritamente confiáveis.
Sem `MCP_ENABLED=true`, conexão e metadados ficam indisponíveis.
Em produção, URL HTTPS é obrigatória; Rails já usa `force_ssl` e `assume_ssl`.
O proxy deve manter Host correto, encaminhar HTTPS com segurança e não
permitir que o cliente sobrescreva os headers confiáveis do proxy.

Instale dependências com `bundle install`, aplique `bundle exec rails db:migrate`
e inicie Rails pelo fluxo habitual (`bin/rails server` local ou deploy atual).
Não é necessário worker. Não altere proteções globais CSRF ou hosts para MCP.
As tabelas OAuth usam RLS sem políticas públicas; acesso é feito pelo backend Rails.

## Cliente OAuth e ChatGPT

Há suporte a clientes pré-cadastrados; DCR e CIMD não são anunciados.
Cadastre callback exato informado pela interface de conexão do cliente:

```bash
MCP_CLIENT_NAME='ChatGPT' \
MCP_CLIENT_REDIRECT_URI='https://chatgpt.com/CALLBACK_EXATO_INFORMADO' \
bundle exec rake mcp:register_client
```

Tarefa imprime client ID e, para cliente confidencial, client secret uma vez
durante o cadastro. Guarde em gerenciador de segredos; não publique saída.
`MCP_CLIENT_CONFIDENTIAL=false` cadastra cliente público com PKCE obrigatório.
Não reutilize secret de outra aplicação. Secret é armazenado com hash, sem
recuperação posterior. Cadastro de cliente não autoriza usuário.

No ChatGPT, use configuração de servidor MCP remoto disponível na sua conta,
URL `https://gerenciador.example.com/mcp`, OAuth e credenciais do cliente
pré-cadastrado. Copie callback da própria interface; não assuma URL fixa.
Disponibilidade e nomes dos controles dependem da conta/interface.
Faça login no Gerenciador Pessoal e confirme consentimento.
Descoberta deve apresentar apenas `get_server_info`.

## Endpoints

| Endpoint | Uso |
| --- | --- |
| `/mcp` | Transporte MCP, Bearer obrigatório em todas as chamadas |
| `/.well-known/oauth-protected-resource/mcp` | Metadados RFC 9728 |
| `/.well-known/oauth-protected-resource` | Alias dos mesmos metadados |
| `/.well-known/oauth-authorization-server` | Metadados RFC 8414 |
| `/oauth/authorize` | Login/consentimento, authorization code e PKCE S256 |
| `/oauth/token` | Troca de código e refresh token |
| `/oauth/revoke` | Revogação RFC 7009 pelo cliente |
| `/oauth/authorized_applications` | Autorizações do usuário e revogação |

Sem token: HTTP 401 e `WWW-Authenticate` indicando metadados.
Sem escopo: HTTP 403. Host/origem não autorizados: HTTP 403.
GET/DELETE MCP não oferecem streams/sessões persistentes: SDK responde 405.
Erros JSON-RPC de protocolo e argumentos são tratados pelo SDK.
Introspecção e dashboard público de aplicações não são disponibilizados.

## Tokens e audiência

Escopo exclusivo `writing_studio:read`. Códigos duram cinco minutos;
access tokens duram 15 minutos. Refresh tokens rotacionam com revogação imediata
do anterior e expiram após 30 dias sem renovação.
Tokens opacos são verificados na base do próprio provedor; não há JWT externo
nem compartilhamento de tokens entre usuários. Grants e tokens guardam audiência
em `mcp_resource`; autorização exige `resource` correspondente ao recurso canônico.
Na troca/refresh, `resource` diferente é rejeitado; se omitido, a audiência
continua vinculada ao grant/token original pelo Doorkeeper.
Todas as chamadas validam expiração, revogação, audiência, escopo e usuário existente.

## Revogar

Usuário acessa `/oauth/authorized_applications` e escolhe Revogar Acesso.
Isso invalida tokens e códigos daquela aplicação somente para sua conta.
Operador pode revogar todos os usuários de um cliente:

```bash
MCP_CLIENT_ID='ID_DO_CLIENTE' bundle exec rake mcp:revoke_client
```

Tarefa revoga acessos atuais; impedir novas autorizações exige remover cliente.
Apagar usuário invalida seus registros OAuth por FK com cascata.

## Conexão local e validação manual

Para desenvolvimento local, `MCP_BASE_URL=http://localhost:3000` é aceito.
Clientes locais, como MCP Inspector, podem consultar transporte HTTP e OAuth.
ChatGPT precisa alcançar URL remota HTTPS; para conexão local, use túnel HTTPS
confiável, atualize `MCP_BASE_URL` com origem do túnel e reinicie Rails.
Grants emitidos para URL antiga deixam de servir a nova audiência.

Depois de configurar, valide pelo cliente: metadados; login/PKCE/consentimento;
troca do código; initialize; notifications/initialized; tools/list;
tools/call de `get_server_info`; rejeição após revogação.
POST usa `Content-Type: application/json` e Accept conforme Streamable HTTP.
Demais requisições MCP enviam `MCP-Protocol-Version` negociado.
HTTP 200 isolado não comprova conexão. Nenhum teste ou chamada de Inspector
foi executado nesta entrega, conforme instrução do usuário.

## Limites e ferramentas futuras

Corpo máximo 64 KiB para MCP/OAuth. Rack::Attack usa cache Rails compartilhado
em produção: 120 chamadas MCP/minuto/IP e 30 POSTs OAuth/minuto/IP; resposta 429.
Cache local de desenvolvimento tem limites por processo.
Logs filtram tokens, segredos, códigos e conteúdo; erros MCP registram só classe.
O transporte é criado por requisição com `McpIntegration::UserContext`, usuário
validado e ferramentas explicitamente registradas em `McpIntegration::Endpoint`.
Ferramentas futuras devem buscar livros por `server_context.books` e resolver IDs
dentro desse escopo, nunca em `WritingBook.find` global. Não usar conta administrativa.
Não registrar ferramentas de escrita sob escopo de leitura.

## Referências

- [SDK Ruby oficial MCP](https://github.com/modelcontextprotocol/ruby-sdk)
- [Transporte MCP 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25/basic/transports)
- [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper)
- [Autenticação de servidores para ChatGPT](https://developers.openai.com/plugins/build/auth)
