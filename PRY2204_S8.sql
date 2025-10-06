
-- Eliminación previa (para evitar errores de duplicados)
drop table detalle_venta cascade constraints;
drop table venta cascade constraints;
drop table medio_pago cascade constraints;
drop table vendedor cascade constraints;
drop table administrativo cascade constraints;
drop table empleado cascade constraints;
drop table salud cascade constraints;
drop table afp cascade constraints;
drop table producto cascade constraints;
drop table marca cascade constraints;
drop table categoria cascade constraints;
drop table proveedor cascade constraints;
drop table comuna cascade constraints;
drop table region cascade constraints;

-- Creación de tablas ESTEBAN IGNACIO GARAY DIAZ

create table region (
    id_region number(4) constraint region_pk primary key, 
    nom_region varchar2(255) not null
); 

create table comuna (
    id_comuna number(4) constraint comuna_pk primary key, 
    nom_comuna varchar2(100) not null, 
    cod_region number(4) not null, 
    constraint fk_comuna_region foreign key (cod_region) references region (id_region)
); 

create table proveedor (
    id_proveedor number(5) constraint proveedor_pk primary key, 
    nombre_proveedor varchar2(150) not null, 
    rut_proveedor varchar2(10) not null, 
    telefono varchar2(10) not null, 
    email varchar2(200) not null, 
    direccion varchar2(200) not null, 
    cod_comuna number(4) not null, 
    constraint fk_proveedor_comuna foreign key (cod_comuna) references comuna (id_comuna)
); 

create table categoria (
    id_categoria number(3) constraint categoria_pk primary key, 
    nombre_categoria varchar2(255) not null
);

create table marca (
    id_marca number(3) constraint marca_pk primary key, 
    nombre_marca varchar2(25) not null
);

create table producto (
    id_producto number(4) constraint producto_pk primary key, 
    nombre_producto varchar2(100) not null, 
    precio_unitario number not null, 
    origen_nacional char(1) not null, 
    stock_minimo number(3) not null, 
    activo char(1) not null, 
    cod_marca number(3) not null, 
    cod_categoria number(3) not null, 
    cod_proveedor number(5) not null, 
    constraint fk_producto_marca foreign key (cod_marca) references marca (id_marca),
    constraint fk_producto_categoria foreign key (cod_categoria) references categoria (id_categoria),
    constraint fk_producto_proveedor foreign key (cod_proveedor) references proveedor (id_proveedor)
); 

create table afp (
    id_afp number generated always as identity 
        (start with 210 increment by 6) constraint afp_pk primary key, 
    nom_afp varchar2(255) not null
);

create table salud (
    id_salud number(4) constraint salud_pk primary key, 
    nom_salud varchar2(40) not null
); 

create table empleado(  
    id_empleado number(4) constraint empleado_pk primary key, 
    rut_empleado varchar2(10) not null, 
    nombre_empleado varchar2(25) not null, 
    apellido_paterno varchar2(25) not null, 
    apellido_materno varchar2(25) not null, 
    fecha_contratacion date not null, 
    sueldo_base number(10) not null, 
    bono_jefatura number(10),
    activo char(1) not null,
    tipo_empleado varchar2(25) not null,
    id_jefe number(4),
    cod_salud number(4) not null, 
    cod_afp number(5) not null, 
    constraint fk_empleado_salud foreign key (cod_salud) references salud (id_salud), 
    constraint fk_empleado_afp foreign key (cod_afp) references afp (id_afp), 
    constraint fk_empleado_jefe foreign key (id_jefe) references empleado(id_empleado)
); 

create table administrativo (
    id_empleado number(4) constraint administrativo_pk primary key, 
    constraint fk_administrativo_empleado foreign key (id_empleado) references empleado(id_empleado)
);

create table vendedor (
    id_empleado number(4) constraint vendedor_pk primary key, 
    comision_venta number(5,2) not null,
    constraint fk_vendedor_empleado foreign key (id_empleado) references empleado (id_empleado)
);

create table medio_pago (
    id_mpago number(3) constraint medio_pago_pk primary key, 
    nombre_mpago varchar2(50) not null
); 

create table venta (
    id_venta number generated always as identity 
        (start with 5050 increment by 3) constraint venta_pk primary key, 
    fecha_venta date not null, 
    total_venta number(10) not null, 
    cod_mpago number(3) not null, 
    cod_empleado number(4) not null, 
    constraint fk_venta_empleado foreign key (cod_empleado) references empleado (id_empleado),
    constraint fk_venta_pago foreign key (cod_mpago) references medio_pago (id_mpago)
); 

create table detalle_venta (
    cod_venta number(4) not null, 
    cod_producto number(4) not null, 
    cantidad number(6) not null,
    constraint detalle_venta_pk primary key (cod_venta, cod_producto),
    constraint fk_det_vent_venta foreign key (cod_venta) references venta (id_venta), 
    constraint fk_det_vent_producto foreign key (cod_producto) references producto (id_producto)
);

--modificación del modelo
ALTER TABLE empleado
ADD CONSTRAINT CK_sueldo_min CHECK (sueldo_base >= 400000);

ALTER TABLE vendedor
ADD CONSTRAINT CK_comision CHECK (comision_venta >= 0 AND comision_venta <= 0.25);

ALTER TABLE producto
ADD CONSTRAINT CK_stock_min CHECK (stock_minimo >= 3);

ALTER TABLE proveedor
ADD CONSTRAINT U_email UNIQUE (email);

ALTER TABLE marca
ADD CONSTRAINT U_nombre_marca UNIQUE (nombre_marca);

ALTER TABLE detalle_venta
ADD CONSTRAINT CK_cantidad CHECK (cantidad > 0);

 
-- Secuencia para SALUD (desde 2050, incrementos de 10)
CREATE SEQUENCE seq_salud
START WITH 2050
INCREMENT BY 10;

DROP SEQUENCE seq_salud;
DROP SEQUENCE seq_empleado;

-- Secuencia para EMPLEADO (desde 750, incrementos de 3)
CREATE SEQUENCE seq_empleado
START WITH 750
INCREMENT BY 3;

--poblamiento de tablas 

insert into salud (id_salud,nom_salud) values (seq_salud.NEXTVAL,'Fonasa');
insert into salud (id_salud,nom_salud) values (seq_salud.NEXTVAL,'Isapre Colmena');
insert into salud (id_salud,nom_salud) values (seq_salud.NEXTVAL,'Isapre Banmedica');
insert into salud (id_salud,nom_salud) values (seq_salud.NEXTVAL,'Cruz Blanca');

INSERT INTO afp (nom_afp) VALUES ('AFP Habitat');
INSERT INTO afp (nom_afp) VALUES ('AFP Cuprum');
INSERT INTO afp (nom_afp) VALUES ('AFP Provida');
INSERT INTO afp (nom_afp) VALUES ('AFP PlanVital');

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (750, '11111111-1', 'Marcela', 'González', 'Pérez', TO_DATE('15-03-2022','DD-MM-YYYY'), 950000, 80000, 'S', 'Administrativo', NULL, 2050, 210);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (753, '22222222-2', 'José', 'Muñoz', 'Ramírez', TO_DATE('10-07-2021','DD-MM-YYYY'), 900000, 75000, 'S', 'Administrativo', NULL, 2060, 216);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (756, '33333333-3', 'Verónica', 'Soto', 'Alarcón', TO_DATE('05-01-2020','DD-MM-YYYY'), 880000, 70000, 'S', 'Vendedor', 750, 2060, 228);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (759, '44444444-4', 'Luis', 'Reyes', 'Fuentes', TO_DATE('01-04-2023','DD-MM-YYYY'), 560000, NULL, 'S', 'Vendedor', 750, 2070, 228);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (762, '55555555-5', 'Claudia', 'Fernández', 'Lagos', TO_DATE('15-04-2023','DD-MM-YYYY'), 600000, NULL, 'S', 'Vendedor', 753, 2070, 216);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (765, '66666666-6', 'Carlos', 'Navarro', 'Vega', TO_DATE('01-05-2023','DD-MM-YYYY'), 610000, NULL, 'S', 'Administrativo', 753, 2060, 210);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (768, '77777777-7', 'Javiera', 'Pino', 'Rojas', TO_DATE('10-05-2023','DD-MM-YYYY'), 650000, NULL, 'S', 'Administrativo', 750, 2050, 210);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (771, '88888888-8', 'Diego', 'Mella', 'Contreras', TO_DATE('12-05-2023','DD-MM-YYYY'), 620000, NULL, 'S', 'Vendedor', 750, 2060, 216);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (774, '99999999-9', 'Fernanda', 'Salas', 'Herrera', TO_DATE('18-05-2023','DD-MM-YYYY'), 570000, NULL, 'S', 'Vendedor', 753, 2070, 228);

INSERT INTO empleado (id_empleado, rut_empleado, nombre_empleado, apellido_paterno, apellido_materno, fecha_contratacion, sueldo_base, bono_jefatura, activo, tipo_empleado, id_jefe, cod_salud, cod_afp)
VALUES (777, '10101010-0', 'Tomás', 'Vidal', 'Espinoza', TO_DATE('01-06-2023','DD-MM-YYYY'), 530000, NULL, 'S', 'Vendedor', NULL, 2050, 222);



insert into medio_pago (id_mpago,nombre_mpago) values (11,'efectivo');
insert into medio_pago (id_mpago,nombre_mpago) values (12,'tarjeta debito ');
insert into medio_pago (id_mpago,nombre_mpago) values (13,'tarjeta credito');
insert into medio_pago (id_mpago,nombre_mpago) values (14,'cheque');

INSERT INTO venta (fecha_venta, total_venta, cod_mpago, cod_empleado)
VALUES (TO_DATE('2023-05-12','YYYY-MM-DD'), 225990, 12, 771);
INSERT INTO venta (fecha_venta, total_venta, cod_mpago, cod_empleado)
VALUES (TO_DATE('2023-10-23','YYYY-MM-DD'), 524990, 13, 777);
INSERT INTO venta (fecha_venta, total_venta, cod_mpago, cod_empleado)
VALUES (TO_DATE('2023-02-17','YYYY-MM-DD'), 466990, 11, 759);

INSERT INTO region (id_region,nom_region) values (1, 'region metropolitana'); 
INSERT INTO region (id_region,nom_region) values (2, 'Valparaiso');
INSERT INTO region (id_region,nom_region) values (3, 'BioBio');
INSERT INTO region (id_region,nom_region) values (4, 'Los Lagos');


--informe 1

SELECT 
id_empleado AS "IDENTIFICADOR", 
nombre_empleado || ' ' || apellido_paterno || ' ' apellido_materno AS "NOMBRE COMPLETO", 
sueldo_base AS "SALARIO",
bono_jefatura AS "BONIFICACION", 
(sueldo_base + bono_jefatura) AS "SALARIO SIMULADO"
FROM 
empleado
WHERE
activo = 'S' AND bono_jefatura IS NOT NULL
ORDER BY 
(sueldo_base + bono_jefatura) DESC,
apellido_paterno DESC; 


informe 2 

select * from empleado;

SELECT
    nombre_empleado || ' ' || apellido_paterno || ' ' || apellido_materno AS "EMPLEADO",
    sueldo_base AS "SUELDO",
    (sueldo_base * 0.08) AS "POSIBLE AUMENTO",
    (sueldo_base + (sueldo_base * 0.08)) AS "SALARIO SIMULADO"
FROM
    empleado
WHERE
    sueldo_base BETWEEN 550000 AND 800000
ORDER BY
    sueldo_base ASC;

--ESTEBAN IGNACIO GARAY DIAZ
    


