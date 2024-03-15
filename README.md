# Microservice para consumo de webservice SOAP com ACL (Access Control List)

## Tecnologias utilizadas
- Java 21
- Spring Boot 3
- Spring Cloud 2023
- Feign
- Spring Security
- Keycloak (authorization server)

## Como rodar o projeto
1. Subir o keycloak auth server com o comando **'docker-compose up'**. O servidor poderá ser acessado através da URL 
2. No console do keycloak, criar um realm, um client, uma role, um usuario/senha e mapear a role criada anteriormente para ele. As configs criadas para esse exemplo podem ser vistas na estrutura do jwt no tópico abaixo. 
3. Executar o projeto com o comando **'mvn exec:java -Dexec.mainClass="com.wallacebiscaro.soapaclspringSoapAclSpringApplication"'**
4. Fazer a autenticacao para gerar um token jwt, atraves da chamada abaixo:
```curl
curl --request POST \
  --url http://localhost:8081/realms/soap-acl-realm/protocol/openid-connect/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data client_id=soap-acl-client \
  --data username=soap-acl-admin \
  --data password=password
```
5. Fazer a requisicao para o endpoint 'converter', passando o jwt gerado acima e o numero que deseja converter para nome extenso:
```curl
curl --request GET \
  --url http://localhost:8080/converter/1 \
  --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJJSnNUbTlWY3JJcU5UVmkweWdYOTlWajFhaG54dXc0bURMYk5wRUxJSklVIn0.eyJleHAiOjE3MTA0NzMzNDQsImlhdCI6MTcxMDQ3MzA0NCwianRpIjoiODcxN2JlYWEtZTI0NS00MzhjLWFmYTQtZTAyMmRiNjY0MGU4IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxL3JlYWxtcy9zb2FwLWFjbC1yZWFsbSIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiIyNWUwNWE1MC0zMTMyLTQzMzQtYmUwYi1lMDA2Nzc3MTJjNWEiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJzb2FwLWFjbC1jbGllbnQiLCJzZXNzaW9uX3N0YXRlIjoiYzhhNTAwYjAtOTM0Yy00YjIzLThmYWMtN2VlNjQ5NWE4YThjIiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6WyIvKiJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsImRlZmF1bHQtcm9sZXMtc29hcC1hY2wtcmVhbG0iXX0sInJlc291cmNlX2FjY2VzcyI6eyJzb2FwLWFjbC1jbGllbnQiOnsicm9sZXMiOlsiQURNSU5fUk9MRSJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwic2lkIjoiYzhhNTAwYjAtOTM0Yy00YjIzLThmYWMtN2VlNjQ5NWE4YThjIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJhYSBhYiIsInByZWZlcnJlZF91c2VybmFtZSI6InNvYXAtYWNsLWFkbWluIiwiZ2l2ZW5fbmFtZSI6ImFhIiwiZmFtaWx5X25hbWUiOiJhYiIsImVtYWlsIjoiYUBhLmNvbSJ9.X8yXC4sTFtcpjxew1HVKyd4GehPJdGrtWszt3DGHregj0oCgNwhHnQH_BGjJC7GYCowYNof0eTkpyGhRKhKRfEFHu-hunbfB8er-FSvXz6nW5sxZ7oeTf8ubcMvzNrzZIHioYnaLKnT8CceyFDdTZEpambNOeZy4DxmNW-wk9R1Dk0j4HViY0LZW2a2eZfKcjxGbw85Av_P36gynODtx9e_bOtDl1B9RQZN97m39YLvvdJn6cxHDE3st7TZxwtf3hvC7hI8DJsfsytuUgGMcfI7I8WpezJCM_M5-1y_7EqotL2gaV4slIQndmdFMm4mcnCis1sH74pSNJuFswMQNdw'
```

## Estrutura do token JWT do Keycloak
```json
{
  "exp": 1710470757,
  "iat": 1710470457,
  "jti": "20354778-de2b-4afb-a009-0668b80eeb33",
  "iss": "http://localhost:8081/realms/soap-acl-realm",
  "aud": "account",
  "sub": "25e05a50-3132-4334-be0b-e00677712c5a",
  "typ": "Bearer",
  "azp": "soap-acl-client",
  "session_state": "8c81da38-15a7-4907-a97b-a9ed0e569753",
  "acr": "1",
  "allowed-origins": [
    "/*"
  ],
  "realm_access": {
    "roles": [
      "offline_access",
      "uma_authorization",
      "default-roles-soap-acl-realm"
    ]
  },
  "resource_access": {
    "soap-acl-client": {
      "roles": [
        "ADMIN_ROLE"
      ]
    },
    "account": {
      "roles": [
        "manage-account",
        "manage-account-links",
        "view-profile"
      ]
    }
  },
  "scope": "profile email",
  "sid": "8c81da38-15a7-4907-a97b-a9ed0e569753",
  "email_verified": true,
  "name": "aa ab",
  "preferred_username": "soap-acl-admin",
  "given_name": "aa",
  "family_name": "ab",
  "email": "a@a.com"
}
```

### Referencias
- SOAP com Feign: https://dev.to/rodrigovp/feign-com-soap-uma-poc-2daf
- Webservice SOAP: https://www.dataaccess.com/webservicesserver/NumberConversion.wso
- Keycloak com Spring: https://medium.com/enfuse-io/method-level-authorization-with-spring-boot-and-keycloak-8e7d45351c1d
- Spring Security: https://www.baeldung.com/spring-security-method-security
- Spring Security Documentation: https://docs.spring.io/spring-security/reference/