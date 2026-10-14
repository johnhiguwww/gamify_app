# Login e Registro com Supabase — o que fazer

## 1. Adicione a dependência no `pubspec.yaml`
Dentro de `dependencies:`, adicione:

```yaml
dependencies:
  flutter:
    sdk: flutter
  supabase_flutter: ^2.8.0
```

Depois rode:
```
flutter pub get
```

## 2. Rode o SQL no Supabase
Abra seu projeto em supabase.com → **SQL Editor** → cole e rode o conteúdo do arquivo
`supabase_schema.sql` (incluso neste pacote). Isso cria a tabela `profiles`
com as permissões corretas (cada usuário só vê/edita o próprio perfil).

## 3. Coloque sua URL e chave anônima
Abra `lib/services/supabase_service.dart` e troque:

```dart
static const String supabaseUrl = 'https://eiyfmcjzhqqcrofllsjd.supabase.co';
static const String supabaseAnonKey = 'sb_publishable_znaEWRyeirGQyC_E4kNbhg_hbR_s646';
```

Esses valores estão em: **Project Settings → API** no painel do Supabase.

## 4. Confirmação de email
Por padrão o Supabase exige confirmação de email antes do primeiro login.
Pra testar mais rápido enquanto desenvolve, em **Authentication → Providers → Email**,
você pode desativar "Confirm email" temporariamente.

## 5. Copie a pasta lib/ pro seu projeto
Substitua a `lib/` do seu projeto pela deste pacote (`lib_organizada_login.zip`),
rode `flutter pub get` e depois `flutter run`.

## O que foi implementado
- **AuthGate** (`lib/screens/auth/auth_gate.dart`): tela inicial do app agora.
  Sem sessão → mostra Login. Com sessão → carrega o perfil do Supabase e
  mostra o Dashboard (RootShell) direto, como você pediu.
- **LoginScreen**: email + senha.
- **RegisterScreen**: nome completo, apelido, email e senha. O apelido vira
  o nome exibido no Dashboard/Perfil.
- **AuthService**: signUp, signIn, signOut, fetchProfile.
- **CurrentUser**: guarda o perfil logado; Dashboard e Perfil agora leem daqui
  (com fallback pro MockData.user só se algo vier nulo, pra nunca quebrar a tela).
- Botão **Sair** na tela de Perfil.

## Sobre o avatar
Por enquanto o "avatar" é só o campo `avatar_url` (texto) na tabela — as telas
continuam mostrando a inicial do apelido dentro de um círculo, como já era no
mock. Se você quiser upload de imagem de verdade (Supabase Storage), é um
próximo passo separado — me avisa que eu implemento.
