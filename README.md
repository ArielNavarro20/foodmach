FoodMach 
Proyecto de título 

Esta versión inicial contiene:
- Controladores principales en `app/Http/Controllers/`:
  - `HomeController`
  - `PedidoController`
  - `RecomendarController`
  - `OpinionController`
  - `AdminController`
  - `MenuController`
  - `AuthController`
- Archivo `.env.example` no subi el .env real para guardar informacion confidencial.
- faltaron algunos archivos que no inclui por error o por no estar seguro como podria dejarlo finalmente. 

Tecnologías
- Laravel 12
- PHP 8.2
- MySQL 8

Para Instalar dependencias;

composer install


Copia el archivo de entorno:

cp .env.example .env


Genera la clave de la aplicación:

php artisan key:generate
Configuración de la base de datos

En el archivo .env.example para la conexion a la db subido el script.

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=foodmach
DB_USERNAME=root
DB_PASSWORD=
