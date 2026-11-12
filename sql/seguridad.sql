/*
   seguridad.sql
   AUTOR:
      ALAN MAURICIO MORALES LÓPEZ
      LUIS ADRIÁN GONZALEZ FALCÓN
      YASSER VLADIMIR CRUZ MIRANDA
   Fecha: 29/11/2025
   Descripción: Script de lenguaje de control de datos (DCL)

   Revisión (2026): se corrigieron el nombre de la base (EL_BUEN_RETIRO) y los
   esquemas reales de las tablas (CLIENTE, VENTAS, SEGURO). Los roles ahora se
   crean dentro de la base y no en master.
   Las contraseñas son de ejemplo: cámbialas antes de usar el script.
*/

--Crear Logins (nivel servidor)
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'admin_seguro')
    CREATE LOGIN admin_seguro WITH PASSWORD = 'Cambiar_Admin#2025';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'cotizador_seguro')
    CREATE LOGIN cotizador_seguro WITH PASSWORD = 'Cambiar_Cotiza#2025';
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'gerente_seguro')
    CREATE LOGIN gerente_seguro WITH PASSWORD = 'Cambiar_Gerente#2025';
GO

USE EL_BUEN_RETIRO;
GO

--Crear Roles (nivel base de datos)
CREATE ROLE rol_admin;
CREATE ROLE rol_cotizador;
CREATE ROLE rol_gerente;
GO

--Crear Usuarios (nivel base de datos)
CREATE USER admin_seguro FOR LOGIN admin_seguro;
CREATE USER cotizador_seguro FOR LOGIN cotizador_seguro;
CREATE USER gerente_seguro FOR LOGIN gerente_seguro;
GO

--Asignar Roles a Usuarios
ALTER ROLE rol_admin ADD MEMBER admin_seguro;
ALTER ROLE rol_cotizador ADD MEMBER cotizador_seguro;
ALTER ROLE rol_gerente ADD MEMBER gerente_seguro;
GO

--PERMISOS
--Admin: control total de la base
GRANT CONTROL ON DATABASE::EL_BUEN_RETIRO TO rol_admin;

--Cotizador: puede insertar, actualizar y consultar clientes, pólizas y cotizaciones
GRANT SELECT, INSERT, UPDATE ON CLIENTE.CLIENTE            TO rol_cotizador;
GRANT SELECT, INSERT, UPDATE ON CLIENTE.DIRECCION          TO rol_cotizador;
GRANT SELECT, INSERT, UPDATE ON CLIENTE.CORREO_CLIENTE     TO rol_cotizador;
GRANT SELECT, INSERT, UPDATE ON CLIENTE.TELEFONO_CLIENTE   TO rol_cotizador;
GRANT SELECT, INSERT, UPDATE ON VENTAS.POLIZA              TO rol_cotizador;
GRANT SELECT, INSERT, UPDATE ON VENTAS.COTIZACION          TO rol_cotizador;
GRANT SELECT, INSERT, UPDATE ON VENTAS.COTIZACION_SEGURO   TO rol_cotizador;
GRANT SELECT ON SCHEMA::CATALOGO                           TO rol_cotizador;
GRANT SELECT ON SEGURO.SEGURO                              TO rol_cotizador;
GRANT EXECUTE ON dbo.pa_RegistrarCotizacion                TO rol_cotizador;

--Gerente: solo lectura de reportes y estadísticas
GRANT SELECT ON CLIENTE.CLIENTE      TO rol_gerente;
GRANT SELECT ON VENTAS.POLIZA        TO rol_gerente;
GRANT SELECT ON VENTAS.COTIZACION    TO rol_gerente;
GRANT SELECT ON SEGURO.SINIESTRO     TO rol_gerente;
GRANT SELECT ON VENTAS.PAGO          TO rol_gerente;
GRANT SELECT ON CLIENTE.vis_cliente  TO rol_gerente;
GRANT SELECT ON SEGURO.vis_siniestro TO rol_gerente;
GO

--RESTRICCIONES
--Impedir que el cotizador elimine registros
DENY DELETE ON CLIENTE.CLIENTE     TO rol_cotizador;
DENY DELETE ON VENTAS.POLIZA       TO rol_cotizador;
DENY DELETE ON VENTAS.COTIZACION   TO rol_cotizador;
GO
