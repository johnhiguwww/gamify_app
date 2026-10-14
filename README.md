# Gamify

App em Flutter e API em Java para acompanhar tarefas, missões, atributos e uma loja de recompensas. Quem for rodar precisa dos três: o app, a API e o banco. O Firebase já está ligado neste repositório.

O celular **não** lê a tabela do Supabase direto. Ele chama a API Java. A API é quem entra no Postgres do Supabase.

```text
Flutter  →  API Java (porta 8080)  →  Postgres no Supabase
                ↑
           Firebase (projeto já marcado no app)
```

## O que cada parte faz

| Parte | Onde está | Função |
|---|---|---|
| App | `lib/` | Telas. Pasta `data` busca a API. Pasta `models` lê o JSON. |
| API | `src/main/java` | Regras de perfil, tarefa, missão e loja. |
| Banco | Supabase | Postgres. A API cria e atualiza as tabelas. |
| Firebase | `.firebaserc`, `.firebase` | Projeto Firebase deste repositório. |

Os models do app esperam o JSON da API Java (`experience`, `reward`, `atributes`). O REST automático do Supabase (`/rest/v1/...`) devolve outro formato e **não** serve nesses models.

## O que instalar

- Flutter (canal stable) e um aparelho ou emulador
- Java 25 (é a versão do `build.gradle`)
- Android Studio ou o SDK do Android, se for rodar no celular
- Conta no projeto Supabase que guarda o banco
- Firebase CLI, se for gerar de novo o arquivo do Firebase (`npm i -g firebase-tools`)

## 1. Banco no Supabase

No painel do Supabase, em **Project Settings → Database**, copie o host. O usuário do banco costuma ser `postgres`. A senha é a do banco, não a `anon key` e não a `service_role`.

Crie um arquivo `.env` na **raiz do projeto** (ao lado do `gradlew`). A API lê esse arquivo. Não commite.

```properties
DB_HOST=db.eiyfmcjzhqqcrofllsjd.supabase.co
DB_PORT=5432
DB_DATABASE=postgres
DB_USER=postgres
DB_PASSWORD=[*************]
# Dados de conexão com o Postgres do Supabase.
# Pegue esses valores em: Supabase > Project Settings > Database
# Use o "Session pooler" (porta 6543), não a conexão direta. 

O env ta asim o da API 

# URL pública da API Java (Cloudflare Tunnel) — sem barra no final
API_BASE_URL=http://localhost:8080
#https://simulation-democracy-attempt-karma.trycloudflare.com
SUPABASE_URL= https://eiyfmcjzhqqcrofllsjd.supabase.co
#db.eiyfmcjzhqqcrofllsjd.supabase.co
# chave pública (anon / publishable) — nunca use a service_role aqui
SUPABASE_ANON_KEY=sb_publishable_znaEWRyeirGQyC_E4kNbhg_hbR_s646
PORT=3000
```

O Supabase exige SSL. A URL da API, do jeito que está em `application.properties`, não pede SSL. Se a API subir e a conexão for recusada, troque a linha do datasource para:

```properties
spring.datasource.url=jdbc:postgresql://${DB_HOST}:${DB_PORT}/${DB_DATABASE}?sslmode=require
```

A API usa `ddl-auto=update`: na primeira subida ela cria as tabelas (`profiles`, `attributes`, `tasks`, `missions`, `store`, `item`) se elas ainda não existirem.

Não há endpoint público para criar perfil. O perfil precisa existir no banco antes do app buscar tarefas. O `user_id` é um UUID.

## 2. API Java

Na raiz do projeto:

```bash
./gradlew bootRun
```

No Windows:

```powershell
.\gradlew.bat bootRun
```

A API sobe em `http://localhost:8080`.

A API está conectada por uma URL publica: `https://jelsoft-benefit-season-solomon.trycloudflare.com` 

Para ver se está no ar, abra:

- Swagger: `http://localhost:8080/swagger-ui/index.html`
- OpenAPI: `http://localhost:8080/v3/api-docs`


Uma resposta 200 traz `userId`, `email`, `name`, `avatarUrl`, `level`, `experience`, `gold` e `atributes`. 404 significa que esse perfil não está no banco.

### Endereços

Perfil:

| Método | Caminho | Para quê |
|---|---|---|
| GET | `/profiles/by-user-uuid/{uuid}` | Perfil completo |
| GET | `/profiles/by-user-email/{email}` | O mesmo perfil, pelo e-mail |
| GET | `/profiles/{uuid}/my_tasks` | Tarefas |
| GET | `/profiles/{uuid}/my_missions` | Missões |
| PUT | `/profiles/update/{uuid}` | Atualiza `name` e `avatarUrl` |

Tarefa:

| Método | Caminho | Para quê |
|---|---|---|
| POST | `/tasks/newtask` | Cria |
| POST | `/tasks/complete` | Conclui. Corpo: `{ "taskId": "..." }` |
| PUT | `/tasks/update?taskId=` | Atualiza |
| PUT | `/tasks/complete-cycle/{taskId}` | Fecha o ciclo |
| DELETE | `/tasks/{taskId}` | Remove |

Missão:

| Método | Caminho | Para quê |
|---|---|---|
| POST | `/missions/new` | Cria |
| PUT | `/missions/complete?missionId=` | Conclui |
| PUT | `/missions/update?missionId=` | Atualiza |
| DELETE | `/missions?missionId=` | Remove |

Loja:

| Método | Caminho | Para quê |
|---|---|---|
| GET | `/profiles/{uuid}/mystore` | Loja e itens |
| POST | `/profiles/{uuid}/addItem` | Cria item. Corpo: `{ "name", "value" }` |
| PUT | `/profiles/{profileId}/updateItem/{itemId}` | Atualiza |
| DELETE | `/profiles/{profileId}/deleteItem/{itemId}` | Remove, se ainda não foi comprado |
| PUT | `/profiles/{profileId}/purchaseItem/{itemId}` | Compra com o ouro do perfil |

## 3. Firebase

O repositório já tem `.firebaserc` e a pasta `.firebase`. Esse é o projeto Firebase do app. Quem for rodar precisa de acesso a esse projeto.

```bash
firebase login
firebase projects:list
```

O alias dentro do `.firebaserc` tem que ser um projeto em que essa conta entra. Os arquivos `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) não vão para o Git. Se faltarem, gere de novo na pasta do app:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

O app só usa o Firebase para o que o `main.dart` já inicializa. Perfil, tarefa, missão e loja vêm da API Java, não do Firestore.

## 4. App Flutter

Entre na pasta do app (a que tem `pubspec.yaml` e `lib/`).

```bash
flutter pub get
flutter run
```

O pacote `http` precisa estar no `pubspec.yaml`. Se não estiver:

```bash
flutter pub add http
```

No celular físico, `localhost` é o próprio celular. Use o IP da máquina onde a API está rodando, por exemplo `http://192.168.0.10:8080`. Emulador Android costuma alcançar o computador por `http://10.0.2.2:8080`.

Não coloque `DB_PASSWORD` dentro do app. O app só precisa do endereço da API.

O arquivo que busca os dados é `lib/data/gamify_api.dart`. O `mockup_data.dart` não é mais a fonte. Se alguma tela ainda usar `MockData`, ela continua mostrando João e a faixa verde, sem olhar o banco.

```dart
final api = GamifyApi(baseUrl: 'http://10.0.2.2:8080');

final tela = await api.loadProfileScreen(userId);
final loja = await api.loadStore(userId);
```

`loadProfileScreen` junta três GET: o perfil, `my_tasks` e `my_missions`. A loja é outra chamada.

### Onde fica cada arquivo

| Arquivo | Pasta no app |
|---|---|
| `attribute.dart`, `mission.dart`, `task.dart`, `store_item.dart`, `user_profile.dart`, `profile_resume.dart`, `json_read.dart` | `lib/models/` |
| `gamify_api.dart` | `lib/data/` |

Na tela, o texto é em português. O JSON continua em inglês.

| A pessoa lê | O JSON leva |
|---|---|
| Inteligência | `intelligence` |
| Força | `strength` |
| Espiritualidade | `spirituality` |
| Carisma | `charisma` |
| Percepção Espacial | `spatialPerception` no perfil, `spatial_perception` na tarefa |
| Autoconsciência | `selfAwareness` no perfil, `self_awareness` na tarefa |
| Linguagem | `language` |
| Raciocínio Lógico | `logicalReasoning` no perfil, `logical_reasoning` na tarefa |
| Musicalidade | `musicality` |
| Única, Diária, Semanal, Mensal | `UNIQUE`, `DAILY`, `WEEKLY`, `MONTHLY` |
| Pendente, Concluída | `PENDING`, `COMPLETED` |
| Ativa, Concluída (missão) | `finished` false ou true |
| Segunda … Domingo | `MONDAY` … `SUNDAY` |

Use `atributosEmPortugues`, `frequencyLabel`, `finishedLabel` e `daysOfWeekLabels`. Não escreva a chave inglesa na tela.

## Cuidados que já estão na API

- A chave dos atributos no perfil é `atributes`, com essa grafia. Não "corrija" para `attributes` no app.
- A tarefa pede o atributo na criação (`attributes`), mas o GET da tarefa **não devolve** esse campo.
- Concluir tarefa soma `reward` no ouro e o mesmo `reward` no atributo. O campo `experience` da tarefa é gravado e não é aplicado.
- Concluir missão soma `experience` no perfil e `reward` no ouro. Não mexe no atributo.
- `level` não sobe sozinho quando `experience` aumenta. Não existe `rank` nem `maxXp` na API.
- Em missão, `tasks` é uma tarefa ou `null`, não uma lista.
- Em tarefa, `finished` é o texto `PENDING` ou `COMPLETED`. Em missão, `finished` é booleano.
- Não existe "tarefas de hoje". `loadTasks` devolve todas.
- Item comprado continua na loja, com `purchase_at` preenchido. O POST manda `name`; a resposta devolve `title`.

## Ordem para subir

1. Confira o `.env` com o host do Supabase.
2. Suba a API (`./gradlew bootRun`) e abra o Swagger.
3. Confira um perfil real com o `curl` acima.
4. Aponte o `GamifyApi` para essa URL.
5. Rode o Flutter (`flutter build web`& `flutter run`). (Se quiser subir só para o Flutter `flutter run -d chrome`)  
  
## Link's de outras documentações 
[Sistemas de comentarios](./sistema-de-comentarios.md)


[GOOGLE](./LEIA_ME_GOOGLE_API.md)


[Supabase](./LEIA_ME_SUPABASE.md)


[Deploy](./dar_deploy.md)