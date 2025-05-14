
# 📱 Central de Atendimento UTFPR

Aplicativo Flutter que permite que membros da UTFPR (alunos, professores, técnicos) registrem solicitações e denúncias com foto, localização automática e comentários. As solicitações são públicas, com autenticação por e-mail e senha via Firebase.

**POR FAVOR ACESSAR DEMO NO LINK: https://www.youtube.com/watch?v=PxLuB85PQrc&ab_channel=vagnerconhariki**

---

## ✅ Funcionalidades

- Cadastro e login de usuários via Firebase Authentication
- Criação de solicitações com:
  - Título e descrição
  - Foto tirada com a câmera (salva como base64 no Firestore)
  - Localização geográfica automática
- Lista pública com todas as solicitações
- Edição e exclusão de solicitações (pelo criador)
- Comentários em cada solicitação
- Firebase Firestore como banco de dados em nuvem

---

## 🚀 Como rodar o projeto localmente

### 🔹 1. Instalar o Flutter

- Acesse: [https://docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
- Baixe o SDK e siga o passo a passo para seu sistema (Windows, macOS, Linux)

Após instalar:

```bash
flutter doctor 
```
### 🔹 2. Instalar um Editor de Código

**Recomendado:**
-   **Android Studio**
    
    -   Instale os plugins **Flutter** e **Dart** via _Settings > Plugins_
        
    -   Configure um dispositivo virtual Android (emulador)
       
**OU**

-   **Visual Studio Code**
    
    -   Instale as extensões **Flutter** e **Dart**

### 🔹 3. Clonar o Projeto

```bash
git clone https://github.com/VConhariki/central_atendimento_utf.git
```
```bash
cd central_atendimento_utf
```
```bash
flutter pub get
```
### 🔹 4. Verificar Dependências

No seu `pubspec.yaml`, certifique-se de ter:

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.13.0
  firebase_auth: ^5.5.3
  cloud_firestore: ^5.6.7
  image_picker: ^1.0.7
  geolocator: ^14.0.0
  provider: ^6.1.2
  path_provider: ^2.1.2
  cupertino_icons: ^1.0.8
  firebase_app_check: ^0.3.2+5
  flutter_image_compress: ^2.4.0
  flutter_screenutil: ^5.9.3
```

Depois:

```bash
flutter pub get
```

### 🔹 5. Rodar o App

1.  Conecte um dispositivo Android ou inicie um emulador
    
2.  Execute:
    
```bash
flutter run
```
3. Garanta as seguintes versões instaladas:
	 - Flutter: 3.29.3
	 - Dart: 3.7.2
	 - DevTools: 2.42.3
	 - SDK: 23
	 - NDK: 27.0.12077973
	 - JAVA: 11 ou maior

### 🔹 6. Facilitando os testes

Para testar mais facilmente faça login com usuário: vagner.conhariki@gmail.com e senha: 123456


## ℹ️ Informações Técnicas

### 📷 Imagens

-   As imagens são capturadas com a câmera
-   Convertidas em **base64** e armazenadas no Firestore (sem Firebase Storage)
-   O campo `imagem_base64` é salvo como string

### 📍 Geolocalização

-   O app pede permissão para obter localização
-   Latitude e longitude são salvos automaticamente junto à solicitação