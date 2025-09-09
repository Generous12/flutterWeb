# Etapa 1: Build
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copiar solo pubspec para cache de dependencias
COPY pubspec.* /app/
RUN flutter pub get

# Copiar todo el código
COPY . /app/

# Construir la web en modo release
RUN flutter build web --release -t lib/main.dart

# Etapa 2: Servir los archivos construidos con un servidor ligero (nginx)
FROM nginx:alpine

# Copiar los archivos web build al directorio de nginx
COPY --from=build /app/build/web /usr/share/nginx/html

# Exponer el puerto
EXPOSE 80

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]
