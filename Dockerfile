# Usa una imagen con Flutter y Dart preinstalados
FROM ghcr.io/cirruslabs/flutter:stable

WORKDIR /app

# Copiar pubspec para instalar dependencias
COPY pubspec.* /app/

# Instalar dependencias usando Flutter
RUN flutter pub get

# Copiar todo el código
COPY . /app/

# Construir tu proyecto web
RUN flutter build web --release -t lib/main.dart

# Servir con un servidor web simple
CMD ["flutter", "run", "-d", "web-server", "--web-port", "8080", "--web-hostname", "0.0.0.0"]
