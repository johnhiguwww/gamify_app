# Login com Google + API Java — o que fazer

## Resumo da arquitetura
- **Supabase**: só cuida do login (Google). Não guarda mais perfil/gamificação.
- **API Java (Spring Boot)**: guarda perfil, tarefas e missões, com PostgreSQL.
- O Flutter, ao logar com Google, pega o `userId` do Supabase e usa ele pra
  buscar (ou criar, na primeira vez) o perfil na API Java.

---

## PARTE 1 — Configurar o login com Google no Supabase

### 1.1 Crie as credenciais OAuth no Google Cloud
1. Acesse console.cloud.google.com e crie um projeto (ou use um existente).
2. Vá em **APIs & Services → Credentials → Create Credentials → OAuth client ID**.
3. Tipo de aplicativo: **Web application**.
4. Em **Authorized redirect URIs**, adicione a URL de callback do Supabase.
   Ela tem esse formato (troque pelo seu Project URL):
   ```
   https://eiyfmcjzhqqcrofllsjd.supabase.co/auth/v1/callback
   ```
5. Salve e copie o **Client ID** e o **Client Secret**.

### 1.2 Ative o provedor Google no Supabase
1. No painel do Supabase → **Authentication → Providers → Google**.
2. Ative o toggle.
3. Cole o **Client ID** e o **Client Secret** que você copiou.
4. Salve.

### 1.3 Confirme a Site URL
Em **Authentication → URL Configuration**, confirme que `Site URL` e
`Redirect URLs` já apontam pro seu site publicado
(ex: `https://gamify-app-ce12f.web.app`) — você já configurou isso antes.

---

## PARTE 2 — Hospedar a API Java de graça

### Opção recomendada: Render + Postgres do próprio Supabase
Você não precisa de um banco novo — pode reaproveitar o Postgres que já vem
com seu projeto Supabase.

1. No Supabase, vá em **Project Settings → Database** e copie os dados de
   conexão (host, porta, nome do banco, usuário, senha) — prefira o modo
   **Session pooler** (porta 6543) pra evitar limite de conexões.
2. Suba o código da API Java (a pasta `gamify-api` deste pacote) num
   repositório no GitHub.
3. Crie uma conta gratuita em render.com.
4. **New → Web Service**, conecte o repositório.
5. Configure:
   - Runtime: Docker ou Gradle (Render detecta automaticamente projetos
     Spring Boot com Gradle)
   - Build Command: `./gradlew build -x test`
   - Start Command: `java -jar build/libs/*.jar`
6. Em **Environment Variables**, adicione (com os valores do passo 1):
   ```
   DB_HOST=...
   DB_PORT=6543
   DB_DATABASE=postgres
   DB_USER=...
   DB_PASSWORD=...
   ```
7. Deploy. No final, o Render te dá uma URL pública, tipo:
   ```
   https://gamify-api.onrender.com
   ```

> ⚠️ No plano free do Render, a API "dorme" depois de alguns minutos sem uso
> e demora ~30s pra responder na primeira chamada depois disso. É normal.

### Antes de subir: ajuste o CORS
Abra `src/main/java/com/example/gamify/config/CorsConfig.java` e confirme
que a URL do seu site publicado está na lista de `allowedOrigins`.

---

## PARTE 3 — Configurar o Flutter

### 3.1 Dependências no pubspec.yaml
```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
  http: ^1.2.2
  cupertino_icons: ^1.0.8
```
Depois rode `flutter pub get`.

### 3.2 Aponte pra sua API
Abra `lib/services/gamify_api_service.dart` e troque:
```dart
static const String baseUrl = 'https://SUA_API_AQUI.onrender.com';
```
pela URL real que o Render te deu.

### 3.3 Confirme a URL/chave do Supabase
`lib/services/supabase_service.dart` já deve estar com seus valores reais
(URL + Publishable key), do que fizemos antes.

### 3.4 Rebuild e redeploy
```
flutter build web
firebase deploy
```

---

## O que já está pronto no código
- **LoginScreen**: um único botão "Continuar com Google".
- **AuthGate**: detecta login → busca o perfil na API Java pelo `userId` →
  se não existir, cria automaticamente com nome/foto do Google → mostra o
  Dashboard.
- **GamifyApiService**: `fetchProfile`, `createOrGetProfile`, `fetchTasks`.
- **UserProfile.fromApi**: converte o JSON da API Java (`level`,
  `experience`, `gold`, etc.) pro formato que o Dashboard já usa.
- **API Java**: novo endpoint `POST /profiles/new` (cria ou devolve o
  perfil existente, sem duplicar) + CORS liberado para o seu site.

## O que ainda falta (próximos passos, se quiser)
- Conectar as telas de **Missões** e **Tarefas** na API (`fetchTasks` já
  existe no serviço, mas as telas ainda usam `MockData`).
- Endpoints de criar tarefa/missão já existem na API (`POST /tasks/newtask`,
  `POST /missions/new`) — só falta chamar eles do Flutter nas telas de
  "nova tarefa" e "nova missão".

Me chama quando quiser seguir com isso.


  static const String supabaseUrl = 'https://eiyfmcjzhqqcrofllsjd.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_znaEWRyeirGQyC_E4kNbhg_hbR_s646';