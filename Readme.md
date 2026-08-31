# DimDim Cloud API

Checkpoint de DevOps Tools & Cloud Computing desenvolvido para a FIAP.

## Aluno

Carlos Eduardo Rodrigues Coelho Pacheco  
RM557323

## Projeto

O DimDim é uma API REST para gerenciamento de transações financeiras.

A aplicação permite realizar operações CRUD utilizando Java com Spring Boot e PostgreSQL.

## Tecnologias

- Java 21
- Spring Boot
- Spring Data JPA
- PostgreSQL 16
- Maven
- Docker
- Docker Compose
- Azure CLI
- Azure Container Registry
- Azure Container Instances
- Azure Storage
- Azure Virtual Network
- Azure Application Gateway

## Arquitetura

A aplicação e o banco de dados são executados em containers.

As imagens Docker são construídas localmente e enviadas ao Azure Container Registry.

Na Azure, a aplicação Java e o PostgreSQL são executados através do Azure Container Instances dentro de uma Virtual Network.

O acesso externo à API é realizado através de um Azure Application Gateway.

O Azure Storage é utilizado para armazenamento persistente de backup do banco de dados.

Fluxo:

```text
Cliente
   |
   v
Public IP
   |
   v
Application Gateway
   |
   v
Java Spring Boot - ACI
   |
   v
PostgreSQL - ACI
```

As imagens são armazenadas no Azure Container Registry.

## Estrutura

```text
.
├── app/
│   ├── src/
│   ├── Dockerfile
│   └── pom.xml
├── database/
│   ├── backup/
│   ├── Dockerfile
│   └── init.sql
├── azure/
│   ├── 01-create-infra.ps1
│   ├── 02-push-images.ps1
│   ├── 03-deploy-aci.ps1
│   └── 99-cleanup.ps1
├── tests/
│   ├── create.json
│   └── update.json
├── docker-compose.yml
└── README.md
```

## Executando localmente

É necessário possuir Docker e Docker Compose instalados.

Na raiz do projeto:

```powershell
docker compose build
docker compose up -d
```

Verifique os containers:

```powershell
docker ps
```

A API ficará disponível em:

```text
http://localhost:8080/api/transacoes
```

## CRUD

### Listar transações

```http
GET /api/transacoes
```

### Buscar transação

```http
GET /api/transacoes/{id}
```

### Criar transação

```http
POST /api/transacoes
Content-Type: application/json
```

Exemplo:

```json
{
  "descricao": "Mercado",
  "valor": 150.90,
  "tipo": "DESPESA",
  "dataTransacao": "2026-08-31"
}
```

### Atualizar

```http
PUT /api/transacoes/{id}
```

### Excluir

```http
DELETE /api/transacoes/{id}
```

## Banco de dados

A tabela principal é:

```text
transacoes
```

Para verificar diretamente no PostgreSQL local:

```powershell
docker exec -it dimdim-db psql -U postgres -d dimdim
```

Depois:

```sql
SELECT * FROM transacoes;
```

## Docker

Existem Dockerfiles separados para:

- aplicação Java;
- PostgreSQL.

A aplicação é executada utilizando usuário não-root dentro do container.

## Azure Container Registry

As imagens utilizadas são:

```text
dimdim-app:v1
dimdim-db:v1
```

O script responsável pelo build e envio das imagens está em:

```text
azure/02-push-images.ps1
```

## Deploy Azure

A infraestrutura é criada utilizando Azure CLI.

Os scripts estão disponíveis em:

```text
azure/
```

Antes do deploy, configure a senha do banco em uma variável de ambiente:

```powershell
$env:DIMDIM_DB_PASSWORD="SUA_SENHA"
```

Execute:

```powershell
.\azure\01-create-infra.ps1
.\azure\02-push-images.ps1
.\azure\03-deploy-aci.ps1
```

## Persistência

O projeto utiliza Azure Storage com Azure File Share.

Devido às características de montagem SMB do Azure Files em Azure Container Instances, o backup persistente do PostgreSQL é armazenado no File Share.

Exemplo:

```text
dimdim-backup.sql
```

O dump pode ser criado utilizando:

```bash
pg_dump -U postgres -d dimdim
```

## API na Azure

Após o deploy, a API é disponibilizada através do Azure Application Gateway.

Endpoint:

```text
http://191.232.55.130/api/transacoes
```

> O endereço IP pode mudar caso a infraestrutura seja recriada.

## Limpeza dos recursos

Para evitar custos desnecessários após a avaliação:

```powershell
.\azure\99-cleanup.ps1
```

O script solicita confirmação antes de remover o Resource Group.