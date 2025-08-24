 FoodMach 

Proyecto de título 
Sistema web inclusivo que recomienda menús seguros según condiciones de salud y preferencias alimentarias.

Esta primera versión incluye:
- Controladores principales en `app/Http/Controllers/`
- Archivo .env.example plantilla 


tecnologias
- Laravel 12 (estructura base)
- PHP 8.2
- MySQL 8

## 🚀 Cómo usar este repo
1. Clonar el repositorio:
   ```bash
   git clone https://github.com/TUUSUARIO/foodmach
   cd foodmach
Instalar dependencias (cuando esté integrado con Laravel real):

composer install


Copiar archivo de entorno:

cp .env.example .env


Generar clave de aplicación:

php artisan key:generate

para  .env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=foodmach
DB_USERNAME=root
DB_PASSWORD=

