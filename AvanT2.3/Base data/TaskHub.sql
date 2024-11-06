create database TaskHub

use TaskHub;

create table areas (
    codigo varchar (5) PRIMARY KEY,
    nombre varchar (30) not null,
    departamento varchar (5) not null,
    foreign key (departamento )references departamento(codigo)
)

create table equipo(
    numero int PRIMARY KEY,
    nombre varchar (30) not null,
    tareasAsignadas int not null,
    areas varchar(5) not null,
    foreign key (areas) references areas (codigo)
)

create table usuario(
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombreUsuario varchar (30) not null unique, 
    contraseña varchar (20) not null,
    empleado int not null,
    rol int not null,
    departamento varchar (5) not null,
    foreign key (empleado) references empleado(numero),
    foreign key (rol) references rol(numero),
    foreign key (departamento) references departamento(codigo)
)

create table usuario_equipo (
    equipo int not null,
    usuario int not null,
    foreign key (equipo) references equipo(numero),
    foreign key (usuario) references usuario (numero)
)

create table rol(
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(30) not null
)

create table empleado (
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(40) not null,
    primerApell varchar(30) not null,
    segundoApell varchar(30),
    dirCalle varchar(40) not null,
    dirNum varchar(10) not null,
    dirColonia varchar(30) not null,
    codigoPostal int not null,
    curp varchar (20) not null,
    rfc varchar (20) not null,
    puesto int not null,
    foreign key (puesto) references puesto(numero)
)

create table puesto (
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar (30) not null,
    departamento varchar(5) not null,
    foreign key (departamento) references departamento(codigo)
)

create table departamento(
    codigo varchar(5) PRIMARY KEY,
    nombre varchar(30) not null unique
)

create table director(
    usuario int not null,
    departamento varchar (5) not null,
    foreign key (usuario) references usuario(numero),
    foreign key (departamento) references departamento(codigo)
)

create table tarea(
    codigo varchar(5) PRIMARY KEY,
    titulo varchar(40) not null,
    descripcion varchar(100) not null,
    tiempoEstimado date not null,
    fechaEntrega date not null,
    tiempoAtrasado int not null,
    tiempoRestante int not null,
    porcetajeAvance varchar(5) not null,
    usuario int,
    equipo int,
    estatus int not null,
    tipo int not null,
    dificultad int not null,
    prioridad int not null,
    foreign key (usuario) references usuario(numero),
    foreign key (equipo) references equipo(numero),
    foreign key (estatus) references estatus(numero),
    foreign key (tipo) references tipo(numero),
    foreign key (dificultad) references dificultad(numero),
    foreign key (prioridad) references prioridad(numero)
)

set FOREIGN_KEY_CHECKS = 0
create table reporte(
    numero int PRIMARY KEY AUTO_INCREMENT,
    titulo varchar(40) not null,
    fechaCreacion date not null,
    descripcion varchar(256) not null,
    usuario int not null,
    tarea varchar(5) not null,
    foreign key (usuario) references usuario(numero),
    foreign key (tarea) references tarea(codigo)
)
drop table `reporte`
create table estatus(
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar (30) not null
)

create table tipo(
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(30) not null
)

create table dificultad(
    numero int PRIMARY KEY AUTO_INCREMENT,
    nombre varchar(30) not null
)

create table prioridad(
    numero int PRIMARY KEY AUTO_INCREMENT,
    tipo varchar(20) not null
)

create table crear_tarea(
    usuario int not null,
    tarea varchar(5) not null,
    foreign key (usuario) references usuario(numero),
    foreign key (tarea) references tarea(codigo)
)

create table subtarea(
    codigo varchar(5) PRIMARY KEY,
    titulo varchar(30) not null,
    descripcion varchar(100) not null,
    tiempoEstimado date not null,
    planificacion varchar(5) not null,
    avance int not null,
    tarea varchar(5) not null,
    foreign key (planificacion) references planificacion(codigo),
    foreign key (avance) references avance(numero),
    foreign key (tarea) references tarea(codigo)
)

create table planificacion(
    codigo varchar(5) PRIMARY KEY,
    fechaInicio date not null,
    fechaLimite date not null,
    comentario varchar(200) not null
)

create table avance (
    numero int PRIMARY KEY AUTO_INCREMENT,
    progreso varchar (10) not null
)

create table tarea_avan (
    tarea varchar(5) not null,
    avance int not null,
    foreign key (avance) references avance(numero),
    foreign key (tarea) references tarea(codigo)
)

create table usuario_plan (
    usuario int not null,
    planificacion varchar(5) not null,  
    foreign key (usuario) references usuario(numero),
    foreign key (planificacion) references planificacion(codigo)
)



/*
    Tiempo Atrasado = Fecha Actual - Fecha Límite (si la tarea no ha sido completada).

    Tiempo Restante = Fecha Límite - Fecha Actual (si la tarea no ha sido completada).

    Porcentaje de Avance = (Tiempo Trabajado / Tiempo Estimado) * 100.

    Porcentaje de Tarea Completada = (Número de Subtareas Completadas / Total de Subtareas) * 100.
*/
insert into estatus (numero, nombre) VALUES
(1, 'Completo'),
(2, 'Sin terminar');

-- Insertando datos de ejemplo en la tabla tarea sin los campos controlados por el trigger
INSERT INTO tarea (codigo, titulo, descripcion, tiempoEstimado, fechaEntrega, usuario, estatus, tipo, dificultad, prioridad)
VALUES 
('T001', 'Desarrollo API', 'Crear API para el sistema', '2024-10-15', '2024-10-20', 1, 1, 1, 2, 3),
('T002', 'Diseño de UI', 'Prototipo de interfaz de usuario', '2024-10-10', '2024-10-18', 2, 2, 2, 3, 2),
('T003', 'Pruebas Unitarias', 'Pruebas del módulo de facturación', '2024-10-12', '2024-10-19', 3, 1, 1, 1, 1),
('T004', 'Documentación', 'Generar documentación técnica', '2024-10-11', '2024-10-21', 1, 3, 3, 2, 4),
('T005', 'Integración Frontend', 'Integrar API con el frontend', '2024-10-13', '2024-10-22', 4, 1, 2, 2, 3);

insert into tarea_avan (tarea, avance) VALUES
('T001', 1),
('T002', 2),
('T003', 3);

insert into avance (numero, progreso) VALUES
('1', 'Terminado '),
('2', 'En progreso'),
('3,', 'Pendiente');


-- Inicializacionde campos calculados de la tabla Tarea
DELIMITER $$
create trigger inicializar_tarea
before insert on tarea
for each row
begin 
    set new.tiempoAtrasado = 0;
    set new.porcetajeAvance = 0;
END$$

select * from tarea

-- Trigger para los dias atrasados en la entrega de la tarea.
DELIMITER $$
create trigger tarea_atrasada
after update on tarea_avan
for each row
begin   
    if (new.avance = 1) then
    update tarea 
        set tiempoAtrasado = DATEDIFF(fechaEntrega, tiempoEstimado)
        where codigo = new.tarea and fechaEntrega > tiempoEstimado;
end if;
end$$

drop trigger tarea_tiempoRestante

select * from tarea
where codigo = 'T002'

select * from tarea_avan
where tarea = 'T002'

update `tarea_avan`
set avance = 1
where tarea = 'T002'

--Trigger para la cantidad de dias restantes para la entrega de la tarea
DELIMITER$$
create trigger tarea_tiempoRestante
before insert on tarea
for each row
begin
    declare diff int;
    SET diff = DATEDIFF(NEW.tiempoEstimado, CURDATE());
    IF diff < 0 THEN
        SET NEW.tiempoRestante = 0;
    ELSE
        SET NEW.tiempoRestante = diff;
    END IF;
end$$

INSERT INTO tarea (codigo, titulo, descripcion, tiempoEstimado, fechaEntrega, usuario, estatus, tipo, dificultad, prioridad)
VALUES 
('T006', 'Desarrollo API', 'Crear API para el sistema', '2024-10-15', '2024-10-20', 1, 1, 1, 2, 3);

INSERT INTO `planificacion`(codigo, fechaIncio, fechaLimite, comentario) VALUES

select * from `subtarea`

select * from tarea
where codigo = 'T006'

select * from usuario
insert into usuario (numero, nombreUsuario, contraseña) VALUES
(null, 'Nia', 'niaHon')

set foreign_key_checks = 0


--Porcentaje de avance de las tareas.
DELIMITER $$
create trigger porcentaje_tarea
after insert on subtarea
for each row
begin
    declare total_subtareas int;
    declare subtareas_completadas int;
    declare porcentaje_completado DECIMAL(5,2);

    set total_subtareas = (select COUNT(*) from subtarea where tarea = new.tarea);
    set subtareas_completadas = (select COUNT(*) from subtarea where tarea = new.tarea AND avance = 1);

    if total_subtareas > 0 then
        set porcentaje_completado = (subtareas_completadas / total_subtareas) * 100;
    else
        set porcentaje_completado = 0;
    end if;

    update tarea 
    set porcetajeAvance = porcentaje_completado
    where codigo = new.tarea;
end$$


INSERT INTO planificacion (codigo, fechaInicio, fechaLimite, comentario) VALUES
('P005', '2024-10-16', '2024-03-31', 'Testeo y depuración final.');

INSERT INTO subtarea (codigo, titulo, descripcion, tiempoEstimado, planificacion, avance, tarea) VALUES
('S005', 'Pruebas unitarias', 'Realizar pruebas unitarias para todos los módulos.', '2024-03-05', 'P005', 100, 'T004');

('P001', '2024-01-01', '2024-01-31', 'Plan inicial para el desarrollo del sistema.'),
('P002', '2024-02-01', '2024-02-28', 'Revisión de seguridad y optimización.'),
('P003', '2024-03-01', '2024-03-15', 'Implementación de nuevas funcionalidades.'),
('P004', '2024-03-16', '2024-03-31', 'Testeo y depuración final.');

INSERT INTO subtarea (codigo, titulo, descripcion, tiempoEstimado, planificacion, avance, tarea) VALUES
('S005', 'Pruebas unitarias', 'Realizar pruebas unitarias para todos los módulos.', '2024-03-05', 'P005', 100, 'T004');

('S001', 'Diseño UI', 'Crear el diseño inicial de la interfaz de usuario.', '2024-01-10', 'P001', 50, 'T001'),
('S002', 'API Backend', 'Desarrollar los servicios web y la lógica del backend.', '2024-02-05', 'P002', 30, 'T002'),
('S003', 'Revisión de código', 'Auditar y optimizar el código existente.', '2024-02-20', 'P004', 70, 'T003'),
('S004', 'Pruebas unitarias', 'Realizar pruebas unitarias para todos los módulos.', '2024-03-05', 'P003', 100, 'T004');

select * from `planificacion`


--Trigger para la inicializacion de tareas asignadas de un equipo
DELIMITER $$
create trigger tarea_equipo
before insert on equipo
for each row
begin 
    set new.tareasAsignadas = 0;
END$$

--Trigger para aumentar las tareas asignadas a un equipo
DELIMITER $$
create trigger aumen_tareas_equipo
after insert on crear_tarea
for each row
begin
    declare num_equipo int;
    SELECT equipo INTO equipo_id FROM usuario_equipo WHERE usuario = NEW.usuario;
    UPDATE equipo
    SET tareasAsignadas = tareasAsignadas + 1
    WHERE numero = num_equipo;
END;

--Trigger para restar tareas al equipo en caso de que se eliminen las tareas.
DELIMITER $$
create trigger decrementar_tareas_asignadas
after delete on crear_tarea
for each row
begin
    DECLARE num_equipo INT;
    SELECT equipo INTO equipo_id FROM usuario_equipo WHERE usuario = OLD.usuario;
    
    UPDATE equipo
    SET tareasAsignadas = tareasAsignadas - 1
    WHERE numero = equipo_id;
END;




--PROCEDIMIENTOS ALMACENADOS--
--Procedimiento para obtener la info de un usuario.
create procedure ObtenerInfoUser (
in num_usurario int)
begin
    select u.nombreUsuario, r.nombre as rol, d.nombre as departamento
    from usuario u
    inner join rol as r on u.rol = r.numero
    inner join departamento as d on u.departamento = d.codigo
    where u.numero = num_usuario;
end;

--Procedimiento para saber el avance de una tarea de un usuario
create procedure AvanceTareasUser (
in num_usuario int)
begin
    select t.titulo, t.descripcion, a.progreso
    from tarea as t
    inner join tarea_avan as ta on t.codigo = ta.tarea
    inner join avance as a on ta.avance = a.numero
    WHERE t.usuario = num_usuario;
end;

--Procedimiento para saber las tareas de un depa
create procedure TareasDepa (
in depa_codigo varchar(5))
begin
    select t.codigo, t.titulo, t.descripcion, u.nombreUsuario
    from tarea as t
    inner join usuario as u on t.usuario = u.numero
    WHERE u.departamento = depa_codigo;
END;

--Procedimiento para obtener el rol de un usuario
create procedure RolUser (
    in num_usuario int,
    out rol_usuario varchar(30)
)
begin
    select r.nombre INTO rol_usuario
    from usuario as u
    inner join rol as r on u.rol = r.numero
    WHERE u.numero = num_usuario;
END;

--Procedimiento para actualizar el progreso de una tarea
create procedure Actualizar_Mostrar_AvanceTarea (
    in tarea_codigo varchar(5),
    in nuevo_avance int,
    INOUT porcentaje_actual varchar(5)
)
begin
    update tarea
    set porcetajeAvance = CONCAT(nuevo_avance, '%')
    WHERE codigo = tarea_codigo;

    select porcetajeAvance INTO porcentaje_actual
    from tarea
    WHERE codigo = tarea_codigo;
END;

select * from tarea
select * from `usuario`
SELECT 
    tarea.codigo,
    tarea.titulo
FROM 
    tarea
JOIN usuario ON tarea.usuario = usuario.numero
JOIN empleado ON usuario.empleado = empleado.numero;

SELECT 
    tarea.codigo,
    tarea.titulo
FROM 
    tarea
JOIN usuario ON tarea.usuario = usuario.numero
JOIN empleado ON usuario.empleado = empleado.numero;


-- Insertar en departamento
INSERT INTO departamento (codigo, nombre) VALUES
('D001', 'Recursos Humanos'),
('D002', 'Tecnología'),
('D003', 'Ventas');

-- Insertar en áreas
INSERT INTO areas (codigo, nombre, departamento) VALUES
('A001', 'Contratación', 'D001'),
('A002', 'Desarrollo', 'D002'),
('A003', 'Soporte', 'D002');

-- Insertar en puesto
INSERT INTO puesto (numero, nombre, departamento) VALUES
(1, 'Gerente', 'D001'),
(2, 'Desarrollador', 'D002'),
(3, 'Vendedor', 'D003');

-- Insertar en empleado
INSERT INTO empleado (numero, nombre, primerApell, segundoApell, dirCalle, dirNum, dirColonia, codigoPostal, curp, rfc, puesto) VALUES
(1, 'Juan', 'Pérez', 'López', 'Av. Siempre Viva', '123', 'Colonia Centro', 12345, 'JUAP123456HDFLNX09', 'PEJL900101ABC', 1),
(2, 'Ana', 'García', 'Martínez', 'Calle Falsa', '456', 'Colonia Norte', 54321, 'ANGM890101HDFLNX09', 'GARJ890101MGR', 2),
(3, 'Luis', 'Sánchez', 'Hernández', 'Calle Real', '789', 'Colonia Sur', 67890, 'LUSH990101HDFLNX09', 'SANL990101ABC', 3);

-- Insertar en rol
INSERT INTO rol (numero, nombre) VALUES
(1, 'Administrador'),
(2, 'Usuario');

-- Insertar en usuario
INSERT INTO usuario (numero, nombreUsuario, contraseña, empleado, rol, departamento) VALUES
(1, 'admin', 'pass123', 1, 1, 'D001'),
(2, 'ana.garcia', 'pass456', 2, 2, 'D002')
(3, 'luis.sanchez', 'pass789', 3, 2, 'D003');

-- Insertar en equipo
INSERT INTO equipo (numero, nombre, tareasAsignadas, areas) VALUES
(1, 'Equipo A', 5, 'A002'),
(2, 'Equipo B', 3, 'A003');

-- Insertar en estatus
INSERT INTO estatus (numero, nombre) VALUES
(1, 'Pendiente'),
(2, 'En Progreso'),
(3, 'Completada');

-- Insertar en tipo
INSERT INTO tipo (numero, nombre) VALUES
(1, 'Desarrollo'),
(2, 'Mantenimiento');

-- Insertar en dificultad
INSERT INTO dificultad (numero, nombre) VALUES
(1, 'Baja'),
(2, 'Media'),
(3, 'Alta');

-- Insertar en prioridad
INSERT INTO prioridad (numero, tipo) VALUES
(1, 'Baja'),
(2, 'Media'),
(3, 'Alta');

-- Insertar en tarea
INSERT INTO tarea (codigo, titulo, descripcion, tiempoEstimado, fechaEntrega, tiempoAtrasado, tiempoRestante, porcentajeAvance, usuario, estatus, tipo, dificultad, prioridad) VALUES
('T001', 'Desarrollar módulo de inicio', 'Crear la interfaz de usuario', 10, '2024-11-15', 0, 10, '0%', 2, 1, 1, 2, 1),
('T002', 'Actualizar servidor', 'Actualizar la versión del servidor', 5, '2024-11-10', 1, 4, '20%', 1, 2, 2, 1, 2);

-- Insertar en crear_tarea
INSERT INTO crear_tarea (usuario, tarea) VALUES
(2, 'T001'),
(1, 'T002');

-- Insertar en planificacion
INSERT INTO planificacion (codigo, fechaInicio, fechaLimite, comentario) VALUES
('P001', '2024-10-01', '2024-11-01', 'Planificación del primer módulo');

-- Insertar en avance
INSERT INTO avance (numero, progreso) VALUES
(1, '0%'),
(2, '50%');

-- Insertar en subtarea
INSERT INTO subtarea (codigo, titulo, descripcion, tiempoEstimado, planificacion, avance, tarea) VALUES
('S001', 'Diseñar interfaz', 'Diseñar la interfaz gráfica', 3, 'P001', 1, 'T001'),
('S002', 'Implementar lógica', 'Desarrollar la lógica del módulo', 7, 'P001', 1, 'T001');

-- Insertar en tarea_avan
INSERT INTO tarea_avan (tarea, avance) VALUES
('T001', 1),
('T002', 2);

-- Insertar en usuario_plan
INSERT INTO usuario_plan (usuario, planificacion) VALUES
(1, 'P001'),
(2, 'P001');

-- Insertar en director
INSERT INTO director (usuario, departamento) VALUES
(1, 'D001'),
(2, 'D002');

SELECT 
            tarea.codigo,
            tarea.titulo, 
            empleado.nombre AS assignee,
            estatus.nombre AS status, 
            prioridad.tipo AS priority,
            tarea.porcetajeAvance AS progress,
            dificultad.nombre AS difficulty,
            tarea.descripcion,
            tarea.tiempoEstimado,
            tarea.fechaEntrega,
            tarea.tiempoAtrasado,
            tarea.tiempoRestante
        FROM 
            tarea
        JOIN usuario ON tarea.usuario = usuario.numero
        JOIN empleado ON usuario.empleado = empleado.numero
        JOIN estatus ON tarea.estatus = estatus.numero
        JOIN prioridad ON tarea.prioridad = prioridad.numero
        JOIN dificultad ON tarea.dificultad = dificultad.numero;

select * from usuario

select * from `empleado`

SELECT numero FROM usuario WHERE nombreUsuario = 'Juan';

select * from `reporte`

INSERT INTO tarea (codigo, titulo, descripcion, tiempoEstimado, fechaEntrega, usuario, estatus, tipo, dificultad, prioridad)
VALUES 
('TT001', 'Desarrollo API', 'Crear API para el sistema', '2024-10-15', '2024-10-20', 1, 1, 1, 2, 3),
('TU002', 'Diseño de UI', 'Prototipo de interfaz de usuario', '2024-10-10', '2024-10-18', 2, 2, 2, 3, 2);

select * from `tarea`

select * from usuario

