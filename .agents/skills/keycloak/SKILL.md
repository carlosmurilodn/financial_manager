---
name: Keycloak
description: Expert guidance for Keycloak identity and access management including realm configuration, client setup, user federation, authentication flows, role-based access control, and integration with applications. Use this when setting up authentication, configuring SSO, managing users and roles, or integrating Keycloak with applications.
---

# Keycloak

Expert assistance with Keycloak identity and access management platform.

## Overview

Keycloak is an open-source Identity and Access Management (IAM) solution providing:
- Single Sign-On (SSO)
- Identity brokering and social login
- User federation (LDAP/Active Directory)
- Standard protocols (OAuth 2.0, OpenID Connect, SAML 2.0)
- Fine-grained authorization
- Admin console and account management


## Realm Configuration
- use keycloak-test-openid-configuration.json file for reference

## Client Configuration
- use keycloak-test-client-configuration.json file for reference

### Create Client

### Browser Flow (Default)
```
Authentication > Flows > Browser

Steps:
1. Cookie (SSO check)
2. Kerberos (optional)
3. Forms (username/password)
   - Username password form
   - OTP form (if enabled)
```

### Custom Authentication Flow
```
1. Duplicate existing flow:
   Flows > Browser > Duplicate

2. Customize:
   - Add execution
   - Set requirement (REQUIRED, ALTERNATIVE, DISABLED)

3. Bind to client:
   Clients > [client] > Advanced > Authentication flow overrides
   - Browser flow: [custom-flow]
```

### Two-Factor Authentication
```
1. Enable OTP:
   Authentication > Flows > Browser
   - Add execution: OTP Form
   - Requirement: CONDITIONAL

2. Configure OTP:
   Authentication > OTP Policy
   - Type: Time-based or Counter-based
   - Algorithm: SHA1, SHA256, SHA512
   - Digits: 6
   - Period: 30 seconds

3. Users enable OTP:
   Account console > Account security > Signing in
   - Set up Authenticator Application
```

## User Federation

### LDAP Integration
```
User Federation > Add provider > LDAP

Connection:
- Console display name: LDAP
- Edit mode: READ_ONLY or WRITEABLE
- Sync registrations: ON
- Vendor: Active Directory, Red Hat Directory Server, etc.
- Connection URL: ldap://ldap.example.com:389
- Users DN: ou=users,dc=example,dc=com
- Bind DN: cn=admin,dc=example,dc=com
- Bind credential: password

LDAP searching and updating:
- Custom user search filter: (objectClass=person)
- Search scope: Subtree

Synchronization:
- Batch size: 1000
- Full sync period: 604800 (weekly)
- Changed users sync period: 86400 (daily)

Test connection and authentication
```

### Custom User Storage SPI
```java
public class CustomUserStorageProvider implements UserStorageProvider {
    @Override
    public UserModel getUserById(String id, RealmModel realm) {
        // Fetch user from custom storage
    }

    @Override
    public UserModel getUserByUsername(String username, RealmModel realm) {
        // Lookup by username
    }

    @Override
    public UserModel getUserByEmail(String email, RealmModel realm) {
        // Lookup by email
    }
}
```

## Identity Providers

### Social Login (Google)
```
Identity Providers > Add provider > Google

Settings:
- Client ID: [from Google Console]
- Client secret: [from Google Console]
- Default scopes: openid profile email
- Store tokens: ON
- Stored tokens readable: ON

Mappers:
- Create mapper: Import from provider
- Sync mode: Import or Force
```

### SAML Provider
```
Identity Providers > Add provider > SAML

Settings:
- Service provider entity ID: my-app
- Single sign-on service URL: [from SAML provider]
- Name ID policy format: Email
- Principal type: Subject NameID
- Want AuthnRequests signed: ON

Import from URL or file for metadata
```

## Token Configuration

### Access Token
```
Clients > [client] > Settings > Advanced

Access Token Lifespan: 5 minutes
Client Session Idle: 30 minutes
Client Session Max: 10 hours

Include in token:
- Standard claims (sub, aud, iss, exp, iat)
- Custom claims via mappers
```

### Refresh Token
```
Realm Settings > Tokens

Refresh Token Max Reuse: 0
Revoke Refresh Token: ON
SSO Session Idle: 30 minutes
SSO Session Max: 10 hours
Offline Session Idle: 30 days
```

### Custom Claims
```
Client scopes > [scope] > Mappers > Create

Mapper type: User Attribute
User attribute: department
Token claim name: department
Claim JSON Type: String
Add to ID token: ON
Add to access token: ON
Add to userinfo: ON
```

## Admin API

### Get Admin Token
```bash
# Password grant
curl -X POST http://localhost:8080/realms/master/protocol/openid-connect/token \
  -d "client_id=admin-cli" \
  -d "username=admin" \
  -d "password=admin" \
  -d "grant_type=password"
```

## Security Best Practices

1. **Use HTTPS in production** - Always enable SSL/TLS
2. **Strong client secrets** - Use cryptographically random secrets
3. **Limit token lifetime** - Short-lived access tokens (5-15 min)
4. **Refresh token rotation** - Enable refresh token reuse detection
5. **PKCE for SPAs** - Use Proof Key for Code Exchange
6. **Content Security Policy** - Proper CSP headers
7. **Rate limiting** - Protect against brute force
8. **Regular updates** - Keep Keycloak up to date
9. **Audit logging** - Enable and monitor event logs
10. **Role hierarchy** - Use composite roles for complexity

## Troubleshooting

### Token Validation Issues
```bash
# Decode JWT token
echo $TOKEN | cut -d. -f2 | base64 -d | jq

# Verify token signature
curl http://localhost:8080/realms/myapp/protocol/openid-connect/certs
```

### Connection Issues
```bash
# Check Keycloak health
curl http://localhost:8080/health

# Check realm endpoints
curl http://localhost:8080/realms/myapp/.well-known/openid-configuration
```

### User Login Issues
1. Check user is enabled
2. Verify email is verified (if required)
3. Check required actions (password reset, email verify)
4. Review authentication logs (Events > Login Events)

### CORS Issues
```
Clients > [client] > Settings
- Web origins: http://localhost:3000
- Valid redirect URIs: http://localhost:3000/*
```

## Resources

- Docs: https://www.keycloak.org/documentation
- Admin REST API: https://www.keycloak.org/docs-api/latest/rest-api/
- Server Admin Guide: https://www.keycloak.org/docs/latest/server_admin/
- GitHub: https://github.com/keycloak/keycloak
- mp keycloak: keycloak-test-openid-configuration.json
