




CREATE DATABASE IF NOT EXISTS menu2
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE menu2;


CREATE TABLE IF NOT EXISTS usuarios (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre   VARCHAR(100) NOT NULL,
  email    VARCHAR(100) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  rol ENUM('usuario','admin') NOT NULL DEFAULT 'usuario',
  creado_en TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- admin@admin.com / admin123
-- cliente@cliente.com / usuario123
INSERT IGNORE INTO usuarios (nombre, email, password, rol) VALUES
('admin',   'admin@admin.com',   '$2b$12$G/BskPj9DNBIf9zU/hK/zezqApx3S4e5lW4F48bkGSOOa8/cQMx7u', 'admin'),
('cliente', 'cliente@cliente.com','$2b$12$WW/J2FgaBgKPWnmlQ9ZAKewkEAAuPaZAA7UWsedQwc1nVTT30zhV6', 'usuario');


CREATE TABLE IF NOT EXISTS enfermedades (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO enfermedades (nombre) VALUES
('celiaco'), ('hipertenso'), ('diabetico'),
('intolerante a la lactosa'), ('sin condiciones'), ('cardiaco');

CREATE TABLE IF NOT EXISTS preferencias (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(50) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO preferencias (nombre) VALUES
('vegano'), ('vegetariano'), ('sin restricciones'), ('celiaco');

CREATE TABLE IF NOT EXISTS alimentos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  descripcion VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO alimentos (descripcion) VALUES
('alto en proteínas'), ('bajo en grasa'), ('alto en grasa'),
('bajo en azúcar'), ('bajo en sodio');


CREATE TABLE IF NOT EXISTS restaurantes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  direccion TEXT NOT NULL,
  tipo VARCHAR(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS menus (
  id INT AUTO_INCREMENT PRIMARY KEY,
  restaurante_id INT NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  caracteristicas TEXT,
  FOREIGN KEY (restaurante_id) REFERENCES restaurantes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT IGNORE INTO restaurantes (nombre, direccion, tipo) VALUES
('Restaurante Verde Vida','Av. Salud 123','vegano celiaco sin lactosa'),
('Delicias Light','Calle Bienestar 456','hipertenso bajo en sodio'),
('Veggie Place','Pasaje Natural 789','vegetariano sin gluten'),
('Energy Foods','Ruta Proteica 321','alto en proteínas sin restricciones'),
('SweetBalance','Diagonal Dulce 222','diabetico bajo en azúcar'),

('Personalizados','N/A','virtual'),

('Casa Vegana','Av. Verde 100','vegano sin gluten sin lactosa'),
('Sabor Sin Gluten','Av. Trigo 0 (libre)','celiaco sin gluten'),
('Vital Fit','Av. Cardio 200','cardiaco bajo en grasa');


INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Ensalada Superverde','Espinaca, palta, quinoa, semillas',
       'vegano, celiaco, sin lactosa, bajo en grasa'
FROM restaurantes r WHERE r.nombre='Restaurante Verde Vida';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Wrap Vegano','Tortilla de arroz, hummus, vegetales',
       'vegano, sin gluten, sin lactosa, alto en fibra'
FROM restaurantes r WHERE r.nombre='Restaurante Verde Vida';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Pollo al vapor','Pechuga con verduras cocidas',
       'bajo en sodio, bajo en grasa'
FROM restaurantes r WHERE r.nombre='Delicias Light';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Ensalada de garbanzos','Garbanzos, tomate, pepino, sin sal',
       'hipertenso, bajo en sodio, veg-friendly'
FROM restaurantes r WHERE r.nombre='Delicias Light';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Tortilla de verduras','Huevos, zanahoria, espinaca',
       'vegetariano, alto en proteínas'
FROM restaurantes r WHERE r.nombre='Veggie Place';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Lentejas con arroz integral','Sin gluten, alto en hierro',
       'vegetariano, sin gluten'
FROM restaurantes r WHERE r.nombre='Veggie Place';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Tazón proteico','Pollo, quinoa, brócoli',
       'alto en proteínas'
FROM restaurantes r WHERE r.nombre='Energy Foods';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Omelette de claras','Claras de huevo, espinaca',
       'bajo en grasa, alto en proteínas, vegetariano'
FROM restaurantes r WHERE r.nombre='Energy Foods';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Postre sin azúcar','Gelatina light con frutas',
       'diabetico, bajo en azúcar, sin lactosa'
FROM restaurantes r WHERE r.nombre='SweetBalance';

INSERT IGNORE INTO menus (restaurante_id, nombre, descripcion, caracteristicas)
SELECT r.id,'Batido de avena','Avena, leche vegetal, canela',
       'bajo en azúcar, sin lactosa, alto en fibra'
FROM restaurantes r WHERE r.nombre='SweetBalance';


INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Bowl de tempeh y quinoa',
       'Tempeh salteado, quinoa, espinaca fresca.',
       'vegano, sin gluten, sin lactosa, alto en proteínas'
FROM restaurantes r WHERE r.nombre='Casa Vegana';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Tofu salteado con verduras',
       'Tofu firme con brócoli y espinaca al wok.',
       'vegano, bajo en grasa, sin lactosa, sin gluten'
FROM restaurantes r WHERE r.nombre='Casa Vegana';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Pizza sin gluten de coliflor',
       'Base de coliflor y harina de arroz, salsa de tomate y queso vegano.',
       'vegetariano, celiaco, sin gluten, sin lactosa'
FROM restaurantes r WHERE r.nombre='Sabor Sin Gluten';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Panqueques de avena y stevia',
       'Panqueques con avena, leche vegetal y stevia.',
       'diabetico, bajo en azúcar, sin lactosa'
FROM restaurantes r WHERE r.nombre='SweetBalance';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Yogur vegetal con frutos rojos',
       'Vaso de yogur vegetal y frutos rojos con stevia.',
       'diabetico, bajo en azúcar, sin lactosa'
FROM restaurantes r WHERE r.nombre='SweetBalance';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Wrap de pollo en tortilla de maíz',
       'Pollo grill, espinaca y tomate en tortilla de maíz.',
       'hipertenso, bajo en sodio, sin gluten'
FROM restaurantes r WHERE r.nombre='Delicias Light';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Ensalada mediterránea baja en sodio',
       'Quinoa, espinaca, tomate y pepino con aceite de oliva.',
       'hipertenso, bajo en sodio, sin gluten, sin lactosa'
FROM restaurantes r WHERE r.nombre='Delicias Light';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Sopa de verduras ligera',
       'Coliflor, brócoli, espinaca y tomate en caldo ligero.',
       'cardiaco, bajo en grasa, sin gluten, sin lactosa'
FROM restaurantes r WHERE r.nombre='Vital Fit';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Bowl light de arroz integral con brócoli',
       'Arroz integral, brócoli y tofu sellado.',
       'cardiaco, bajo en grasa, vegetariano'
FROM restaurantes r WHERE r.nombre='Vital Fit';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Tofu Power Protein',
       'Tofu a la plancha con quinoa y lentejas.',
       'vegano, alto en proteínas, sin lactosa, sin gluten'
FROM restaurantes r WHERE r.nombre='Energy Foods';

INSERT IGNORE INTO menus (restaurante_id,nombre,descripcion,caracteristicas)
SELECT r.id,'Ensalada proteica de lentejas',
       'Lentejas, espinaca y tomate con limón.',
       'vegetariano, sin gluten, alto en proteínas'
FROM restaurantes r WHERE r.nombre='Veggie Place';


CREATE TABLE IF NOT EXISTS ingredientes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre     VARCHAR(120) NOT NULL UNIQUE,
  categoria  VARCHAR(40)  NOT NULL,     
  calorias   INT          NOT NULL DEFAULT 0,
  proteina   DECIMAL(6,2) NOT NULL DEFAULT 0,
  grasa      DECIMAL(6,2) NOT NULL DEFAULT 0,
  carbo      DECIMAL(6,2) NOT NULL DEFAULT 0,
  azucar     DECIMAL(6,2) NOT NULL DEFAULT 0,
  sodio_mg   INT          NOT NULL DEFAULT 0,
  es_gluten  TINYINT(1)   NOT NULL DEFAULT 0,
  es_lactosa TINYINT(1)   NOT NULL DEFAULT 0,
  es_animal  TINYINT(1)   NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT IGNORE INTO ingredientes(nombre,categoria,calorias,proteina,grasa,carbo,azucar,sodio_mg,es_gluten,es_lactosa,es_animal) VALUES
('Pechuga de pollo','carne',165,31,3.6,0,0,70,0,0,1),
('Tofu firme','legumbre',76,8,4.8,1.9,0.6,7,0,0,0),
('Quinoa cocida','cereal',120,4.4,1.9,21.3,0.9,7,0,0,0),
('Arroz integral cocido','cereal',111,2.6,0.9,23,0.4,5,0,0,0),
('Pasta de trigo cocida','cereal',131,5,1.1,25,0.7,6,1,0,0),
('Lentejas cocidas','legumbre',116,9,0.4,20,1.8,2,0,0,0),
('Brócoli','verdura',34,2.8,0.4,7,1.7,33,0,0,0),
('Espinaca','verdura',23,2.9,0.4,3.6,0.4,79,0,0,0),
('Queso mozzarella','lacteo',280,18,17,3,1,620,0,1,1),
('Leche de vaca','lacteo',60,3.2,3.3,4.8,5,44,0,1,1),
('Leche vegetal','otro',45,1,2.5,4,3,60,0,0,0),
('Avena','cereal',389,17,7,66,1,2,0,0,0),
('Garbanzos cocidos','legumbre',164,9,2.6,27.4,4.8,24,0,0,0),

('Tempeh','legumbre',192,20,11,7,0.5,9,0,0,0),
('Coliflor','verdura',25,1.9,0.3,5,2,30,0,0,0),
('Harina de arroz','cereal',366,6,1,80,0.2,2,0,0,0),
('Harina de almendras','otro',571,21,50,21,4,1,0,0,0),
('Queso vegano','otro',270,2,23,18,0.5,350,0,0,0),
('Tortilla de maíz','cereal',218,5.7,2.9,45,1,5,0,0,0),
('Tomate','verdura',18,0.9,0.2,3.9,2.6,5,0,0,0),
('Pepino','verdura',15,0.7,0.1,3.6,1.7,2,0,0,0),
('Frutos rojos','otro',50,1,0.3,12,7,1,0,0,0),
('Stevia','otro',0,0,0,0,0,0,0,0,0);

CREATE TABLE IF NOT EXISTS menu_ingrediente (
  menu_id INT NOT NULL,
  ingrediente_id INT NOT NULL,
  gramos DECIMAL(7,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (menu_id, ingrediente_id),
  FOREIGN KEY (menu_id) REFERENCES menus(id) ON DELETE CASCADE,
  FOREIGN KEY (ingrediente_id) REFERENCES ingredientes(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Ensalada Superverde' AND i.nombre='Quinoa cocida';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Ensalada Superverde' AND i.nombre='Espinaca';

INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 180 FROM menus m JOIN ingredientes i ON m.nombre='Pollo al vapor' AND i.nombre='Pechuga de pollo';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 100 FROM menus m JOIN ingredientes i ON m.nombre='Pollo al vapor' AND i.nombre='Brócoli';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Pollo al vapor' AND i.nombre='Arroz integral cocido';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 150 FROM menus m JOIN ingredientes i ON m.nombre='Bowl de tempeh y quinoa' AND i.nombre='Quinoa cocida';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Bowl de tempeh y quinoa' AND i.nombre='Tempeh';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 50  FROM menus m JOIN ingredientes i ON m.nombre='Bowl de tempeh y quinoa' AND i.nombre='Espinaca';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 150 FROM menus m JOIN ingredientes i ON m.nombre='Tofu salteado con verduras' AND i.nombre='Tofu firme';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Tofu salteado con verduras' AND i.nombre='Brócoli';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 60  FROM menus m JOIN ingredientes i ON m.nombre='Tofu salteado con verduras' AND i.nombre='Espinaca';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 200 FROM menus m JOIN ingredientes i ON m.nombre='Pizza sin gluten de coliflor' AND i.nombre='Coliflor';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 60  FROM menus m JOIN ingredientes i ON m.nombre='Pizza sin gluten de coliflor' AND i.nombre='Harina de arroz';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 50  FROM menus m JOIN ingredientes i ON m.nombre='Pizza sin gluten de coliflor' AND i.nombre='Queso vegano';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Pizza sin gluten de coliflor' AND i.nombre='Tomate';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Panqueques de avena y stevia' AND i.nombre='Avena';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 150 FROM menus m JOIN ingredientes i ON m.nombre='Panqueques de avena y stevia' AND i.nombre='Leche vegetal';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 40  FROM menus m JOIN ingredientes i ON m.nombre='Panqueques de avena y stevia' AND i.nombre='Harina de almendras';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 2   FROM menus m JOIN ingredientes i ON m.nombre='Panqueques de avena y stevia' AND i.nombre='Stevia';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 200 FROM menus m JOIN ingredientes i ON m.nombre='Yogur vegetal con frutos rojos' AND i.nombre='Leche vegetal';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Yogur vegetal con frutos rojos' AND i.nombre='Frutos rojos';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 1   FROM menus m JOIN ingredientes i ON m.nombre='Yogur vegetal con frutos rojos' AND i.nombre='Stevia';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 140 FROM menus m JOIN ingredientes i ON m.nombre='Wrap de pollo en tortilla de maíz' AND i.nombre='Pechuga de pollo';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 70  FROM menus m JOIN ingredientes i ON m.nombre='Wrap de pollo en tortilla de maíz' AND i.nombre='Tortilla de maíz';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 50  FROM menus m JOIN ingredientes i ON m.nombre='Wrap de pollo en tortilla de maíz' AND i.nombre='Tomate';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 30  FROM menus m JOIN ingredientes i ON m.nombre='Wrap de pollo en tortilla de maíz' AND i.nombre='Espinaca';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Ensalada mediterránea baja en sodio' AND i.nombre='Quinoa cocida';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 100 FROM menus m JOIN ingredientes i ON m.nombre='Ensalada mediterránea baja en sodio' AND i.nombre='Espinaca';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Ensalada mediterránea baja en sodio' AND i.nombre='Tomate';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Ensalada mediterránea baja en sodio' AND i.nombre='Pepino';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 100 FROM menus m JOIN ingredientes i ON m.nombre='Sopa de verduras ligera' AND i.nombre='Coliflor';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Sopa de verduras ligera' AND i.nombre='Brócoli';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 60  FROM menus m JOIN ingredientes i ON m.nombre='Sopa de verduras ligera' AND i.nombre='Espinaca';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 60  FROM menus m JOIN ingredientes i ON m.nombre='Sopa de verduras ligera' AND i.nombre='Tomate';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 150 FROM menus m JOIN ingredientes i ON m.nombre='Bowl light de arroz integral con brócoli' AND i.nombre='Arroz integral cocido';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Bowl light de arroz integral con brócoli' AND i.nombre='Brócoli';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Bowl light de arroz integral con brócoli' AND i.nombre='Tofu firme';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 180 FROM menus m JOIN ingredientes i ON m.nombre='Tofu Power Protein' AND i.nombre='Tofu firme';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 120 FROM menus m JOIN ingredientes i ON m.nombre='Tofu Power Protein' AND i.nombre='Quinoa cocida';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Tofu Power Protein' AND i.nombre='Lentejas cocidas';


INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 180 FROM menus m JOIN ingredientes i ON m.nombre='Ensalada proteica de lentejas' AND i.nombre='Lentejas cocidas';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 80  FROM menus m JOIN ingredientes i ON m.nombre='Ensalada proteica de lentejas' AND i.nombre='Espinaca';
INSERT IGNORE INTO menu_ingrediente (menu_id, ingrediente_id, gramos)
SELECT m.id, i.id, 60  FROM menus m JOIN ingredientes i ON m.nombre='Ensalada proteica de lentejas' AND i.nombre='Tomate';


DROP VIEW IF EXISTS vw_menu_nutricion;
CREATE VIEW vw_menu_nutricion AS
SELECT
  m.id AS menu_id,
  ROUND(SUM(i.calorias * mi.gramos/100))           AS kcal,
  ROUND(SUM(i.proteina * mi.gramos/100), 2)        AS prot_g,
  ROUND(SUM(i.grasa    * mi.gramos/100), 2)        AS grasa_g,
  ROUND(SUM(i.carbo    * mi.gramos/100), 2)        AS carb_g,
  ROUND(SUM(i.azucar   * mi.gramos/100), 2)        AS azucar_g,
  ROUND(SUM(i.sodio_mg * mi.gramos/100))           AS sodio_mg,
  MAX(i.es_gluten)   AS contiene_gluten,
  MAX(i.es_lactosa)  AS contiene_lactosa,
  MAX(i.es_animal)   AS contiene_animal
FROM menus m
JOIN menu_ingrediente mi ON mi.menu_id = m.id
JOIN ingredientes i      ON i.id = mi.ingrediente_id
GROUP BY m.id;


CREATE TABLE IF NOT EXISTS pedidos (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  menu_id INT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  nombre_form      VARCHAR(120) NULL,
  edad_form        INT NULL,
  direccion_form   VARCHAR(255) NULL,
  envio_form       ENUM('sí','no') NULL,
  enfermedad_form  VARCHAR(60) NULL,
  preferencia_form VARCHAR(60) NULL,
  alimento_form    VARCHAR(100) NULL,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
  FOREIGN KEY (menu_id)    REFERENCES menus(id)    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS opiniones (
  id INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT NOT NULL,
  mensaje TEXT NOT NULL,
  fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


SET @cliente_id = (SELECT id FROM usuarios WHERE email='cliente@cliente.com');
SET @menu_demo  = (SELECT id FROM menus WHERE nombre='Ensalada Superverde' LIMIT 1);
INSERT IGNORE INTO pedidos (usuario_id, menu_id, nombre_form, edad_form, direccion_form, envio_form, enfermedad_form, preferencia_form, alimento_form)
VALUES (@cliente_id, @menu_demo, 'Cliente Demo', 30, 'Mi calle 123', 'sí', 'celiaco', 'vegano', 'bajo en sodio');


UPDATE restaurantes
SET nombre   = 'Tu Menú Ideal',
    direccion= 'Compra online en MundoRestorant',
    tipo     = 'virtual'
WHERE nombre = 'Personalizados'
LIMIT 1;


