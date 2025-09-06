FROM dart:3.9

WORKDIR /app

# Copiar pubspec para instalar dependencias
COPY pubspec.* /app/

RUN dart pub get

# Copiar todo el código
COPY . /app/

# Compilar tu proyecto (ajusta según tu entrypoint)
RUN dart compile exe bin/proyecto_web.dart -o bin/proyecto_web.exe

# Comando por defecto
CMD ["./bin/proyecto_web.exe"]
