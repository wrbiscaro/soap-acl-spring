# Microservice para consumo de webservice SOAP com ACL (Access Control List)

## Tecnologias utilizadas
- Java 21
- Spring Boot 3
- Spring Cloud 2023
- Feign
- Spring Security
- Keycloak (authorization server)
- Terraform
- AWS (ALB + ECS)
- Open Telemetry
- New Relic

## Observability
Os logs, metricas e traces sao enviados ao New Relic através de Open Telemetry, seguindo a seguinte estrutura: **app -> opentelemetry collector -> new relic otlp endpoint**

Subimos o **Otel Collector** via docker-compose e sua configuracao esta no arquivo "resources/local/collector/otel-collector-config.yaml". O collector faz export para o New Relic usando **OpenTelemetry Protocol (OTLP)**. 

Foi usada a instrumentacao automatica usando o **opentelemetry-javaagent.jar**. Para ativá-la, basta subir a aplicacao passando o agent como argumento da JVM: **-javaagent:opentelemetry-javaagent.jar**. Também precisamos setar as seguintes envs:
```env
# Nome do servico no New Relic
OTEL_SERVICE_NAME=soap-acl-spring

# Desabilita o envio dos comandos/args usados para subir a aplicacao, por questao de seguranca e pois a string é muito grande, o que faz o envio quebrar no New Relic
OTEL_EXPERIMENTAL_RESOURCE_DISABLED_KEYS=process.command_args

# Env para habilitar o debug, caso necessario
OTEL_JAVAAGENT_DEBUG=false
``` 

### Conceitos básicos:
* Span é a unidade logica e possui um nome, timestamp de inicio e duracao.
* Trace representa o caminho percorrido pela requisicao. É um conjunto dos spans envolvidos na requisicao.
* Baggage sao metadados (chave/valor) que podemos anexar ao nosso contexto e propagar pelo sdk de rastreamento. útil quando fazemos a instrumentacao manual (sem agent).

## Como rodar o projeto
1. Subir o keycloak auth server e o opentelemetry collector com o comando **'docker-compose up'**. O servidor do keycloack poderá ser acessado através da URL http://localhost:8081, com o usuario e senha setados no docker-compose.
2. No console do keycloak, criar um realm, um client, uma role, um usuario/senha e mapear a role criada anteriormente para ele. As configs criadas para esse exemplo podem ser vistas na estrutura do jwt no tópico abaixo.
3. Compilar o projeto com o comando **mvn clean install**.
4. Executar o projeto com o comando **java -javaagent:opentelemetry-javaagent.jar -jar target/soap-acl-spring-0.0.1-SNAPSHOT**.
5. Fazer a autenticacao para gerar um token jwt, atraves da chamada abaixo:
```curl
curl --request POST \
  --url http://localhost:8081/realms/soap-acl-realm/protocol/openid-connect/token \
  --header 'Content-Type: application/x-www-form-urlencoded' \
  --data grant_type=password \
  --data client_id=soap-acl-client \
  --data username=soap-acl-admin \
  --data password=password
```
6. Fazer a requisicao para o endpoint 'converter', passando o jwt gerado acima e o numero que deseja converter para nome extenso:
```curl
curl --request GET \
  --url http://localhost:8080/converter/1 \
  --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJJSnNUbTlWY3JJcU5UVmkweWdYOTlWajFhaG54dXc0bURMYk5wRUxJSklVIn0.eyJleHAiOjE3MTA0NzMzNDQsImlhdCI6MTcxMDQ3MzA0NCwianRpIjoiODcxN2JlYWEtZTI0NS00MzhjLWFmYTQtZTAyMmRiNjY0MGU4IiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgxL3JlYWxtcy9zb2FwLWFjbC1yZWFsbSIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiIyNWUwNWE1MC0zMTMyLTQzMzQtYmUwYi1lMDA2Nzc3MTJjNWEiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJzb2FwLWFjbC1jbGllbnQiLCJzZXNzaW9uX3N0YXRlIjoiYzhhNTAwYjAtOTM0Yy00YjIzLThmYWMtN2VlNjQ5NWE4YThjIiwiYWNyIjoiMSIsImFsbG93ZWQtb3JpZ2lucyI6WyIvKiJdLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiIsImRlZmF1bHQtcm9sZXMtc29hcC1hY2wtcmVhbG0iXX0sInJlc291cmNlX2FjY2VzcyI6eyJzb2FwLWFjbC1jbGllbnQiOnsicm9sZXMiOlsiQURNSU5fUk9MRSJdfSwiYWNjb3VudCI6eyJyb2xlcyI6WyJtYW5hZ2UtYWNjb3VudCIsIm1hbmFnZS1hY2NvdW50LWxpbmtzIiwidmlldy1wcm9maWxlIl19fSwic2NvcGUiOiJwcm9maWxlIGVtYWlsIiwic2lkIjoiYzhhNTAwYjAtOTM0Yy00YjIzLThmYWMtN2VlNjQ5NWE4YThjIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsIm5hbWUiOiJhYSBhYiIsInByZWZlcnJlZF91c2VybmFtZSI6InNvYXAtYWNsLWFkbWluIiwiZ2l2ZW5fbmFtZSI6ImFhIiwiZmFtaWx5X25hbWUiOiJhYiIsImVtYWlsIjoiYUBhLmNvbSJ9.X8yXC4sTFtcpjxew1HVKyd4GehPJdGrtWszt3DGHregj0oCgNwhHnQH_BGjJC7GYCowYNof0eTkpyGhRKhKRfEFHu-hunbfB8er-FSvXz6nW5sxZ7oeTf8ubcMvzNrzZIHioYnaLKnT8CceyFDdTZEpambNOeZy4DxmNW-wk9R1Dk0j4HViY0LZW2a2eZfKcjxGbw85Av_P36gynODtx9e_bOtDl1B9RQZN97m39YLvvdJn6cxHDE3st7TZxwtf3hvC7hI8DJsfsytuUgGMcfI7I8WpezJCM_M5-1y_7EqotL2gaV4slIQndmdFMm4mcnCis1sH74pSNJuFswMQNdw'
```
* Para subir o projeto sem auth, pode ser usado o spring profile "noauth".

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

## Como fazer o deploy na AWS
1. Criar um repo no ECR para armazenar a imagem da nossa app, com o nome "soap-acl-spring-prod". A pasta de infra contém um modulo pra criar o repo, mas a criacao do repo e o deploy da imagem (passo 2) devem ocorrer antes da subida do container, senao ele nao ira encontrar a imagem.
2. Dentro da pasta app, executar os comandos abaixo para fazer login no ECR, buildar e imagem e fazer o deploy dela no ECR. As opcoes "buildx" e "--platform" do segundo comando sao necessarios para fazer um **multiplataform build** para execucao da app dentro de uma maquina Linux, caso esse comando seja executado a partir de uma maquina MacOS.
```terminal
aws ecr get-login-password --region sa-east-1 | docker login --username AWS --password-stdin 638260411513.dkr.ecr.sa-east-1.amazonaws.com

docker buildx build --platform linux/amd64,linux/arm64 -t 638260411513.dkr.ecr.sa-east-1.amazonaws.com/soap-acl-spring-prod:latest --push .
```
3. Dentro da pasta infra/env/prod, executar os comandos terraform init, plan e apply para fazer o deploy da infra. A infra contém um ALB com target para um ECS Fargate e todas as dependencias necessarias para funcionamento (VPC, SG, IAM, etc).

## Referencias
- SOAP com Feign: https://dev.to/rodrigovp/feign-com-soap-uma-poc-2daf
- Webservice SOAP: https://www.dataaccess.com/webservicesserver/NumberConversion.wso
- Keycloak com Spring: https://medium.com/enfuse-io/method-level-authorization-with-spring-boot-and-keycloak-8e7d45351c1d
- Spring Security: https://www.baeldung.com/spring-security-method-security
- Spring Security Documentation: https://docs.spring.io/spring-security/reference/
- Open Telemetry: https://opentelemetry.io/docs/languages/java/getting-started/
- New Relic: https://docs.newrelic.com/docs/more-integrations/open-source-telemetry-integrations/opentelemetry/get-started/opentelemetry-set-up-your-app/