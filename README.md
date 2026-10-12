# Gamify API

API REST do projeto Gamify, desenvolvida como parte de um Trabalho de Conclusão de Curso da UNIPÊ, em João Pessoa.

O projeto propõe uma abordagem de gamificação aplicada ao acompanhamento de pessoas com TDAH, explorando a teoria das 9 inteligências por meio de perfis, tarefas e missões. Este repositório contém apenas o backend da solução. O cliente será desenvolvido separadamente em Flutter.

## Objetivo

Esta API centraliza as regras e os dados da aplicação, permitindo:

- consultar perfis de usuários;
- recuperar tarefas associadas a um perfil;
- cadastrar novas tarefas gamificadas;
- cadastrar missões vinculadas a um perfil e, opcionalmente, a uma tarefa;
- armazenar atributos relacionados às inteligências e ao progresso do usuário.

## Stack utilizada

- Java 26
- Spring Boot 4.1.1
- Spring Web MVC
- Spring Data JPA
- PostgreSQL
- Lombok
- SpringDoc OpenAPI / Swagger UI
- Gradle

## Estrutura do projeto

Os principais pacotes estão organizados da seguinte forma:

- `controllers`: exposição dos endpoints HTTP;
- `services`: regras de negócio;
- `repository`: acesso a dados com JPA;
- `models/entities`: entidades persistidas no banco;
- `models/dtos`: contratos de entrada e saída da API;
- `utils`: enums, exceções e utilitários auxiliares.

## Pré-requisitos

Antes de executar a API, garanta que o ambiente tenha:

- Java 26 instalado;
- PostgreSQL em execução;
- variáveis de ambiente do banco configuradas;
- Gradle Wrapper disponível no projeto.

## Configuração

A aplicação lê variáveis de ambiente para montar a conexão com o PostgreSQL. Em ambiente local, elas podem ser fornecidas pelo sistema operacional ou por um arquivo `.env` na raiz do projeto.


## Como executar

### Windows

```powershell
.\gradlew.bat bootRun
```

### Linux/macOS

```bash
./gradlew bootRun
```

Por padrão, a aplicação sobe em:

```text
http://localhost:8080
```

## Como testar

Para executar os testes automatizados:

### Windows

```powershell
.\gradlew.bat test
```

### Linux/macOS

```bash
./gradlew test
```

## Documentação da API

Com a aplicação em execução, a documentação interativa pode ser acessada em:

- Swagger UI: `http://localhost:8080/swagger-ui/index.html`
- OpenAPI JSON: `http://localhost:8080/v3/api-docs`

## Endpoints principais

### Perfis

#### Buscar perfil por e-mail

```http
GET /profiles/by-user-email/{email}
```

Retorna os dados de um perfil com:

- `userId`
- `email`
- `name`
- `avatarUrl`
- `level`
- `experience`
- `gold`
- `atributes`

#### Buscar perfil por UUID

```http
GET /profiles/by-user-uuid/{uuid}
```

#### Listar tarefas de um perfil

```http
GET /profiles/{uuid}/my_tasks
```

### Tarefas

#### Criar nova tarefa

```http
POST /tasks/newtask
Content-Type: application/json
```

Exemplo de payload:

```json
{
  "profileUuid": "eb01b1fc-5ca0-49fe-85e1-264dd781ed7c",
  "title": "Estudar 30 minutos",
  "description": "Revisar o conteúdo planejado para o dia",
  "reward": 25,
  "experience": 40,
  "frequency": "DAILY",
  "scheduledTime": "19:30",
  "daysOfWeek": ["MONDAY", "WEDNESDAY", "FRIDAY"],
  "expirationDate": "2026-12-31T23:59:59.000Z",
  "partOfMission": false
}
```

Campos relevantes:

- `frequency`: aceita `UNIQUE`, `DAILY`, `WEEKLY` ou `MONTHLY`;
- `daysOfWeek`: aceita valores como `MONDAY`, `TUESDAY`, `WEDNESDAY`, `THURSDAY`, `FRIDAY`, `SATURDAY` e `SUNDAY`;
- `scheduledTime`: horário opcional no formato `HH:mm`;
- `expirationDate`: data opcional de expiração;
- `partOfMission`: indica se a tarefa pertence a uma missão.

### Missões

#### Criar nova missão

```http
POST /missions/new
Content-Type: application/json
```

Exemplo de payload:

```json
{
  "userId": "eb01b1fc-5ca0-49fe-85e1-264dd781ed7c",
  "title": "Concluir rotina da semana",
  "reward": 50,
  "experience": 100,
  "taskId": "ab253afa-fdd5-4a14-9666-9f78cfa6cf88"
}
```

O campo `taskId` é opcional e pode ser usado para associar a missão a uma tarefa já existente.

## Modelo de domínio

Atualmente, o perfil do usuário mantém dados de progresso gamificado, incluindo:

- nível;
- experiência;
- ouro;
- atributos associados às inteligências e características do usuário.

Os atributos persistidos hoje na API são:

- `strength`
- `spirituality`
- `intelligence`
- `charisma`
- `spatialPerception`
- `selfAwareness`
- `language`
- `logicalReasoning`
- `musicality`

## Informações importantes

- Este repositório representa somente a camada de API do projeto.
- O cliente da aplicação será desenvolvido em Flutter, em um projeto separado.
- A aplicação usa `spring.jpa.hibernate.ddl-auto=update`, portanto o schema pode ser ajustado automaticamente conforme as entidades.
- Os perfis são consultados pela API, mas neste estado atual não há endpoint público para criação de perfil neste projeto.
- Para criar tarefas e missões, o perfil informado precisa existir previamente no banco.
- O arquivo `requests.http` contém um exemplo simples de requisição para apoio em testes manuais.

## Contexto acadêmico

Este projeto integra um TCC da universidade UNIPÊ, em João Pessoa, com foco em gamificação e no apoio a pessoas com TDAH por meio de mecânicas de progresso, recompensas e exploração inspirada na teoria das 9 inteligências.