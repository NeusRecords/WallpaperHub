# 🖼️ WallpaperHub - Premium Wallpaper App

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/sqlite-%2307405e.svg?style=for-the-badge&logo=sqlite&logoColor=white)
![Google Fonts](https://img.shields.io/badge/Google%20Fonts-4285F4?style=for-the-badge&logo=google&logoColor=white)

**WallpaperHub** es una aplicación moderna y elegante desarrollada en Flutter que permite a los usuarios explorar, descargar y configurar fondos de pantalla de alta resolución de forma sencilla y rápida.

---

## ✨ Características Principales

*   **🔍 Búsqueda Inteligente**: Encuentra exactamente lo que buscas con nuestro motor de búsqueda integrado.
*   **📁 Categorías Dinámicas**: Navega a través de colecciones curadas como Naturaleza, Arquitectura, Tecnología y más.
*   **❤️ Favoritos**: Guarda tus fondos preferidos localmente para acceder a ellos en cualquier momento, incluso sin conexión.
*   **⬇️ Descarga en Alta Calidad**: Guarda las imágenes directamente en tu galería con optimización automática.
*   **🖼️ Configuración Directa**: Cambia tu fondo de pantalla (Inicio, Bloqueo o Ambos) con un solo toque sin salir de la app.
*   **🔄 Cambio Automático**: Función de servicio en segundo plano para rotar tus fondos de pantalla favoritos periódicamente.
*   **📱 Diseño Responsivo**: Interfaz minimalista y fluida con cuadrículas personalizadas (Staggered Grid).

---

## 📸 Demo & Screenshots

> [!TIP]
> Puedes añadir tus propias capturas de pantalla en la carpeta `assets/screenshots/` y enlazarlas aquí.

| Pantalla de Inicio | Categorías | Vista Previa |
| :---: | :---: | :---: |
| ![Home](https://via.placeholder.com/200x400?text=Home+Screen) | ![Categories](https://via.placeholder.com/200x400?text=Categories) | ![Preview](https://via.placeholder.com/200x400?text=Wallpaper+Preview) |

---

## 🛠️ Stack Tecnológico

*   **Framework**: [Flutter](https://flutter.dev)
*   **Lenguaje**: [Dart](https://dart.dev)
*   **Gestión de Estado**: `Provider`
*   **Base de Datos**: `SQLite` (via `sqflite`) para favoritos.
*   **Imágenes**: `CachedNetworkImage` para una carga fluida y ahorro de datos.
*   **Fuentes**: `Google Fonts (Outfit / Roboto)`
*   **API**: Conexión con [Pexels API](https://www.pexels.com/api/) para contenido dinámico.

---

## 🚀 Instalación y Uso

Sigue estos pasos para ejecutar el proyecto localmente:

1.  **Clona el repositorio**:
    ```bash
    git clone https://github.com/NeusRecords/WallpaperHub.git
    ```

2.  **Entra a la carpeta del proyecto**:
    ```bash
    cd wallpaper_app
    ```

3.  **Instala las dependencias**:
    ```bash
    flutter pub get
    ```

4.  **Configura tu API Key**:
    *   Regístrate en [Pexels API](https://www.pexels.com/api/).
    *   Busca el archivo de configuración de API en `lib/data/data.dart` (o donde se encuentre la constante) y pega tu llave.

5.  **Ejecuta la aplicación**:
    ```bash
    flutter run
    ```

---

## 📄 Licencia

Este proyecto está bajo la licencia **MIT**. Consulta el archivo [LICENSE](LICENSE) para más detalles.

---

## 🤝 Contribuciones

¡Las contribuciones son bienvenidas! Si tienes ideas para mejorar la app, no dudes en abrir un *issue* o enviar un *pull request*.

1.  Haz un Fork del proyecto.
2.  Crea tu rama de características (`git checkout -b feature/AmazingFeature`).
3.  Haz un Commit de tus cambios (`git commit -m 'Add some AmazingFeature'`).
4.  Haz un Push a la rama (`git push origin feature/AmazingFeature`).
5.  Abre un Pull Request.

---

Desarrollado con ❤️ por **[NeusRecords](https://github.com/NeusRecords)**
