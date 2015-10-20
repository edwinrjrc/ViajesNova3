--
-- PostgreSQL database dump
--

-- Dumped from database version 9.2.3
-- Dumped by pg_dump version 9.2.3
-- Started on 2015-10-19 23:01:07

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 6 (class 2615 OID 256515)
-- Name: auditoria; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA auditoria;


ALTER SCHEMA auditoria OWNER TO postgres;

--
-- TOC entry 7 (class 2615 OID 256516)
-- Name: negocio; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA negocio;


ALTER SCHEMA negocio OWNER TO postgres;

--
-- TOC entry 8 (class 2615 OID 256517)
-- Name: reportes; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA reportes;


ALTER SCHEMA reportes OWNER TO postgres;

--
-- TOC entry 9 (class 2615 OID 256518)
-- Name: seguridad; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA seguridad;


ALTER SCHEMA seguridad OWNER TO postgres;

--
-- TOC entry 10 (class 2615 OID 256519)
-- Name: soporte; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA soporte;


ALTER SCHEMA soporte OWNER TO postgres;

--
-- TOC entry 275 (class 3079 OID 11727)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2772 (class 0 OID 0)
-- Dependencies: 275
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- TOC entry 276 (class 3079 OID 257736)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 2773 (class 0 OID 0)
-- Dependencies: 276
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = auditoria, pg_catalog;

--
-- TOC entry 468 (class 1255 OID 257291)
-- Name: fn_consultaasistencia(date); Type: FUNCTION; Schema: auditoria; Owner: postgres
--

CREATE FUNCTION fn_consultaasistencia(p_fecha date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select u.usuario, u.nombres, u.apepaterno, u.apematerno, 
       (select max(e.fecharegistro) 
          from auditoria.eventosesionsistema e
         where e.idusuario = u.id
           and date(e.fecharegistro) = p_fecha) as horaInicio
  from seguridad.usuario u
 where u.id_rol <> 1;

return micursor;

end;$$;


ALTER FUNCTION auditoria.fn_consultaasistencia(p_fecha date) OWNER TO postgres;

--
-- TOC entry 289 (class 1255 OID 256520)
-- Name: fn_registrareventosesionsistema(integer, character varying, integer); Type: FUNCTION; Schema: auditoria; Owner: postgres
--

CREATE FUNCTION fn_registrareventosesionsistema(p_idusuario integer, p_usuario character varying, p_idtipoevento integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 
fechahoy timestamp with time zone;
maxid integer;

BEGIN

maxid = nextval('auditoria.seq_eventosesionsistema');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;
	
INSERT INTO auditoria.eventosesionsistema(
            id, idusuario, usuario, fecharegistro, idtipoevento)
    VALUES (maxid, p_idusuario, p_usuario, fechahoy,p_idtipoevento);

return true;

END;
$$;


ALTER FUNCTION auditoria.fn_registrareventosesionsistema(p_idusuario integer, p_usuario character varying, p_idtipoevento integer) OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 290 (class 1255 OID 256521)
-- Name: fn_actualizarcomprobanteservicio(integer, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcomprobanteservicio(p_idservicio integer, p_generocomprobantes boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET generocomprobantes  = p_generocomprobantes, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_idservicio;

 return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarcomprobanteservicio(p_idservicio integer, p_generocomprobantes boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 291 (class 1255 OID 256522)
-- Name: fn_actualizarconsolidador(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarconsolidador(p_id integer, p_nombre character varying, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Consolidador"
   SET nombre              = p_nombre, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_id;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarconsolidador(p_id integer, p_nombre character varying, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 292 (class 1255 OID 256523)
-- Name: fn_actualizarcontactoproveedor(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcontactoproveedor(p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN

UPDATE 
  negocio."PersonaContactoProveedor" 
SET 
  idarea               = p_idarea,
  anexo                = p_anexo
WHERE idestadoregistro = 1
  AND idproveedor      = p_idproveedor
  AND idcontacto       = p_idcontacto;

return true;
END;
$$;


ALTER FUNCTION negocio.fn_actualizarcontactoproveedor(p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying) OWNER TO postgres;

--
-- TOC entry 293 (class 1255 OID 256524)
-- Name: fn_actualizarcorreoelectronico(integer, character varying, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcorreoelectronico(p_id integer, p_correo character varying, p_recibirpromociones boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CorreoElectronico"
   SET correo              = p_correo, 
       recibirpromociones  = p_recibirpromociones,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idestadoregistro    = 1
   AND id                  = p_id;


end;
$$;


ALTER FUNCTION negocio.fn_actualizarcorreoelectronico(p_id integer, p_correo character varying, p_recibirpromociones boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 294 (class 1255 OID 256525)
-- Name: fn_actualizarcuentabancaria(integer, character varying, character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcuentabancaria(p_idcuenta integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_cuentabancaria');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;


UPDATE negocio."CuentaBancaria"
   SET nombrecuenta        = p_nombrecuenta, 
       numerocuenta        = p_numerocuenta,
       idtipocuenta        = p_idtipocuenta,
       idbanco             = p_idbanco, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_idcuenta;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarcuentabancaria(p_idcuenta integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 295 (class 1255 OID 256526)
-- Name: fn_actualizarcuentabancariasaldo(integer, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarcuentabancariasaldo(p_idcuenta integer, p_saldocuenta numeric, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_cuentabancaria');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;


UPDATE negocio."CuentaBancaria"
   SET saldocuenta         = p_saldocuenta, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_idcuenta;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarcuentabancariasaldo(p_idcuenta integer, p_saldocuenta numeric, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 297 (class 1255 OID 256527)
-- Name: fn_actualizardireccion(integer, integer, character varying, character varying, character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizardireccion(p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion character varying, p_ipmodificacion character varying, p_observacion character varying, p_referencia character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare 

fechahoy    timestamp with time zone;
iddireccion integer = 0;
cantidad    integer    = 0;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."Direccion"
 where id               = p_id
   and idestadoregistro = 1;

if cantidad = 1 then
iddireccion           = p_id;
UPDATE 
  negocio."Direccion" 
SET 
  idvia                = p_idvia,
  nombrevia            = p_nombrevia,
  numero               = p_numero,
  interior             = p_interior,
  manzana              = p_manzana,
  lote                 = p_lote,
  principal            = p_principal,
  idubigeo             = p_idubigeo,
  observacion          = p_observacion,
  referencia           = p_referencia,
  usuariomodificacion  = p_usuariomodificacion,
  fechamodificacion    = fechahoy,
  ipmodificacion       = p_ipmodificacion
WHERE idestadoregistro = 1
  AND id               = iddireccion;

elsif cantidad = 0 then
select 
negocio.fn_ingresardireccion(p_idvia, p_nombrevia, p_numero, p_interior, p_manzana, p_lote, p_principal, p_idubigeo, p_usuariomodificacion, p_ipmodificacion, 
p_observacion, p_referencia)
into iddireccion;

end if;

return iddireccion;

end;
$$;


ALTER FUNCTION negocio.fn_actualizardireccion(p_id integer, p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariomodificacion character varying, p_ipmodificacion character varying, p_observacion character varying, p_referencia character varying) OWNER TO postgres;

--
-- TOC entry 298 (class 1255 OID 256528)
-- Name: fn_actualizarestadoservicio(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarestadoservicio(p_idservicio integer, p_idestadoservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET idestadoservicio    = p_idestadoservicio, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_idservicio;

 return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarestadoservicio(p_idservicio integer, p_idestadoservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 299 (class 1255 OID 256529)
-- Name: fn_actualizarpersona(integer, integer, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying, character varying, date, character varying, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarpersona(p_id integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariomodificacion character varying, p_ipmodificacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare 

fechahoy timestamp with time zone;
cantidad integer;
idpersona integer;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."Persona"
 where id               = p_id
   AND idtipopersona    = p_idtipopersona;

if cantidad = 1 then
idpersona                  = p_id;
UPDATE negocio."Persona"
   SET nombres             = p_nombres, 
       apellidopaterno     = p_apepaterno, 
       apellidomaterno     = p_apematerno, 
       idgenero            = p_idgenero, 
       idestadocivil       = p_idestadocivil, 
       idtipodocumento     = p_idtipodocumento, 
       numerodocumento     = p_numerodocumento, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion,
       fecnacimiento       = p_fecnacimiento,
       idestadoregistro    = 1,
       nropasaporte        = p_nropasaporte,
       fecvctopasaporte    = p_fecvctopasaporte
 WHERE id                  = idpersona
   AND idtipopersona       = p_idtipopersona;

elsif cantidad = 0 then

select negocio.fn_ingresarpersona(p_idtipopersona, p_nombres, p_apepaterno, p_apematerno, p_idgenero, p_idestadocivil, p_idtipodocumento, 
p_numerodocumento, p_usuariomodificacion, p_ipmodificacion, p_nropasaporte, p_fecvctopasaporte) into idpersona;

end if;

return idpersona;

 end;
$$;


ALTER FUNCTION negocio.fn_actualizarpersona(p_id integer, p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariomodificacion character varying, p_ipmodificacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date) OWNER TO postgres;

--
-- TOC entry 300 (class 1255 OID 256530)
-- Name: fn_actualizarpersonaproveedor(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarpersonaproveedor(p_idpersona integer, p_idrubro integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE 
  negocio."PersonaAdicional" 
SET 
  idrubro   = p_idrubro
WHERE idestadoregistro = 1
  AND idpersona = p_idpersona;
  
  return true;
END;
$$;


ALTER FUNCTION negocio.fn_actualizarpersonaproveedor(p_idpersona integer, p_idrubro integer) OWNER TO postgres;

--
-- TOC entry 301 (class 1255 OID 256531)
-- Name: fn_actualizarprogramanovios(integer, integer, date, date, integer, numeric, integer, integer, date, text, numeric, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarprogramanovios(p_idnovios integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_novios');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProgramaNovios"
   SET usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion, 
       idestadoregistro    = 0
 WHERE id                  = p_idnovios;

INSERT INTO negocio."ProgramaNovios"(
            id, codigonovios, idnovia, idnovio, iddestino, fechaboda, fechaviaje, 
            idmoneda, cuotainicial, dias, noches, fechashower, observaciones, 
            montototal, idservicio, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    (SELECT maxid, codigonovios, idnovia, idnovio, p_iddestino, p_fechaboda, p_fechaviaje, 
                   p_idmoneda, p_cuotainicial, p_dias, p_noches, p_fechashower, p_observaciones, 
                   p_montototal, p_idservicio, p_usuariomodificacion, fechahoy, p_ipmodificacion, 
                   p_usuariomodificacion, fechahoy, p_ipmodificacion
              FROM negocio."ProgramaNovios"
             WHERE id = p_idnovios);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarprogramanovios(p_idnovios integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 302 (class 1255 OID 256532)
-- Name: fn_actualizarproveedorcuentabancaria(integer, integer, character varying, character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarproveedorcuentabancaria(p_idcuenta integer, p_idproveedor integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare v_pagosACuenta integer;
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

SELECT count(1)
  INTO v_pagosACuenta
  FROM negocio."PagosObligacion" po
 INNER JOIN negocio."ObligacionesXPagar" ON oxp.id = po.idobligacion
 WHERE oxp.idproveedor    = p_idproveedor
   AND po.idcuentadestino = p_idcuenta;

IF v_pagosACuenta = 0 THEN
	UPDATE negocio."CuentaBancaria"
	   SET nombrecuenta        = p_nombrecuenta, 
	       numerocuenta        = p_numerocuenta,
	       idtipocuenta        = p_idtipocuenta,
	       idbanco             = p_idbanco, 
	       usuariomodificacion = p_usuariomodificacion, 
	       fechamodificacion   = fechahoy, 
	       ipmodificacion      = p_ipmodificacion
	 WHERE id                  = p_idcuenta;

ELSE
	UPDATE negocio."CuentaBancaria"
	   SET nombrecuenta        = p_nombrecuenta,
	       usuariomodificacion = p_usuariomodificacion, 
	       fechamodificacion   = fechahoy, 
	       ipmodificacion      = p_ipmodificacion
	 WHERE id                  = p_idcuenta;

END IF;


return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedorcuentabancaria(p_idcuenta integer, p_idproveedor integer, p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 303 (class 1255 OID 256533)
-- Name: fn_actualizarproveedorservicio(integer, integer, integer, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarproveedorservicio(p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare 

fechahoy timestamp with time zone;
cantidad integer;
resultado boolean;


begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select count(1)
  into cantidad
  from negocio."ProveedorTipoServicio"
 where idproveedor         = p_idproveedor
   and idtiposervicio      = p_idtiposervicio
   and idproveedorservicio = p_idproveedorservicio;

if cantidad = 1 then
UPDATE negocio."ProveedorTipoServicio"
   SET porcencomnacional      = p_porcencomision, 
       porcencominternacional = p_porcencominternacional,
       usuariomodificacion    = p_usuariomodificacion, 
       fechamodificacion      = fechahoy, 
       ipmodificacion         = p_ipmodificacion
 WHERE idproveedor            = p_idproveedor
   AND idtiposervicio         = p_idtiposervicio
   and idproveedorservicio    = p_idproveedorservicio;
else
select negocio.fn_ingresarservicioproveedor(
    p_idproveedor,
    p_idtiposervicio,
    p_idproveedorservicio,
    p_porcencomision,
    p_porcencominternacional,
    p_usuariomodificacion,
    p_ipmodificacion) into resultado;
end if;

return true;

 end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedorservicio(p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 304 (class 1255 OID 256534)
-- Name: fn_actualizarproveedortipo(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarproveedortipo(p_idpersona integer, p_idtipoproveedor integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProveedorPersona"
   SET idtipoproveedor     = p_idtipoproveedor, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idproveedor         = p_idpersona;


return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarproveedortipo(p_idpersona integer, p_idtipoproveedor integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 305 (class 1255 OID 256535)
-- Name: fn_actualizarrelacioncomprobantes(integer, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarrelacioncomprobantes(p_idservicio integer, p_guardorelacion boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET guardorelacioncomprobantes = p_guardorelacion, 
       usuariomodificacion        = p_usuariomodificacion, 
       fechamodificacion          = fechahoy, 
       ipmodificacion             = p_ipmodificacion
 WHERE id                         = p_idservicio;

 return true;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarrelacioncomprobantes(p_idservicio integer, p_guardorelacion boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 306 (class 1255 OID 256536)
-- Name: fn_actualizarservicio(integer, character varying, character varying, character varying, boolean, integer, boolean, integer, boolean, boolean, boolean, character varying, character varying, integer, boolean, boolean); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarservicio(p_id integer, p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_esimpuesto boolean, p_esfee boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."MaestroServicios"
   SET nombre              = p_nombreservicio, 
       desccorta           = p_desccorta, 
       desclarga           = p_desclarga, 
       requierefee         = p_requierefee, 
       idmaeserfee         = p_idmaeserfee,
       pagaimpto           = p_pagaimpto, 
       idmaeserimpto       = p_idmaeserimpto,
       cargacomision       = p_cargacomision,
       esimpuesto          = p_esimpuesto,
       esfee	           = p_esfee,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion,
       idparametroasociado = p_idparametro,
       visible             = p_visible,
       esserviciopadre     = p_serviciopadre
 WHERE id                  = p_id;

return true;
end;
$$;


ALTER FUNCTION negocio.fn_actualizarservicio(p_id integer, p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_esimpuesto boolean, p_esfee boolean, p_usuariomodificacion character varying, p_ipmodificacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) OWNER TO postgres;

--
-- TOC entry 307 (class 1255 OID 256537)
-- Name: fn_actualizarserviciocabecera1(integer, integer, integer, date, integer, numeric, numeric, numeric, numeric, integer, character varying, integer, integer, integer, integer, numeric, numeric, date, date, integer, text, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_actualizarserviciocabecera1(p_idservicio integer, p_idcliente1 integer, p_idcliente2 integer, p_fechacompra date, p_cantidadservicios integer, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_montototaligv numeric, p_iddestino integer, p_descdestino character varying, p_idmediopago integer, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idvendedor integer, p_observacion text, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioCabecera"
   SET idcliente1          = p_idcliente1, 
       idcliente2          = p_idcliente2, 
       fechacompra         = p_fechacompra, 
       idformapago         = p_idmediopago, 
       idestadopago        = p_idestadopago, 
       idestadoservicio    = p_idestadoservicio, 
       nrocuotas           = p_nrocuotas, 
       tea                 = p_tea, 
       valorcuota          = p_valorcuota, 
       fechaprimercuota    = p_fechaprimercuota, 
       fechaultcuota       = p_fechaultcuota, 
       montocomisiontotal  = p_montototalcomision, 
       montototaligv       = p_montototaligv, 
       montototal          = p_montototal, 
       montototalfee       = p_montototalfee, 
       idvendedor          = p_idvendedor, 
       observaciones       = p_observacion,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_idservicio;

 return p_idservicio;

end;
$$;


ALTER FUNCTION negocio.fn_actualizarserviciocabecera1(p_idservicio integer, p_idcliente1 integer, p_idcliente2 integer, p_fechacompra date, p_cantidadservicios integer, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_montototaligv numeric, p_iddestino integer, p_descdestino character varying, p_idmediopago integer, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idvendedor integer, p_observacion text, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 308 (class 1255 OID 256538)
-- Name: fn_calcularcuota(numeric, numeric, numeric); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_calcularcuota(p_montototal numeric, p_nrocuotas numeric, p_tea numeric) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

declare valorcuota decimal = 0;
declare numerador decimal = 0;
declare denominador decimal = 0;
declare tasamensual decimal = 0;

Begin

tasamensual = negocio.fn_calculartem(p_tea);

numerador = ((1+tasamensual)^p_nrocuotas) * tasamensual;
denominador = ((1+tasamensual)^p_nrocuotas) - 1;

valorcuota = p_montototal * (numerador / denominador);


return valorcuota;


End;
$$;


ALTER FUNCTION negocio.fn_calcularcuota(p_montototal numeric, p_nrocuotas numeric, p_tea numeric) OWNER TO postgres;

--
-- TOC entry 309 (class 1255 OID 256539)
-- Name: fn_calculartem(numeric); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_calculartem(p_tea numeric) RETURNS double precision
    LANGUAGE plpgsql
    AS $$

declare tasamensual decimal = 0;


begin

tasamensual = ( (1+p_tea)^(1.0/12.0) )-1;

return tasamensual;

end;
$$;


ALTER FUNCTION negocio.fn_calculartem(p_tea numeric) OWNER TO postgres;

--
-- TOC entry 310 (class 1255 OID 256540)
-- Name: fn_comboproveedorestipo(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_comboproveedorestipo(p_idtipo integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT per.id, per.nombres, per.apellidopaterno, per.apellidomaterno
  FROM negocio."Persona" per,
       negocio."ProveedorPersona" pper
 WHERE per.id                = pper.idproveedor
   AND per.idestadoregistro  = 1
   AND pper.idestadoregistro = 1
   AND pper.idtipoproveedor  = p_idtipo;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_comboproveedorestipo(p_idtipo integer) OWNER TO postgres;

--
-- TOC entry 296 (class 1255 OID 256541)
-- Name: fn_consultacuentabancaria(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultacuentabancaria(p_idcuenta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, saldocuenta, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."CuentaBancaria"
 WHERE idestadoregistro = 1
   AND id               = p_idcuenta;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultacuentabancaria(p_idcuenta integer) OWNER TO postgres;

--
-- TOC entry 492 (class 1255 OID 256542)
-- Name: fn_consultararchivoscargados(integer, date, date, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultararchivoscargados(p_idarchivo integer, p_fechadesde date, p_fechahasta date, p_idproveedor integer, p_nombrereporte character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT ac.id, nombrearchivo, nombrereporte, ac.idproveedor, vp.nombres, vp.apellidopaterno, vp.apellidomaterno, numerofilas, numerocolumnas, 
       (SELECT COUNT(1) 
          FROM negocio."DetalleArchivoCargado" dac
         WHERE idarchivo    = ac.id
           AND seleccionado = TRUE) AS seleccionados,
       ac.idmoneda, tmmo.nombre, tmmo.abreviatura, ac.montosubtotal, ac.montoigv, ac.montototal
  FROM negocio."ArchivoCargado" ac,
       negocio.vw_proveedor vp,
       soporte."Tablamaestra" tmmo
 WHERE vp.idproveedor                   = ac.idproveedor
   AND tmmo.idmaestro                   = 20
   AND ac.idmoneda                      = tmmo.id
   AND ac.id                            = COALESCE(p_idarchivo, ac.id)
   AND date(ac.fechacreacion)           BETWEEN p_fechadesde AND p_fechahasta
   AND ac.idproveedor                   = COALESCE(p_idproveedor, ac.idproveedor)
   AND REPLACE(ac.nombrereporte,' ','') LIKE '%'||COALESCE(p_nombrereporte,REPLACE(ac.nombrereporte,' ',''))||'%';

 return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultararchivoscargados(p_idarchivo integer, p_fechadesde date, p_fechahasta date, p_idproveedor integer, p_nombrereporte character varying) OWNER TO postgres;

--
-- TOC entry 493 (class 1255 OID 266418)
-- Name: fn_consultarcheckinpendientes(timestamp without time zone, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcheckinpendientes(p_fechahasta timestamp without time zone, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
select sc.id, negocio.fn_consultarnombrepersona(sc.idcliente1) as nombrecliente, 
       negocio.fn_consultarnombrepersona(sc.idcliente2) as nombrecliente2,
       t.descripcionorigen, t.descripciondestino, t.fechasalida, t.fechallegada, 
       negocio.fn_consultarnombrepersona(t.idaerolinea) nombreaerolinea,
       sd.codigoreserva, sd.numeroboleto, sd.id as iddetalle, t.id as idtramo, rs.id as idruta
  from negocio."Tramo" t
 inner join negocio."RutaServicio" rs on rs.idtramo = t.id
 inner join negocio."ServicioDetalle" sd on sd.idruta = rs.id
 inner join negocio."ServicioCabecera" sc on sc.id = sd.idservicio
 where fechasalida between current_timestamp and p_fechahasta
   and sc.idvendedor = coalesce(p_idvendedor,sc.idvendedor);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcheckinpendientes(p_fechahasta timestamp without time zone, p_idvendedor integer) OWNER TO postgres;

--
-- TOC entry 311 (class 1255 OID 256543)
-- Name: fn_consultarclientescumple(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarclientescumple() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select id, idtipopersona, nombres, apellidopaterno, apellidomaterno, 
       idgenero, idestadocivil, idtipodocumento, numerodocumento, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion, idestadoregistro, fecnacimiento, nropasaporte, 
       fecvctopasaporte
  from negocio."Persona" p
 where p.idestadoregistro              = 1
   and p.idtipopersona                 = 1
   and to_char(p.fecnacimiento,'ddMM') = to_char(current_date,'ddMM');

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarclientescumple() OWNER TO postgres;

--
-- TOC entry 312 (class 1255 OID 256544)
-- Name: fn_consultarclientesnovios(character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarclientesnovios(p_genero character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idpersona, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno
   FROM negocio."Persona" pro, 
        soporte."Tablamaestra" tdoc
  WHERE pro.idestadoregistro  = 1 
    AND pro.idtipopersona     = 1
    AND tdoc.idmaestro        = 1 
    AND pro.idtipodocumento   = tdoc.id
    AND pro.idgenero          = p_genero;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarclientesnovios(p_genero character varying) OWNER TO postgres;

--
-- TOC entry 313 (class 1255 OID 256545)
-- Name: fn_consultarclientesnovios(character varying, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarclientesnovios(p_genero character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idpersona, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno
   FROM negocio."Persona" pro, 
        soporte."Tablamaestra" tdoc
  WHERE pro.idestadoregistro  = 1 
    AND pro.idtipopersona     = 1
    AND tdoc.idmaestro        = 1 
    AND pro.idtipodocumento   = tdoc.id
    AND pro.idgenero          = p_genero
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND pro.numerodocumento   = COALESCE(p_numerodocumento,pro.numerodocumento)
    AND CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)))||'%';


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarclientesnovios(p_genero character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) OWNER TO postgres;

--
-- TOC entry 314 (class 1255 OID 256546)
-- Name: fn_consultarcompbtobligcnservdethijo(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcompbtobligcnservdethijo(p_idservicio integer, p_iddetservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as numeroComprobante,
       (select tm.nombre
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = 17) as tipoObligacion,
       (select tm.abreviatura
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = 17) as tipoObligacionAbrev,
       (select obli.numerocomprobante
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id) as numeroObligacion
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_iddetservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcompbtobligcnservdethijo(p_idservicio integer, p_iddetservicio integer) OWNER TO postgres;

--
-- TOC entry 315 (class 1255 OID 256547)
-- Name: fn_consultarcomprobantesgenerados(integer, integer, integer, integer, character varying, date, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcomprobantesgenerados(p_idcomprobante integer, p_idservicio integer, p_idadquiriente integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_fechadesde date, p_fechahasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT cg.id, cg.idservicio, cg.idtipocomprobante, tm.nombre, cg.numerocomprobante, cg.idtitular, p.nombres, p.apellidopaterno, p.apellidomaterno,
       cg.fechacomprobante, cg.totaligv, cg.totalcomprobante, cg.tienedetraccion, 
       cg.tieneretencion, cg.usuariocreacion, cg.fechacreacion, cg.ipcreacion, cg.usuariomodificacion, 
       cg.fechamodificacion, cg.ipmodificacion
  FROM negocio."ComprobanteGenerado" cg
 INNER JOIN soporte."Tablamaestra" tm ON cg.idtipocomprobante = tm.id AND tm.idmaestro = 17
 INNER JOIN negocio."Persona" p       ON cg.idtitular         = p.id
 WHERE cg.idestadoregistro  = 1
   AND cg.fechacomprobante  BETWEEN COALESCE(p_fechadesde,'1900-01-01') AND COALESCE(p_fechahasta,current_date)
   AND cg.id                = COALESCE(p_idcomprobante, cg.id)
   AND cg.idservicio        = COALESCE(p_idservicio, cg.idservicio)
   AND cg.idtitular         = COALESCE(p_idadquiriente, cg.idtitular)
   AND cg.idtipocomprobante = COALESCE(p_idtipocomprobante, cg.idtipocomprobante)
   AND cg.numerocomprobante = COALESCE(p_numerocomprobante, cg.numerocomprobante);
   

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcomprobantesgenerados(p_idcomprobante integer, p_idservicio integer, p_idadquiriente integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_fechadesde date, p_fechahasta date) OWNER TO postgres;

--
-- TOC entry 316 (class 1255 OID 256548)
-- Name: fn_consultarcomprobantesobligacionservdet(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcomprobantesobligacionservdet(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as numeroComprobante,
       (select tm.nombre
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = 17) as tipoObligacion,
	(select tm.abreviatura
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = 17) as tipoObligacionAbrev,
       (select obli.numerocomprobante
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id) as numeroObligacion
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcomprobantesobligacionservdet(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 317 (class 1255 OID 256549)
-- Name: fn_consultarcomprobantesserviciodetalle(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcomprobantesserviciodetalle(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as numeroComprobante
       
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcomprobantesserviciodetalle(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 318 (class 1255 OID 256550)
-- Name: fn_consultarcompserviciodethijo(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcompserviciodethijo(p_idservicio integer, p_iddetserv integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible,
       (select cg.tienedetraccion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneDetraccion,
       (select cg.tieneretencion
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tieneRetencion,
       (select cg.id
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as idComprobante,
       (select cg.idtipocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as tipoComprobante,
       (select tm.nombre
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = 17) as tipoComprobanteAbrev,
       (select cg.numerocomprobante
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante = cg.id) as numeroComprobante
       
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_iddetserv;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcompserviciodethijo(p_idservicio integer, p_iddetserv integer) OWNER TO postgres;

--
-- TOC entry 319 (class 1255 OID 256551)
-- Name: fn_consultarconsolidador(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarconsolidador(p_idconsolidador integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion
  FROM negocio."Consolidador"
 WHERE idestadoregistro = 1
   AND id               = p_idconsolidador;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarconsolidador(p_idconsolidador integer) OWNER TO postgres;

--
-- TOC entry 320 (class 1255 OID 256552)
-- Name: fn_consultarcontactoxpersona(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcontactoxpersona(p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, 
       per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento
  from negocio."PersonaContactoProveedor" pcon,
       negocio."Persona" per
 where pcon.idestadoregistro = 1
   and per.idestadoregistro  = 1
   and per.idtipopersona     = 3
   and pcon.idcontacto       = per.id
   and pcon.idproveedor      = p_idpersona;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcontactoxpersona(p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 321 (class 1255 OID 256553)
-- Name: fn_consultarcronogramapago(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcronogramapago(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
       idestadocuota, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CronogramaPago"
 where idservicio = p_idservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcronogramapago(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 322 (class 1255 OID 256554)
-- Name: fn_consultarcronogramaservicio(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarcronogramaservicio(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
       idestadocuota, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CronogramaPago"
 WHERE idservicio = p_idservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarcronogramaservicio(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 323 (class 1255 OID 256555)
-- Name: fn_consultardetallecomprobantegenerado(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultardetallecomprobantegenerado(p_idcomprobante integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT id, idserviciodetalle, idcomprobante, cantidad, detalleconcepto, 
       preciounitario, totaldetalle
  FROM negocio."DetalleComprobanteGenerado"
 WHERE idcomprobante = p_idcomprobante;
   

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultardetallecomprobantegenerado(p_idcomprobante integer) OWNER TO postgres;

--
-- TOC entry 324 (class 1255 OID 256556)
-- Name: fn_consultardetalleservicioventadetalle(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultardetalleservicioventadetalle(p_idservicio integer, p_iddetalle integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, 
       tipser.id as idtiposervicio, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee, tipser.visible,
       
       serdet.descripcionservicio, 
       serdet.idservicio, 
       serdet.fechaida, 
       serdet.fecharegreso, 
       serdet.cantidad, 
       serdet.idempresaproveedor, 
       serdet.descripcionproveedor,
       pro.nombres, pro.apellidopaterno, pro.apellidomaterno,
       serdet.idempresaoperadora, 
       serdet.descripcionoperador, 
       serdet.idempresatransporte, 
       serdet.descripcionemptransporte, 
       serdet.idhotel, 
       serdet.decripcionhotel, 
       serdet.idruta, 
       serdet.preciobase, 
       serdet.editocomision, 
       serdet.tarifanegociada, 
       serdet.porcencomision, 
       serdet.montocomision, 
       serdet.montototal, 
       serdet.codigoreserva, 
       serdet.numeroboleto
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.id = serdet.idtiposervicio AND tipser.idestadoregistro = 1
  LEFT JOIN negocio.vw_proveedoresnova pro    ON pro.id    = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.id               = p_iddetalle;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultardetalleservicioventadetalle(p_idservicio integer, p_iddetalle integer) OWNER TO postgres;

--
-- TOC entry 325 (class 1255 OID 256557)
-- Name: fn_consultarinvitadosnovios(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarinvitadosnovios(p_idnovios integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, nombres, apellidopaterno, apellidomaterno, telefono, correoelectronico, 
       fecnacimiento
  FROM negocio."Personapotencial"
 WHERE idnovios = p_idnovios;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarinvitadosnovios(p_idnovios integer) OWNER TO postgres;

--
-- TOC entry 494 (class 1255 OID 266403)
-- Name: fn_consultarnombrepersona(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarnombrepersona(p_id integer) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
declare nombre character varying(100);

begin

SELECT COALESCE(pro.nombres,'')||' '||COALESCE(pro.apellidopaterno,'')||' '||COALESCE(pro.apellidomaterno,'')
  INTO nombre
  FROM negocio."Persona" pro
 WHERE pro.id               = p_id;

return nombre;

end;
$$;


ALTER FUNCTION negocio.fn_consultarnombrepersona(p_id integer) OWNER TO postgres;

--
-- TOC entry 327 (class 1255 OID 256558)
-- Name: fn_consultarnovios(integer, character varying, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarnovios(p_id integer, p_codnovios character varying, p_idnovia integer, p_idnovio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT snov.id, snov.codigonovios, novia.idtipodocumento as tipodocnovia, novia.numerodocumento as numdocnovia, 
       snov.idnovia, novia.nombres as nomnovia, novia.apellidopaterno as apepatnovia, novia.apellidomaterno as apematnovia,
       novio.idtipodocumento as tipodocnovio, novio.numerodocumento as numdocnovio, 
       snov.idnovio, novio.nombres as nomnovio, novio.apellidopaterno as apepatnovio, novio.apellidomaterno as apematnovio,
       snov.iddestino, dest.descripcion as descdestino, dest.codigoiata, pai.descripcion as descpais,
       snov.fechaboda, snov.fechaviaje, 
       snov.idmoneda, snov.cuotainicial, snov.dias, snov.noches, snov.fechashower, snov.observaciones, 
       snov.usuariocreacion, snov.fechacreacion, snov.ipcreacion, snov.usuariomodificacion, 
       snov.fechamodificacion, snov.ipmodificacion,
       (select count(1) from negocio."Personapotencial" where idnovios = snov.id) as cantidadInvitados, snov.idservicio,
       sercab.idvendedor, usu.nombres as nomvendedor, usu.apepaterno as apepatvendedor, usu.apematerno as apematvendedor,
       sercab.montocomisiontotal, sercab.montototal, sercab.montototalfee
  FROM negocio."ProgramaNovios" snov,
       negocio."Persona" novia,
       negocio."Persona" novio,
       soporte.destino dest,
       soporte.pais pai,
       negocio."ServicioCabecera" sercab,
       seguridad.usuario usu
 WHERE snov.idestadoregistro  = 1
   AND snov.id                = COALESCE(p_id,snov.id)
   AND novia.idestadoregistro = 1
   AND novia.idtipopersona    = 1
   AND novia.id               = snov.idnovia
   AND snov.idnovia           = COALESCE(p_idnovia,snov.idnovia)
   AND novio.idestadoregistro = 1
   AND novio.idtipopersona    = 1
   AND novio.id               = snov.idnovio
   AND snov.idnovio           = COALESCE(p_idnovio,snov.idnovio)
   AND dest.idestadoregistro  = 1
   AND dest.id                = snov.iddestino
   AND pai.idestadoregistro   = 1
   AND dest.idpais            = pai.id
   AND snov.idservicio        = sercab.id
   AND sercab.idvendedor      = usu.id
   AND snov.codigonovios      = COALESCE(p_codnovios,snov.codigonovios);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarnovios(p_id integer, p_codnovios character varying, p_idnovia integer, p_idnovio integer) OWNER TO postgres;

--
-- TOC entry 328 (class 1255 OID 256559)
-- Name: fn_consultarobligacion(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarobligacion(p_idobligacion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT oxp.id, idtipocomprobante, tmtd.nombre, numerocomprobante, idproveedor as idtitular, tit.nombres, tit.apellidopaterno, tit.apellidomaterno, fechacomprobante, 
       fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, 
       tieneretencion
  FROM negocio."ObligacionesXPagar" oxp
 INNER JOIN soporte."Tablamaestra" tmtd ON tmtd.idmaestro = 17 AND tmtd.id = oxp.idtipocomprobante
 INNER JOIN negocio."Persona" tit ON tit.id = oxp.idproveedor AND tit.idestadoregistro = 1
 WHERE oxp.id = p_idobligacion;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarobligacion(p_idobligacion integer) OWNER TO postgres;

--
-- TOC entry 329 (class 1255 OID 256560)
-- Name: fn_consultarobligacionxpagar(integer, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select oxp.id, oxp.idtipocomprobante, tm.nombre as nombrecomprobante, oxp.numerocomprobante, 
       oxp.idproveedor, pro.nombres, oxp.fechacomprobante, 
       oxp.fechapago, oxp.detallecomprobante, oxp.totaligv, oxp.totalcomprobante, oxp.saldocomprobante
  from negocio."ObligacionesXPagar" oxp,
       soporte."Tablamaestra" tm,
       negocio."Persona" pro
 where oxp.idtipocomprobante = tm.id
   and tm.idmaestro          = 17
   and pro.idestadoregistro  = 1
   and pro.idtipopersona     = 2
   and pro.id                = oxp.idproveedor
   and oxp.idtipocomprobante = COALESCE(p_idtipocomprobante,oxp.idtipocomprobante)
   and oxp.numerocomprobante = COALESCE(p_numerocomprobante,oxp.numerocomprobante)
   and oxp.idproveedor       = COALESCE(p_idproveedor,oxp.idproveedor);

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer) OWNER TO postgres;

--
-- TOC entry 495 (class 1255 OID 266417)
-- Name: fn_consultarpasajeros(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpasajeros(p_idserviciodetalle integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea, 
       negocio.fn_consultarnombrepersona(idaerolinea) as nombreaerolina, 
       idrelacion, tmre.nombre as nombrerelacion,
       idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 INNER JOIN soporte."Tablamaestra" tmre ON tmre.idmaestro = 23 AND tmre.id = ps.idrelacion
 WHERE idserviciodetalle = p_idserviciodetalle;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpasajeros(p_idserviciodetalle integer) OWNER TO postgres;

--
-- TOC entry 330 (class 1255 OID 256561)
-- Name: fn_consultarpersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpersona(p_id integer, p_idtipopersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, 
    pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, 
    pro.usuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pro.fecnacimiento,
    pro.nropasaporte, pro.fecvctopasaporte
   FROM negocio."Persona" pro
   left join negocio."PersonaAdicional" ppro on ppro.idpersona = pro.id AND ppro.idestadoregistro = 1
  WHERE pro.idestadoregistro = 1 
    AND pro.idtipopersona = p_idtipopersona
    AND pro.id = p_id;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpersona(p_id integer, p_idtipopersona integer) OWNER TO postgres;

--
-- TOC entry 469 (class 1255 OID 256562)
-- Name: fn_consultarpersonas(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpersonas(p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idproveedor, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno, 
       dir.idvia, tvia.nombre AS nombretipovia, 
       dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, 
	    ( SELECT tel.numero
		FROM negocio."TelefonoDireccion" tedir, 
		     negocio."Telefono" tel
	       WHERE tedir.idestadoregistro = 1 
		 AND tel.idestadoregistro   = 1 
		 AND tedir.iddireccion      = dir.id 
		 AND tedir.idtelefono       = tel.id LIMIT 1) AS teledireccion
   FROM negocio."Persona" pro
  INNER JOIN soporte."Tablamaestra" tdoc     ON tdoc.idmaestro        = 1 AND pro.idtipodocumento = tdoc.id
   LEFT JOIN negocio."PersonaDireccion" pdir ON pdir.idestadoregistro = 1 AND pro.id              = pdir.idpersona
   LEFT JOIN negocio."Direccion" dir         ON dir.idestadoregistro  = 1 AND pdir.iddireccion    = dir.id AND dir.principal = 'S'
   LEFT JOIN soporte."Tablamaestra" tvia     ON tvia.idmaestro        = 2 AND dir.idvia           = tvia.id
  WHERE pro.idestadoregistro  = 1 
    AND pro.idtipopersona     = COALESCE(p_idtipopersona,pro.idtipopersona)
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND pro.numerodocumento   = COALESCE(p_numerodocumento,pro.numerodocumento)
    AND CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)))||'%';

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpersonas(p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) OWNER TO postgres;

--
-- TOC entry 331 (class 1255 OID 256563)
-- Name: fn_consultarpersonas2(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarpersonas2(p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT per.id, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, per.numerodocumento, per.nombres, 
       per.apellidopaterno, per.apellidomaterno, per.idgenero, 
       (case when per.idgenero='M' then 'MASCULINO'
        else 'FEMENINO' end) as genero, per.idestadocivil, estciv.nombre
   FROM soporte."Tablamaestra" tdoc,
        negocio."Persona" per
   LEFT JOIN soporte."Tablamaestra" estciv ON estciv.idmaestro = 9 AND estciv.id = per.idestadocivil
  WHERE per.idestadoregistro  = 1 
    AND per.idtipopersona     = 1
    AND tdoc.idmaestro        = 1 
    AND per.idtipodocumento   = tdoc.id
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND per.numerodocumento   = COALESCE(p_numerodocumento,per.numerodocumento)
    AND CONCAT(replace(per.nombres,' ',''),trim(per.apellidopaterno),trim(per.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(per.nombres,' ',''),trim(per.apellidopaterno),trim(per.apellidomaterno)))||'%';


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarpersonas2(p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying) OWNER TO postgres;

--
-- TOC entry 332 (class 1255 OID 256564)
-- Name: fn_consultarproveedorservicio(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarproveedorservicio(p_idproveedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idproveedor, idtiposervicio, idproveedorservicio, porcencomnacional, porcencominternacional
  FROM negocio."ProveedorTipoServicio"
 WHERE idproveedor = p_idproveedor;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarproveedorservicio(p_idproveedor integer) OWNER TO postgres;

--
-- TOC entry 326 (class 1255 OID 256565)
-- Name: fn_consultarsaldosservicio(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarsaldosservicio(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
       montosaldoservicio
  FROM negocio."SaldosServicio"
 WHERE idsaldoservicio = (SELECT max(idsaldoservicio)
                            FROM negocio."SaldosServicio" 
                           WHERE idservicio = p_idservicio);


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarsaldosservicio(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 343 (class 1255 OID 256566)
-- Name: fn_consultarservicio(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicio(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, idmaeserfee, pagaimpto, idmaeserimpto, cargacomision, esimpuesto, esfee, idparametroasociado, visible, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE id = p_idservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicio(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 344 (class 1255 OID 256567)
-- Name: fn_consultarserviciodependientes(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarserviciodependientes(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idservicio, idserviciodepende, ms.nombre, ms.visible
  FROM negocio."ServicioMaestroServicio" sms,
       negocio."MaestroServicios" ms
 WHERE sms.idestadoregistro  = 1
   AND sms.idservicio        = p_idservicio
   AND sms.idserviciodepende = ms.id;
  -- AND ms.visible            = true;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarserviciodependientes(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 345 (class 1255 OID 256568)
-- Name: fn_consultarserviciodetallehijos(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarserviciodetallehijos(p_idservicio integer, p_idserviciopadre integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, serdet.codigoreserva, serdet.numeroboleto
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_idserviciopadre;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarserviciodetallehijos(p_idservicio integer, p_idserviciopadre integer) OWNER TO postgres;

--
-- TOC entry 346 (class 1255 OID 256569)
-- Name: fn_consultarserviciosinvisibles(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarserviciosinvisibles(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for

select sms.idserviciodepende, ms.nombre, COALESCE((select max(valor) from soporte."Parametro" par where par.id = ms.idparametroasociado),'0') as valor
  from negocio."ServicioMaestroServicio" sms
  inner join negocio."MaestroServicios" ms on sms.idserviciodepende = ms.id
   and ms.visible            = false
 where sms.idservicio        = p_idservicio;

 return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarserviciosinvisibles(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 347 (class 1255 OID 256570)
-- Name: fn_consultarservicioventa(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventa(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, sercab.montocomisiontotal, sercab.montototaligv, sercab.montototalfee,
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota, sercab.montocomisiontotal,
       sercab.idestadoservicio, 
       (select count(1) from negocio."PagosServicio" where idservicio=sercab.id) tienepagos,
       usu.id as idusuario,
       usu.nombres as nombresvendedor, usu.apepaterno, usu.apematerno,
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion, sercab.generocomprobantes, sercab.guardorelacioncomprobantes, sercab.observaciones
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = 14 and maeep.id = sercab.idestadopago
 inner join seguridad.usuario usu on usu.id = sercab.idvendedor
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and sercab.id               = p_idservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventa(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 348 (class 1255 OID 256571)
-- Name: fn_consultarservicioventa(integer, character varying, character varying, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventa(p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, 
       sercab.idformapago, maemp.nombre as nommediopago, maemp.descripcion as descmediopago,
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" where idservicio = sercab.id) as cantidadNovios
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maemp on maemp.estado = 'A' and maemp.idmaestro = 13 and maemp.id = sercab.idformapago
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = 14 and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idmaestro = 15 and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor);
	
return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventa(p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer) OWNER TO postgres;

--
-- TOC entry 349 (class 1255 OID 256572)
-- Name: fn_consultarservicioventa(integer, character varying, character varying, integer, integer, date, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventa(p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer, p_idservicio integer, p_fechadesde date, p_fechahasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

if p_idservicio is not null then
open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, 
       sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" where idservicio = sercab.id) as cantidadNovios, sercab.idvendedor
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = 14 and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idmaestro = 15 and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and sercab.id               = COALESCE(p_idservicio,sercab.id);
else
open micursor for
select sercab.id, sercab.idcliente1, cli1.nombres as nombres1, cli1.apellidopaterno as apellidopaterno1, cli1.apellidomaterno as apellidomaterno1, 
       sercab.idcliente2, cli2.nombres as nombres2, cli2.apellidopaterno as apellidopaterno2, cli2.apellidomaterno as apellidomaterno2, 
       sercab.fechacompra, sercab.montototal, sercab.idestadopago, maeep.nombre as nomestpago, maeep.descripcion as descestpago, sercab.idestadoservicio, maest.nombre as nomestservicio,
       sercab.nrocuotas, sercab.tea, sercab.valorcuota, sercab.fechaprimercuota, sercab.fechaultcuota,
       sercab.usuariocreacion, sercab.fechacreacion, sercab.ipcreacion, 
       sercab.usuariomodificacion, sercab.fechamodificacion, sercab.ipmodificacion,
       (select count(1) from negocio."ProgramaNovios" where idservicio = sercab.id) as cantidadNovios, sercab.idvendedor
  from negocio."ServicioCabecera" sercab 
 inner join negocio.vw_clientesnova cli1 on sercab.idcliente1 = cli1.id
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = 14 and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idmaestro = 15 and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id
 where sercab.idestadoregistro = 1
   and sercab.fechacompra between p_fechadesde and p_fechahasta
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor)
   and sercab.id               = COALESCE(p_idservicio,sercab.id);
end if;
	
return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventa(p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer, p_idservicio integer, p_fechadesde date, p_fechahasta date) OWNER TO postgres;

--
-- TOC entry 353 (class 1255 OID 256573)
-- Name: fn_consultarservicioventadetalle(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventadetalle(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible, serdet.codigoreserva, serdet.numeroboleto
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventadetalle(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 354 (class 1255 OID 256574)
-- Name: fn_consultarservicioventadetallehijo(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventadetallehijo(p_idservicio integer, p_idserdeta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible, serdet.codigoreserva, serdet.numeroboleto
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio AND tipser.esserviciopadre = false
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende = p_idserdeta;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventadetallehijo(p_idservicio integer, p_idserdeta integer) OWNER TO postgres;

--
-- TOC entry 355 (class 1255 OID 256575)
-- Name: fn_consultarservicioventadetallepadre(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventadetallepadre(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT serdet.id as idSerdetalle, serdet.idtiposervicio, 
       tipser.id, tipser.nombre as nomtipservicio, tipser.desccorta as descservicio, tipser.requierefee, 
       tipser.pagaimpto, tipser.cargacomision, tipser.esimpuesto, tipser.esfee,
       serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.cantidad, 
       serdet.preciobase, serdet.porcencomision, serdet.montocomision, serdet.montototal, serdet.idempresaproveedor, pro.nombres, pro.apellidopaterno, 
       pro.apellidomaterno, tipser.visible, serdet.codigoreserva, serdet.numeroboleto
  FROM negocio."ServicioDetalle" serdet
 INNER JOIN negocio."MaestroServicios" tipser ON tipser.idestadoregistro = 1 AND tipser.id = serdet.idtiposervicio AND tipser.esserviciopadre = true
  LEFT JOIN negocio.vw_proveedoresnova pro ON pro.id = serdet.idempresaproveedor
 WHERE serdet.idestadoregistro = 1
   AND serdet.idservicio       = p_idservicio
   AND serdet.idservdetdepende is null;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventadetallepadre(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 356 (class 1255 OID 256576)
-- Name: fn_consultarservicioventajr(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultarservicioventajr(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select cantidad, descripcionservicio, fechaida, 
       fecharegreso, idmoneda, abreviatura, preciobase, montototal, 
       codigoreserva, numeroboleto, idservicio 
  from negocio.vw_servicio_detalle 
 where idservicio = p_idservicio;


return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultarservicioventajr(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 357 (class 1255 OID 256577)
-- Name: fn_consultartipocambio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultartipocambio(p_idmonedaorigen integer, p_idmonedadestino integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare fechahoy date;
declare v_cantidad integer;
declare v_idultimo integer;
declare v_idtipocambio integer;
declare v_mensaje character varying(100);
declare micursor refcursor;

begin

select current_date into fechahoy;

select count(1)
  into v_cantidad
  from negocio."TipoCambio"
 where fechatipocambio = fechahoy
   and idmonedaorigen  = p_idmonedaorigen
   and idmonedadestino = p_idmonedadestino;

if v_cantidad = 1 then
    select id
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
elsif v_cantidad > 1 then
    select max(id)
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
else
    select count(1)
      into v_cantidad
      from negocio."TipoCambio"
     where idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;

    if v_cantidad >= 1 then
        select max(id)
          into v_idtipocambio
	  from negocio."TipoCambio"
	 where idmonedaorigen  = p_idmonedaorigen
	   and idmonedadestino = p_idmonedadestino;
    else
        v_mensaje = 'Tipo de cambio de '||(select nombre
                                            from soporte."Tablamaestra" 
                                           where idmaestro = 20
                                             and id        = p_idmonedaorigen);
        v_mensaje = v_mensaje || ' a ' || (select nombre
                                           from soporte."Tablamaestra" 
                                          where idmaestro = 20
                                            and id        = p_idmonedadestino);

        v_mensaje = v_mensaje || ' no fue registrado';
        
        RAISE USING MESSAGE = v_mensaje;
    end if;
end if;

open micursor for
SELECT tc.id, fechatipocambio, 
       idmonedaorigen, tmmo.nombre as nombreMonOrigen, 
       idmonedadestino, tmmd.nombre as nombreMonDestino, 
       montocambio
  FROM negocio."TipoCambio" tc
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = 20 AND tmmo.id = idmonedaorigen
 INNER JOIN soporte."Tablamaestra" tmmd ON tmmd.idmaestro = 20 AND tmmd.id = idmonedadestino
 WHERE tc.id = v_idtipocambio;

 return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultartipocambio(p_idmonedaorigen integer, p_idmonedadestino integer) OWNER TO postgres;

--
-- TOC entry 358 (class 1255 OID 256578)
-- Name: fn_consultartipocambiomonto(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultartipocambiomonto(p_idmonedaorigen integer, p_idmonedadestino integer) RETURNS numeric
    LANGUAGE plpgsql
    AS $$

declare fechahoy date;
declare v_cantidad integer;
declare v_idtipocambio integer;
declare v_mensaje character varying(15);
declare v_tipocambio decimal(9,6);

begin

select current_date into fechahoy;

select count(1)
  into v_cantidad
  from negocio."TipoCambio"
 where fechatipocambio = fechahoy
   and idmonedaorigen  = p_idmonedaorigen
   and idmonedadestino = p_idmonedadestino;

if v_cantidad = 1 then
    select id
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
elsif v_cantidad > 1 then
    select max(id)
      into v_idtipocambio
      from negocio."TipoCambio"
     where fechatipocambio = fechahoy
       and idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;
else
    select count(1)
      into v_cantidad
      from negocio."TipoCambio"
     where idmonedaorigen  = p_idmonedaorigen
       and idmonedadestino = p_idmonedadestino;

    if v_cantidad >= 1 then
        select max(id)
          into v_idtipocambio
	  from negocio."TipoCambio"
	 where idmonedaorigen  = p_idmonedaorigen
	   and idmonedadestino = p_idmonedadestino;
    else
        v_mensaje = 'Tipo de cambio de '+(select nombre
                                            from soporte."Tablamaestra" 
                                           where idmaestro = 20
                                             and id        = p_idmonedaorigen);
        v_mensaje = v_mensaje + ' a ' + (select nombre
                                           from soporte."Tablamaestra" 
                                          where idmaestro = 20
                                            and id        = p_idmonedadestino);

        v_mensaje = v_mensaje + ' no fue registrado';
        
        RAISE USING MESSAGE = v_mensaje;
    end if;
end if;

SELECT montocambio
  INTO v_tipocambio
  FROM negocio."TipoCambio"
 WHERE id = v_idtipocambio;

return v_tipocambio;

end;
$$;


ALTER FUNCTION negocio.fn_consultartipocambiomonto(p_idmonedaorigen integer, p_idmonedadestino integer) OWNER TO postgres;

--
-- TOC entry 496 (class 1255 OID 256579)
-- Name: fn_consultartramosruta(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_consultartramosruta(p_idruta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
SELECT tramo.id as idtramo, tramo.descripcionorigen, tramo.fechasalida, tramo.descripciondestino, tramo.fechallegada, tramo.preciobase, per.nombres
  FROM negocio."RutaServicio" ruta
 INNER JOIN negocio."Tramo" tramo ON ruta.idtramo = tramo.id
 INNER JOIN negocio."Persona" per ON per.idestadoregistro  = 1 AND tramo.idaerolinea = per.id
 WHERE ruta.idestadoregistro = 1
   AND ruta.id               = p_idruta;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_consultartramosruta(p_idruta integer) OWNER TO postgres;

--
-- TOC entry 359 (class 1255 OID 256580)
-- Name: fn_correosxpersona(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_correosxpersona(p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, correo, idpersona, usuariocreacion, fechacreacion, ipcreacion, 
       usuariomodificacion, fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."CorreoElectronico"
 WHERE idestadoregistro = 1
   AND idpersona        = p_idpersona;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_correosxpersona(p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 363 (class 1255 OID 256581)
-- Name: fn_direccionesxpersona(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_direccionesxpersona(p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT dir.id, dir.idvia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, 
       dir.lote, dir.principal, dir.idubigeo, dir.usuariocreacion, 
       dir.fechacreacion, dir.ipcreacion, dep.iddepartamento, 
       dep.descripcion AS departamento, pro.idprovincia, 
       pro.descripcion AS provincia, dis.iddistrito, dis.descripcion AS distrito, 
       pdir.idpersona, dir.observacion, dir.referencia
  FROM negocio."Direccion" dir, 
       negocio."PersonaDireccion" pdir, 
       soporte.ubigeo dep, 
       soporte.ubigeo pro, 
       soporte.ubigeo dis
 WHERE dir.idestadoregistro                  =  1 
   AND pdir.idestadoregistro                 =  1 
   AND dir.id                                =  pdir.iddireccion 
   AND substring(dir.idubigeo, 1, 2)||'0000' =  dep.id
   AND dep.iddepartamento                    <> '00'
   AND dep.idprovincia                       =  '00'
   AND dep.iddistrito                        =  '00'
   AND substring(dir.idubigeo, 1, 4)||'00'   =  pro.id
   AND pro.iddepartamento                    <> '00'
   AND pro.idprovincia                       <> '00'
   AND pro.iddistrito                        =  '00'
   AND dis.id::bpchar                        = dir.idubigeo
   AND pdir.idpersona                        = p_idpersona;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_direccionesxpersona(p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 364 (class 1255 OID 256582)
-- Name: fn_eliminarcontactoproveedor(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcontactoproveedor(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Persona"
   SET idestadoregistro    = 0,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idestadoregistro    = 1
   AND id                  in (select idcontacto
                                 from negocio."PersonaContactoProveedor"
                                where idestadoregistro = 1
                                  and idproveedor      = p_idpersona);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcontactoproveedor(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 365 (class 1255 OID 256583)
-- Name: fn_eliminarcorreoscontacto(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcorreoscontacto(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CorreoElectronico"
   SET idestadoregistro    = 0, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idestadoregistro    = 1
   AND idpersona           = p_idpersona;

return p_idpersona;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcorreoscontacto(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 366 (class 1255 OID 256584)
-- Name: fn_eliminarcronogramaservicio(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcronogramaservicio(p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."CronogramaPago"
   SET idestadoregistro    = 0,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idservicio          = p_idservicio;
 
return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcronogramaservicio(p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 367 (class 1255 OID 256585)
-- Name: fn_eliminarcuentasproveedor(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarcuentasproveedor(p_idproveedor integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ProveedorCuentaBancaria"
   SET idestadoregistro    = 0,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idestadoregistro    = 1
   AND idproveedor         = p_idproveedor;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarcuentasproveedor(p_idproveedor integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 368 (class 1255 OID 256586)
-- Name: fn_eliminardetalleservicio(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminardetalleservicio(p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."ServicioDetalle"
   SET idestadoregistro    = 0,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idservicio          = p_idservicio;
 
return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminardetalleservicio(p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 369 (class 1255 OID 256587)
-- Name: fn_eliminardirecciones(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminardirecciones(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."Direccion" 
SET 
  idestadoregistro     = 0,
  usuariomodificacion  = p_usuariomodificacion,
  fechamodificacion    = fechahoy,
  ipmodificacion       = p_ipmodificacion
WHERE idestadoregistro = 1
  AND id               IN (SELECT iddireccion 
                             FROM negocio."PersonaDireccion"
                            WHERE idpersona        = p_idpersona
                              AND idestadoregistro = 1);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminardirecciones(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 370 (class 1255 OID 256588)
-- Name: fn_eliminardocumentosustentoservicio(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminardocumentosustentoservicio(p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."DocumentoAdjuntoServicio"
   SET idestadoregistro    = 0,
       usuariomodificacion = p_usuariomodificacion,
       fechamodificacion   = fechahoy,
       ipmodificacion      = p_ipmodificacion
 WHERE idservicio          = p_idservicio;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminardocumentosustentoservicio(p_idservicio integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 371 (class 1255 OID 256589)
-- Name: fn_eliminarinvitadosnovios(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarinvitadosnovios(p_idnovios integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Personapotencial"
   SET usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion, 
       idestadoregistro    = 0
 WHERE idnovios            = p_idnovios;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarinvitadosnovios(p_idnovios integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 372 (class 1255 OID 256590)
-- Name: fn_eliminarpersona(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarpersona(p_idpersona integer, p_idtipopersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE negocio."Persona"
   SET idestadoregistro    = 0,
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE idestadoregistro    = 1
   AND id                  = p_idpersona
   AND idtipopersona       = p_idtipopersona;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarpersona(p_idpersona integer, p_idtipopersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 485 (class 1255 OID 257950)
-- Name: fn_eliminarpersonadirecciones(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarpersonadirecciones(p_idpersona integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."PersonaDireccion"
SET 
  idestadoregistro     = 0
WHERE idestadoregistro = 1
  AND idpersona        = p_idpersona;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarpersonadirecciones(p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 484 (class 1255 OID 257949)
-- Name: fn_eliminarpersonadirecciones(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminarpersonadirecciones(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."PersonaDireccion"
SET 
  idestadoregistro     = 0
WHERE idestadoregistro = 1
  AND idpersona        = p_idpersona;

return false;

end;
$$;


ALTER FUNCTION negocio.fn_eliminarpersonadirecciones(p_idpersona integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 373 (class 1255 OID 256591)
-- Name: fn_eliminartelefonoscontacto(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminartelefonoscontacto(p_idcontacto integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."Telefono" 
SET
  idestadoregistro     = 0,
  usuariomodificacion  = p_usuariomodificacion,
  fechamodificacion    = fechahoy,
  ipmodificacion       = p_ipmodificacion
WHERE idestadoregistro = 1
  AND id               IN (SELECT idtelefono
                             FROM negocio."TelefonoPersona"
                            WHERE idpersona        = p_idcontacto
                              AND idestadoregistro = 1);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminartelefonoscontacto(p_idcontacto integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 374 (class 1255 OID 256592)
-- Name: fn_eliminartelefonosdireccion(integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_eliminartelefonosdireccion(p_iddireccion integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE 
  negocio."Telefono" 
SET 
  idestadoregistro     = 0,
  usuariomodificacion  = p_usuariomodificacion,
  fechamodificacion    = fechahoy,
  ipmodificacion       = p_ipmodificacion
WHERE idestadoregistro = 1
  AND id               IN (SELECT idtelefono
                             FROM negocio."TelefonoDireccion"
                            WHERE iddireccion      = p_iddireccion
                              AND idestadoregistro = 1);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_eliminartelefonosdireccion(p_iddireccion integer, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 491 (class 1255 OID 266161)
-- Name: fn_generaimparchivocargado(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_generaimparchivocargado(p_id integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT p.nombres, p.apellidopaterno, p.apellidomaterno, sd.numeroboleto
  FROM negocio."DetalleArchivoCargado" dac
 INNER JOIN negocio."ServicioDetalle" sd ON sd.codigoreserva = dac.campo1
 INNER JOIN negocio."ServicioCabecera" sc ON sc.id = sd.idservicio
 INNER JOIN negocio."Persona" p ON p.idtipopersona = 1 AND sc.idcliente1 = p.id
 WHERE idarchivo = p_id;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_generaimparchivocargado(p_id integer) OWNER TO postgres;

--
-- TOC entry 375 (class 1255 OID 256593)
-- Name: fn_generarcodigonovio(integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_generarcodigonovio(p_codigosnovios integer, p_usuario character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$

declare cod_novio character varying(20);
declare fechaserie character varying(4);

Begin


select to_char(fecnacimiento,'ddMM')
  into fechaserie
  from seguridad.usuario
 where usuario = p_usuario;

cod_novio = fechaserie || p_codigosnovios;

return cod_novio;

end;
$$;


ALTER FUNCTION negocio.fn_generarcodigonovio(p_codigosnovios integer, p_usuario character varying) OWNER TO postgres;

--
-- TOC entry 376 (class 1255 OID 256594)
-- Name: fn_generarcronogramapago(integer, date, numeric, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_generarcronogramapago(p_idservicio integer, p_fechaprimervencimiento date, p_montototal numeric, p_tea numeric, p_nrocuotas numeric, p_usuariocrecion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare nrocuota integer = 1;
declare valorcuota decimal = 0;
declare capital decimal = 0;
declare interes decimal = 0;
declare fecvencimiento date = p_fechaprimervencimiento;
declare tasamensual decimal = 0;
declare saldo decimal = p_montototal;


Begin

select negocio.fn_calcularcuota(p_montototal,p_nrocuotas,p_tea) into valorcuota;
select negocio.fn_calculartem(p_tea) into tasamensual;

LOOP

    interes = saldo * tasamensual;
    capital = valorcuota - interes;

    PERFORM negocio.fn_ingresarcuotacronograma(
    nrocuota,
    p_idservicio,
    fecvencimiento,
    capital,
    interes,
    valorcuota,
    1,
    p_usuariocrecion,
    p_ipcreacion);

    nrocuota = nrocuota + 1;
    fecvencimiento = (fecvencimiento + (1 || ' month')::INTERVAL);
    saldo = saldo - capital;
    
    EXIT WHEN cast(nrocuota as decimal) > p_nrocuotas;  
END LOOP;

update negocio."ServicioCabecera" set fechaultcuota = fecvencimiento where id = p_idservicio;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_generarcronogramapago(p_idservicio integer, p_fechaprimervencimiento date, p_montototal numeric, p_tea numeric, p_nrocuotas numeric, p_usuariocrecion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 377 (class 1255 OID 256595)
-- Name: fn_ingresainvitado(character varying, character varying, character varying, date, character varying, character varying, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresainvitado(p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_fecnacimiento date, p_telefono character varying, p_correoelectronico character varying, p_idnovios integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_personapotencial');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Personapotencial"(
            id, nombres, apellidopaterno, apellidomaterno, 
            fecnacimiento, telefono, correoelectronico, idnovios, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, p_nombres, p_apellidopaterno, p_apellidomaterno, 
            p_fecnacimiento, p_telefono, p_correoelectronico, p_idnovios, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresainvitado(p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_fecnacimiento date, p_telefono character varying, p_correoelectronico character varying, p_idnovios integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 378 (class 1255 OID 256596)
-- Name: fn_ingresararchivocargado(character varying, character varying, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_archivocargado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ArchivoCargado"(
            id, nombrearchivo, nombrereporte, idproveedor, numerofilas, numerocolumnas, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombrearchivo, p_nombrereporte, p_idproveedor, p_numerofilas, p_numerocolumnas, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 488 (class 1255 OID 266183)
-- Name: fn_ingresararchivocargado(character varying, character varying, integer, integer, integer, integer, numeric, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_archivocargado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ArchivoCargado"(
            id, nombrearchivo, nombrereporte, idproveedor, numerofilas, numerocolumnas, idmoneda, montosubtotal, montoigv, montototal, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombrearchivo, p_nombrereporte, p_idproveedor, p_numerofilas, p_numerocolumnas, p_idmoneda, p_montosubtotal, p_montoIGV, p_montototal, p_usuariocreacion, 
	    fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 379 (class 1255 OID 256597)
-- Name: fn_ingresarcomprobanteadicional(integer, integer, character varying, integer, character varying, date, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcomprobanteadicional(p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_detallecomprobante character varying, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare cantidad integer;


Begin

select count(1)
  into cantidad
  from negocio."ComprobanteAdicional"
 where numerocomprobante = p_numerocomprobante;

if cantidad > 0 then
   raise USING MESSAGE = 'El número de comprobante ya se encuentra registrado';
end if;

maxid = nextval('negocio.seq_comprobanteadicional');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ComprobanteAdicional"(
            id, idservicio, idtipocomprobante, numerocomprobante, idtitular, 
            detallecomprobante, fechacomprobante, totaligv, totalcomprobante, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idservicio, p_idtipocomprobante, p_numerocomprobante, p_idtitular, p_detallecomprobante, 
            p_fechacomprobante, p_totaligv, p_totalcomprobante, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcomprobanteadicional(p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_detallecomprobante character varying, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 498 (class 1255 OID 266419)
-- Name: fn_ingresarcomprobantegenerado(integer, integer, character varying, integer, date, numeric, numeric, boolean, boolean, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcomprobantegenerado(p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_idmoneda integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare cantidad integer;


Begin

select count(1)
  into cantidad
  from negocio."ComprobanteGenerado"
 where numerocomprobante = p_numerocomprobante;

if cantidad > 0 then
   raise USING MESSAGE = 'El número de comprobante ya se encuentra registrado';
end if;

maxid = nextval('negocio.seq_comprobantegenerado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ComprobanteGenerado"(
            id, idservicio, idtipocomprobante, numerocomprobante, idtitular, fechacomprobante, idmoneda,
            totaligv, totalcomprobante, tienedetraccion, tieneretencion, usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idservicio, p_idtipocomprobante, p_numerocomprobante, p_idtitular, p_fechacomprobante, p_idmoneda,
            p_totaligv, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcomprobantegenerado(p_idservicio integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_idtitular integer, p_fechacomprobante date, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_idmoneda integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 381 (class 1255 OID 256599)
-- Name: fn_ingresarconsolidador(character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarconsolidador(p_nombre character varying, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_consolidador');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Consolidador"(
            id, nombre, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombre, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);


return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarconsolidador(p_nombre character varying, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 382 (class 1255 OID 256600)
-- Name: fn_ingresarcontactoproveedor(integer, integer, integer, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcontactoproveedor(p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."PersonaContactoProveedor"(
            idproveedor, idcontacto, idarea, anexo)
    VALUES (p_idproveedor, p_idcontacto, p_idarea, p_anexo);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcontactoproveedor(p_idproveedor integer, p_idcontacto integer, p_idarea integer, p_anexo character varying) OWNER TO postgres;

--
-- TOC entry 383 (class 1255 OID 256601)
-- Name: fn_ingresarcorreoelectronico(character varying, integer, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcorreoelectronico(p_correo character varying, p_idpersona integer, p_recibirpromociones boolean, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxcorreo integer = 0;
declare fechahoy timestamp with time zone;

begin

maxcorreo = nextval('negocio.seq_correoelectronico');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."CorreoElectronico"(
            id, correo, idpersona, recibirpromociones, usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxcorreo, p_correo, p_idpersona, p_recibirpromociones, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion);

return maxcorreo;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcorreoelectronico(p_correo character varying, p_idpersona integer, p_recibirpromociones boolean, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 384 (class 1255 OID 256602)
-- Name: fn_ingresarcuentabancariaproveedor(character varying, character varying, integer, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcuentabancariaproveedor(p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_idproveedor integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
declare maxid integer;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;
maxid = nextval('negocio.seq_cuentabancariaproveedor');

INSERT INTO negocio."ProveedorCuentaBancaria"(
            id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, 
            idproveedor, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombrecuenta, p_numerocuenta, p_idtipocuenta, p_idbanco, p_idmoneda, 
            p_idproveedor, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcuentabancariaproveedor(p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_idproveedor integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 385 (class 1255 OID 256603)
-- Name: fn_ingresarcuotacronograma(integer, integer, date, double precision, double precision, double precision, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarcuotacronograma(p_nrocuota integer, p_idservicio integer, p_fechavencimiento date, p_capital double precision, p_interes double precision, p_totalcuota double precision, p_idestadocuota integer, p_usuariocrecion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."CronogramaPago"(
            nrocuota, idservicio, fechavencimiento, capital, interes, totalcuota, 
            idestadocuota, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (p_nrocuota, p_idservicio, p_fechavencimiento, p_capital, p_interes, p_totalcuota, 
            p_idestadocuota, p_usuariocrecion, fechahoy, p_ipcreacion, p_usuariocrecion, 
            fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarcuotacronograma(p_nrocuota integer, p_idservicio integer, p_fechavencimiento date, p_capital double precision, p_interes double precision, p_totalcuota double precision, p_idestadocuota integer, p_usuariocrecion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 386 (class 1255 OID 256604)
-- Name: fn_ingresardetallearchivocargado(integer, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, boolean, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardetallearchivocargado(p_idarchivo integer, p_campo1 character varying, p_campo2 character varying, p_campo3 character varying, p_campo4 character varying, p_campo5 character varying, p_campo6 character varying, p_campo7 character varying, p_campo8 character varying, p_campo9 character varying, p_campo10 character varying, p_campo11 character varying, p_campo12 character varying, p_campo13 character varying, p_campo14 character varying, p_campo15 character varying, p_campo16 character varying, p_campo17 character varying, p_campo18 character varying, p_campo19 character varying, p_campo20 character varying, p_seleccionado boolean, p_idtipocomprobante integer, p_numerocomprobante character varying, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_detallearchivocargado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."DetalleArchivoCargado"(
            id, idarchivo, campo1, campo2, campo3, campo4, campo5, campo6, 
            campo7, campo8, campo9, campo10, campo11, campo12, campo13, campo14, 
            campo15, campo16, campo17, campo18, campo19, campo20, seleccionado, idtipocomprobante, numerocomprobante,
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idarchivo, p_campo1, p_campo2, p_campo3, p_campo4, p_campo5, p_campo6, 
            p_campo7, p_campo8, p_campo9, p_campo10, p_campo11, p_campo12, p_campo13, p_campo14, 
            p_campo15, p_campo16, p_campo17, p_campo18, p_campo19, p_campo20, p_seleccionado, p_idtipocomprobante, p_numerocomprobante, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardetallearchivocargado(p_idarchivo integer, p_campo1 character varying, p_campo2 character varying, p_campo3 character varying, p_campo4 character varying, p_campo5 character varying, p_campo6 character varying, p_campo7 character varying, p_campo8 character varying, p_campo9 character varying, p_campo10 character varying, p_campo11 character varying, p_campo12 character varying, p_campo13 character varying, p_campo14 character varying, p_campo15 character varying, p_campo16 character varying, p_campo17 character varying, p_campo18 character varying, p_campo19 character varying, p_campo20 character varying, p_seleccionado boolean, p_idtipocomprobante integer, p_numerocomprobante character varying, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 389 (class 1255 OID 256605)
-- Name: fn_ingresardetallecomprobantegenerado(integer, integer, integer, character varying, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardetallecomprobantegenerado(idserviciodetalle integer, p_idcomprobante integer, p_cantidad integer, p_detalleconcepto character varying, p_preciounitario numeric, p_totaldetalle numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_detallecomprobantegenerado');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."DetalleComprobanteGenerado"(
            id, idserviciodetalle, idcomprobante, cantidad, detalleconcepto, preciounitario, 
            totaldetalle, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, idserviciodetalle, p_idcomprobante, p_cantidad, p_detalleconcepto, p_preciounitario, 
            p_totaldetalle, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardetallecomprobantegenerado(idserviciodetalle integer, p_idcomprobante integer, p_cantidad integer, p_detalleconcepto character varying, p_preciounitario numeric, p_totaldetalle numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 390 (class 1255 OID 256606)
-- Name: fn_ingresardireccion(integer, character varying, character varying, character varying, character varying, character varying, character varying, character, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresardireccion(p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion character varying, p_ipcreacion character varying, p_observacion character varying, p_referencia character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxdireccion integer;
declare fechahoy timestamp with time zone;

begin

select coalesce(max(id),0)
  into maxdireccion
  from negocio."Direccion";

maxdireccion = nextval('negocio.seq_direccion');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Direccion"(id, idvia, nombrevia, numero, interior, manzana, lote, principal, idubigeo, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion, observacion, referencia)
values (maxdireccion,p_idvia,p_nombrevia,p_numero,p_interior,p_manzana,p_lote,p_principal,p_idubigeo,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion, p_observacion, p_referencia);

return maxdireccion;

end;
$$;


ALTER FUNCTION negocio.fn_ingresardireccion(p_idvia integer, p_nombrevia character varying, p_numero character varying, p_interior character varying, p_manzana character varying, p_lote character varying, p_principal character varying, p_idubigeo character, p_usuariocreacion character varying, p_ipcreacion character varying, p_observacion character varying, p_referencia character varying) OWNER TO postgres;

--
-- TOC entry 391 (class 1255 OID 256607)
-- Name: fn_ingresarobligacionxpagar(integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_obligacionxpagar');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ObligacionesXPagar"(
            id, idtipocomprobante, numerocomprobante, idproveedor, fechacomprobante, 
            fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, tieneretencion, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, p_idtipocomprobante, p_numerocomprobante, p_idproveedor, p_fechacomprobante, 
            p_fechapago, p_detallecomprobante, p_totaligv, p_totalcomprobante, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 392 (class 1255 OID 256608)
-- Name: fn_ingresarpais(character varying, integer, character varying, character varying, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpais(p_descripcion character varying, p_idcontinente integer, p_usuariocreacion character varying, p_ipcreacion character varying, p_fecnacimiento date) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxpais integer;
declare fechahoy timestamp with time zone;

begin

maxpais = nextval('negocio.seq_pais');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.pais(
            id, descripcion, idcontinente, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion, 
            idestadoregistro)
    VALUES (maxpais, p_descripcion, p_idcontinente, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, 1);

return maxpais;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarpais(p_descripcion character varying, p_idcontinente integer, p_usuariocreacion character varying, p_ipcreacion character varying, p_fecnacimiento date) OWNER TO postgres;

--
-- TOC entry 393 (class 1255 OID 256609)
-- Name: fn_ingresarpais(integer, character varying, integer, date, date, character varying, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpais(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_obligacionxpagar');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ObligacionesXPagar"(
            id, idtipocomprobante, numerocomprobante, idproveedor, fechacomprobante, 
            fechapago, detallecomprobante, totaligv, totalcomprobante, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, p_idtipocomprobante, p_numerocomprobante, p_idproveedor, p_fechacomprobante, 
            p_fechapago, p_detallecomprobante, p_totaligv, p_totalcomprobante, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarpais(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 497 (class 1255 OID 266416)
-- Name: fn_ingresarpasajero(character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpasajero(p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_correoelectronico character varying, p_telefono1 character varying, p_telefono2 character varying, p_nropaxfrecuente character varying, p_idrelacion integer, p_idaerolinea integer, p_idserviciodetalle integer, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_pax');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PasajeroServicio"(
            id, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
            telefono1, telefono2, nropaxfrecuente, idrelacion, idaerolinea, idserviciodetalle, 
            idservicio, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_nombres, p_apellidopaterno, p_apellidomaterno, p_correoelectronico, 
            p_telefono1, p_telefono2, p_nropaxfrecuente, p_idrelacion, p_idaerolinea, p_idserviciodetalle, 
            p_idservicio, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarpasajero(p_nombres character varying, p_apellidopaterno character varying, p_apellidomaterno character varying, p_correoelectronico character varying, p_telefono1 character varying, p_telefono2 character varying, p_nropaxfrecuente character varying, p_idrelacion integer, p_idaerolinea integer, p_idserviciodetalle integer, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 394 (class 1255 OID 256610)
-- Name: fn_ingresarpersona(integer, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying, character varying, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersona(p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion character varying, p_ipcreacion character varying, p_fecnacimiento date) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxpersona integer;
declare fechahoy timestamp with time zone;

begin

maxpersona = nextval('negocio.seq_persona');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Persona"(id, idtipopersona, nombres, apellidopaterno, apellidomaterno, 
            idgenero, idestadocivil, idtipodocumento, numerodocumento, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion,fecnacimiento)
values (maxpersona,p_idtipopersona,p_nombres,p_apepaterno,p_apematerno,p_idgenero,p_idestadocivil,p_idtipodocumento,p_numerodocumento,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion,p_fecnacimiento);

return maxpersona;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarpersona(p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion character varying, p_ipcreacion character varying, p_fecnacimiento date) OWNER TO postgres;

--
-- TOC entry 396 (class 1255 OID 256611)
-- Name: fn_ingresarpersona(integer, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying, character varying, date, character varying, date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersona(p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion character varying, p_ipcreacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxpersona integer;
declare fechahoy timestamp with time zone;

begin

maxpersona = nextval('negocio.seq_persona');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

insert into negocio."Persona"(id, idtipopersona, nombres, apellidopaterno, apellidomaterno, 
            idgenero, idestadocivil, idtipodocumento, numerodocumento, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion,fecnacimiento, nropasaporte, fecvctopasaporte)
values (maxpersona,p_idtipopersona,p_nombres,p_apepaterno,p_apematerno,p_idgenero,p_idestadocivil,p_idtipodocumento,p_numerodocumento,p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion,p_fecnacimiento, p_nropasaporte, p_fecvctopasaporte);

return maxpersona;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarpersona(p_idtipopersona integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_idgenero character varying, p_idestadocivil integer, p_idtipodocumento integer, p_numerodocumento character varying, p_usuariocreacion character varying, p_ipcreacion character varying, p_fecnacimiento date, p_nropasaporte character varying, p_fecvctopasaporte date) OWNER TO postgres;

--
-- TOC entry 397 (class 1255 OID 256612)
-- Name: fn_ingresarpersonadireccion(integer, integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersonadireccion(p_idpersona integer, p_idtipopersona integer, p_iddireccion integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."PersonaDireccion"(
            idpersona, iddireccion, idtipopersona)
    VALUES (p_idpersona, p_iddireccion, p_idtipopersona);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarpersonadireccion(p_idpersona integer, p_idtipopersona integer, p_iddireccion integer) OWNER TO postgres;

--
-- TOC entry 398 (class 1255 OID 256613)
-- Name: fn_ingresarpersonaproveedor(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarpersonaproveedor(p_idpersona integer, p_idrubro integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."PersonaAdicional"(idpersona, idrubro)
    VALUES (p_idpersona, p_idrubro);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarpersonaproveedor(p_idpersona integer, p_idrubro integer) OWNER TO postgres;

--
-- TOC entry 399 (class 1255 OID 256614)
-- Name: fn_ingresarprogramanovios(integer, integer, integer, date, date, integer, numeric, integer, integer, date, text, numeric, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarprogramanovios(p_idnovia integer, p_idnovio integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare cod_novio character varying(20);

Begin

maxid = nextval('negocio.seq_novios');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;
cod_novio = negocio.fn_generarcodigonovio(maxid,p_usuariocreacion);

INSERT INTO negocio."ProgramaNovios"(
            id, codigonovios, idnovia, idnovio, iddestino, fechaboda, fechaviaje, 
            idmoneda, cuotainicial, dias, noches, fechashower, observaciones, 
            montototal, idservicio, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, cod_novio, p_idnovia, p_idnovio, p_iddestino, p_fechaboda, p_fechaviaje, p_idmoneda, p_cuotainicial, p_dias, p_noches, p_fechashower, 
	    p_observaciones, p_montototal, p_idservicio, p_usuariocreacion, 
	    fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarprogramanovios(p_idnovia integer, p_idnovio integer, p_iddestino integer, p_fechaboda date, p_fechaviaje date, p_idmoneda integer, p_cuotainicial numeric, p_dias integer, p_noches integer, p_fechashower date, p_observaciones text, p_montototal numeric, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 400 (class 1255 OID 256615)
-- Name: fn_ingresarproveedortipo(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarproveedortipo(p_idpersona integer, p_idtipoproveedor integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_consolidador');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ProveedorPersona"(
            idproveedor, idtipoproveedor, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (p_idpersona, p_idtipoproveedor, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarproveedortipo(p_idpersona integer, p_idtipoproveedor integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 401 (class 1255 OID 256616)
-- Name: fn_ingresarruta(integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarruta(p_idruta integer, p_idtramo integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."RutaServicio"(
            id, idtramo, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (p_idruta, p_idtramo, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarruta(p_idruta integer, p_idtramo integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 402 (class 1255 OID 256617)
-- Name: fn_ingresarservicio(character varying, character varying, character varying, boolean, integer, boolean, integer, boolean, boolean, numeric, character varying, character varying, integer, boolean, boolean); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarservicio(p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_cargaigv boolean, p_valorcomision numeric, p_usuariocreacion character varying, p_ipcreacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_maestroservicio');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."MaestroServicios"(
            id, nombre, desccorta, desclarga, requierefee, idmaeserfee, pagaimpto, 
            idmaeserimpto, cargacomision, cargaigv, valorporcomision, 
            usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion, idparametroasociado, visible, esserviciopadre)
    VALUES (maxid, p_nombreservicio, p_desccorta, p_desclarga, p_requierefee, p_idmaeserfee, p_pagaimpto, 
            p_idmaeserimpto, p_cargacomision, p_cargaigv, p_valorcomision, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idparametro, p_visible, p_serviciopadre);

return maxid;
end;
$$;


ALTER FUNCTION negocio.fn_ingresarservicio(p_nombreservicio character varying, p_desccorta character varying, p_desclarga character varying, p_requierefee boolean, p_idmaeserfee integer, p_pagaimpto boolean, p_idmaeserimpto integer, p_cargacomision boolean, p_cargaigv boolean, p_valorcomision numeric, p_usuariocreacion character varying, p_ipcreacion character varying, p_idparametro integer, p_visible boolean, p_serviciopadre boolean) OWNER TO postgres;

--
-- TOC entry 405 (class 1255 OID 256618)
-- Name: fn_ingresarserviciocabecera(integer, integer, date, numeric, numeric, numeric, numeric, integer, integer, integer, numeric, numeric, date, date, integer, integer, text, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarserviciocabecera(p_idcliente1 integer, p_idcliente2 integer, p_fechaservicio date, p_montototaligv numeric, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idmoneda integer, p_idvendedor integer, p_observacion text, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_serviciocabecera');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ServicioCabecera"(
            id, idcliente1, idcliente2, fechacompra,
            idestadopago, idestadoservicio, nrocuotas, tea, valorcuota, 
            fechaprimercuota, fechaultcuota, idmoneda, montocomisiontotal, 
            montototaligv, montototal, montototalfee, idvendedor, observaciones, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idcliente1, p_idcliente2, p_fechaservicio,
            p_idestadopago, p_idestadoservicio, p_nrocuotas, p_tea, p_valorcuota, 
            p_fechaprimercuota, p_fechaultcuota, p_idmoneda, p_montototalcomision, 
            p_montototaligv, p_montototal, p_montototalfee, p_idvendedor, p_observacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, 
            fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarserviciocabecera(p_idcliente1 integer, p_idcliente2 integer, p_fechaservicio date, p_montototaligv numeric, p_montototal numeric, p_montototalfee numeric, p_montototalcomision numeric, p_idestadopago integer, p_idestadoservicio integer, p_nrocuotas integer, p_tea numeric, p_valorcuota numeric, p_fechaprimercuota date, p_fechaultcuota date, p_idmoneda integer, p_idvendedor integer, p_observacion text, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 487 (class 1255 OID 257995)
-- Name: fn_ingresarserviciodetalle(integer, character varying, integer, timestamp with time zone, timestamp with time zone, integer, integer, character varying, integer, character varying, integer, character varying, integer, character varying, integer, integer, numeric, numeric, numeric, boolean, boolean, numeric, numeric, character varying, numeric, character varying, integer, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarserviciodetalle(p_idtiposervicio integer, p_descripcionservicio character varying, p_idservicio integer, p_fechaida timestamp with time zone, p_fecharegreso timestamp with time zone, p_cantidad integer, p_idproveedor integer, p_descripcionproveedor character varying, p_idoperador integer, p_descripcionoperador character varying, p_idempresatransporte integer, p_descripcionemptransporte character varying, p_idhotel integer, p_decripcionhotel character varying, p_idruta integer, p_idmoneda integer, p_preciounitarioanterior numeric, p_tipocambio numeric, p_preciounitario numeric, p_editocomision boolean, p_tarifanegociada boolean, p_porcencomision numeric, p_montocomision numeric, p_codigoreserva character varying, p_montototal numeric, p_numeroboleto character varying, p_idservdetdepende integer, p_aplicaigv boolean, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_serviciodetalle');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ServicioDetalle"(
            id, idtiposervicio, descripcionservicio, idservicio, fechaida, 
            fecharegreso, cantidad, idempresaproveedor, descripcionproveedor, 
            idempresaoperadora, descripcionoperador, idempresatransporte, descripcionemptransporte, idhotel, decripcionhotel,
            idruta, idmoneda, preciobaseanterior, tipocambio, preciobase, editocomision, tarifanegociada, 
            porcencomision, montocomision, montototal, codigoreserva, numeroboleto, idservdetdepende, aplicaigv,
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idtiposervicio, p_descripcionservicio, p_idservicio, p_fechaida, 
            p_fecharegreso, p_cantidad, p_idproveedor, p_descripcionproveedor, 
            p_idoperador, p_descripcionoperador, p_idempresatransporte, p_descripcionemptransporte, p_idhotel, p_decripcionhotel,
            p_idruta, p_idmoneda, p_preciounitarioanterior, p_tipocambio, p_preciounitario, p_editocomision, p_tarifanegociada,
            p_porcencomision, p_montocomision, p_montototal, p_codigoreserva, p_numeroboleto, p_idservdetdepende, p_aplicaigv,
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarserviciodetalle(p_idtiposervicio integer, p_descripcionservicio character varying, p_idservicio integer, p_fechaida timestamp with time zone, p_fecharegreso timestamp with time zone, p_cantidad integer, p_idproveedor integer, p_descripcionproveedor character varying, p_idoperador integer, p_descripcionoperador character varying, p_idempresatransporte integer, p_descripcionemptransporte character varying, p_idhotel integer, p_decripcionhotel character varying, p_idruta integer, p_idmoneda integer, p_preciounitarioanterior numeric, p_tipocambio numeric, p_preciounitario numeric, p_editocomision boolean, p_tarifanegociada boolean, p_porcencomision numeric, p_montocomision numeric, p_codigoreserva character varying, p_montototal numeric, p_numeroboleto character varying, p_idservdetdepende integer, p_aplicaigv boolean, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 406 (class 1255 OID 256620)
-- Name: fn_ingresarserviciomaestroservicio(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarserviciomaestroservicio(p_idservicio integer, p_idserviciodepente integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare cantidad integer;

Begin

select count(1)
  into cantidad
  from negocio."ServicioMaestroServicio"
 where idservicio        = p_idservicio
   and idserviciodepende = p_idserviciodepente;

if cantidad = 0 then
INSERT INTO negocio."ServicioMaestroServicio"(
            idservicio, idserviciodepende)
    VALUES (p_idservicio, p_idserviciodepente);

end if;

    

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarserviciomaestroservicio(p_idservicio integer, p_idserviciodepente integer) OWNER TO postgres;

--
-- TOC entry 407 (class 1255 OID 256621)
-- Name: fn_ingresarservicioproveedor(integer, integer, integer, numeric, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresarservicioproveedor(p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ProveedorTipoServicio"(
            idproveedor, idtiposervicio, idproveedorservicio, porcencomnacional, porcencominternacional, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (p_idproveedor, p_idtiposervicio, p_idproveedorservicio, p_porcencomision, p_porcencominternacional, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresarservicioproveedor(p_idproveedor integer, p_idtiposervicio integer, p_idproveedorservicio integer, p_porcencomision numeric, p_porcencominternacional numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 408 (class 1255 OID 256622)
-- Name: fn_ingresartelefono(character varying, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefono(p_numero character varying, p_idempresaproveedor integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxtelefono integer;
declare fechahoy timestamp with time zone;

Begin

select coalesce(max(id),0)
  into maxtelefono
  from negocio."Telefono";

maxtelefono = nextval('negocio.seq_telefono');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Telefono"(
            id, numero, idempresaproveedor, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxtelefono, p_numero, p_idempresaproveedor, p_usuariocreacion,fechahoy,
	p_ipcreacion,p_usuariocreacion,fechahoy,p_ipcreacion);

return maxtelefono;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefono(p_numero character varying, p_idempresaproveedor integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 409 (class 1255 OID 256623)
-- Name: fn_ingresartelefonodireccion(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefonodireccion(p_idtelefono integer, p_iddireccion integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."TelefonoDireccion"(
            idtelefono, iddireccion)
    VALUES (p_idtelefono, p_iddireccion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefonodireccion(p_idtelefono integer, p_iddireccion integer) OWNER TO postgres;

--
-- TOC entry 410 (class 1255 OID 256624)
-- Name: fn_ingresartelefonopersona(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartelefonopersona(p_idtelefono integer, p_idpersona integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

Begin

INSERT INTO negocio."TelefonoPersona"(
            idtelefono, idpersona)
    VALUES (p_idtelefono, p_idpersona);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartelefonopersona(p_idtelefono integer, p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 411 (class 1255 OID 256625)
-- Name: fn_ingresartipocambio(date, integer, integer, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartipocambio(p_fecha date, p_idmonedaorigen integer, p_idmonedadestino integer, p_montocambio numeric, p_usuariocreacion character varying, p_ipcrecion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_tipocambio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."TipoCambio"(
            id, fechatipocambio, idmonedaorigen, idmonedadestino, montocambio, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_fecha, p_idmonedaorigen, p_idmonedadestino, p_montocambio, 
            p_usuariocreacion, fechahoy, p_ipcrecion, p_usuariocreacion, fechahoy, p_ipcrecion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartipocambio(p_fecha date, p_idmonedaorigen integer, p_idmonedadestino integer, p_montocambio numeric, p_usuariocreacion character varying, p_ipcrecion character varying) OWNER TO postgres;

--
-- TOC entry 403 (class 1255 OID 256626)
-- Name: fn_ingresartramo(integer, character varying, timestamp with time zone, integer, character varying, timestamp with time zone, numeric, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_ingresartramo(p_idorigen integer, p_descripcionorigen character varying, p_fechasalida timestamp with time zone, p_iddestino integer, p_descripciondestino character varying, p_fechallegada timestamp with time zone, p_preciobase numeric, p_idaerolinea integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_tramo');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."Tramo"(
            id, idorigen, descripcionorigen, fechasalida, iddestino, descripciondestino, 
            fechallegada, preciobase, idaerolinea, usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idorigen, p_descripcionorigen, p_fechasalida, p_iddestino, p_descripciondestino, 
            p_fechallegada, p_preciobase, p_idaerolinea, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_ingresartramo(p_idorigen integer, p_descripcionorigen character varying, p_fechasalida timestamp with time zone, p_iddestino integer, p_descripciondestino character varying, p_fechallegada timestamp with time zone, p_preciobase numeric, p_idaerolinea integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 395 (class 1255 OID 256627)
-- Name: fn_listarclientescorreo(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarclientescorreo() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select cli.id as idcliente, cli.nombres as nomcliente, cli.apellidopaterno as apepatcliente, cli.apellidomaterno as apematcliente, 
       con.id as idcontacto, con.nombres as nomcontacto, con.apellidopaterno as apepatcontacto, con.apellidomaterno as apematcontacto,
       cor.correo, cor.recibirpromociones
  from negocio.vw_clientesnova cli,
       negocio."PersonaContactoProveedor" pccli,
       negocio.vw_consultacontacto con,
       negocio."CorreoElectronico" cor
 where cli.id                 = pccli.idproveedor
   and pccli.idestadoregistro = 1
   and pccli.idcontacto       = con.id
   and cor.idpersona          = con.id
   and cor.correo             is not null
   and cor.correo             <> '';

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarclientescorreo() OWNER TO postgres;

--
-- TOC entry 404 (class 1255 OID 256628)
-- Name: fn_listarclientescumples(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarclientescumples() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
select * 
  from negocio.vw_clientesnova
 where to_char(fecnacimiento,'ddMM') = to_char(current_date,'ddMM');

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarclientescumples() OWNER TO postgres;

--
-- TOC entry 412 (class 1255 OID 256629)
-- Name: fn_listarconsolidadores(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarconsolidadores() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
       fechamodificacion, ipmodificacion
  FROM negocio."Consolidador"
 WHERE idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarconsolidadores() OWNER TO postgres;

--
-- TOC entry 413 (class 1255 OID 256630)
-- Name: fn_listarcuentasbancarias(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarcuentasbancarias() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT cb.id, cb.nombrecuenta, cb.numerocuenta, cb.idtipocuenta, tmtc.nombre as nombretipocuenta, cb.idbanco, tmba.nombre as nombrebanco, 
       cb.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura, cb.saldocuenta, 
       (SELECT COUNT(1)
          FROM negocio."MovimientoCuenta" mc
         WHERE mc.idcuenta = cb.id) numeroMovimientos,
       cb.usuariocreacion, cb.fechacreacion, cb.ipcreacion, cb.usuariomodificacion, cb.fechamodificacion, cb.ipmodificacion
  FROM negocio."CuentaBancaria" cb,
       soporte."Tablamaestra" tmtc,
       soporte."Tablamaestra" tmba,
       soporte."Tablamaestra" tmmo
 WHERE idestadoregistro = 1
   AND tmtc.idmaestro   = 21
   AND cb.idtipocuenta  = tmtc.id
   AND tmba.idmaestro   = 19
   AND cb.idbanco       = tmba.id
   AND tmmo.idmaestro   = 20
   AND cb.idmoneda      = tmmo.id;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarcuentasbancarias() OWNER TO postgres;

--
-- TOC entry 490 (class 1255 OID 256631)
-- Name: fn_listarcuentasbancariascombo(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarcuentasbancariascombo() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT cb.id, cb.nombrecuenta
  FROM negocio."CuentaBancaria" cb
 WHERE idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarcuentasbancariascombo() OWNER TO postgres;

--
-- TOC entry 414 (class 1255 OID 256632)
-- Name: fn_listarcuentasbancariasproveedor(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarcuentasbancariasproveedor(p_idproveedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, 
       idproveedor 
  FROM negocio."ProveedorCuentaBancaria" pcb
 WHERE idestadoregistro = 1
   AND idproveedor      = p_idproveedor;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarcuentasbancariasproveedor(p_idproveedor integer) OWNER TO postgres;

--
-- TOC entry 415 (class 1255 OID 256633)
-- Name: fn_listardocumentosadicionales(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listardocumentosadicionales(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT das.id, idservicio, idtipodocumento, tm.nombre as nombredocumento, descripciondocumento, archivo, nombrearchivo, tipocontenido, 
       extensionarchivo, usuariocreacion, fechacreacion, ipcreacion, 
       usuariomodificacion, fechamodificacion, ipmodificacion, idestadoregistro
  FROM negocio."DocumentoAdjuntoServicio" das,
       soporte."Tablamaestra" tm
 where das.idservicio      = p_idservicio
   and das.idtipodocumento = tm.id
   and tm.idmaestro        = 18;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listardocumentosadicionales(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 416 (class 1255 OID 256634)
-- Name: fn_listarmaestroservicios(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroservicios() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE visible          = true
   AND idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroservicios() OWNER TO postgres;

--
-- TOC entry 417 (class 1255 OID 256635)
-- Name: fn_listarmaestroserviciosadm(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosadm() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosadm() OWNER TO postgres;

--
-- TOC entry 418 (class 1255 OID 256636)
-- Name: fn_listarmaestroserviciosfee(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosfee() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND esfee            = TRUE;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosfee() OWNER TO postgres;

--
-- TOC entry 419 (class 1255 OID 256637)
-- Name: fn_listarmaestroserviciosigv(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosigv() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND esimpuesto       = TRUE;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosigv() OWNER TO postgres;

--
-- TOC entry 420 (class 1255 OID 256638)
-- Name: fn_listarmaestroserviciosimpto(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmaestroserviciosimpto() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, nombre, desccorta, desclarga, requierefee, pagaimpto, cargacomision, esserviciopadre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   AND esimpuesto       = TRUE;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmaestroserviciosimpto() OWNER TO postgres;

--
-- TOC entry 421 (class 1255 OID 256639)
-- Name: fn_listarmovimientosxcuenta(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarmovimientosxcuenta(p_idcuenta integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT id, 
       idcuenta, 
       idtipomovimiento, 
       (CASE idtipomovimiento WHEN 1 THEN 'Ingreso' ELSE 'Egreso' END) as desTipoMovimiento,
       idtransaccion, 
       tmtt.nombre as nombreTransaccion,
       descripcionnovimiento, 
       importemovimiento, 
       idautorizador, 
       idmovimientopadre, 
       usuariocreacion, 
       fechacreacion, 
       ipcreacion, 
       usuariomodificacion, 
       fechamodificacion, 
       ipmodificacion
  FROM negocio."MovimientoCuenta" mc
 INNER JOIN negocio."CuentaBancaria" cb ON cb.idestadoregistro = 1  AND mc.idcuenta = cb.id
 INNER JOIN soporte."Tablamaestra" tmtt ON tmtt.idmaestro      = 13 AND tmtt.id     = idtransaccion
 WHERE mc.idcuenta = p_idcuenta;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarmovimientosxcuenta(p_idcuenta integer) OWNER TO postgres;

--
-- TOC entry 422 (class 1255 OID 256640)
-- Name: fn_listarpagos(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarpagos(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idservicio, ps.idformapago, tmfp.nombre as nombreformapago, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, espagoretencion, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."PagosServicio" ps
 INNER JOIN soporte."Tablamaestra" tmfp ON ps.idformapago = tmfp.id AND tmfp.idmaestro = 13
 WHERE idestadoregistro = 1
   AND idservicio       = p_idservicio
 ORDER BY idpago DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarpagos(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 423 (class 1255 OID 256641)
-- Name: fn_listarpagosobligaciones(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listarpagosobligaciones(p_idobligacion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idobligacion, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, espagoretencion, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."PagosObligacion"
 WHERE idestadoregistro = 1
   AND idobligacion     = p_idobligacion
 ORDER BY idpago DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listarpagosobligaciones(p_idobligacion integer) OWNER TO postgres;

--
-- TOC entry 380 (class 1255 OID 256642)
-- Name: fn_listartipocambio(date); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_listartipocambio(p_fecha date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$

declare micursor refcursor;

begin

open micursor for
SELECT tc.id, fechatipocambio, 
       idmonedaorigen, tmmo.nombre as nombreMonOrigen, 
       idmonedadestino, tmmd.nombre as nombreMonDestino, 
       montocambio
  FROM negocio."TipoCambio" tc
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = 20 AND tmmo.id = idmonedaorigen
 INNER JOIN soporte."Tablamaestra" tmmd ON tmmd.idmaestro = 20 AND tmmd.id = idmonedadestino
 WHERE fechatipocambio = COALESCE(p_fecha,fechatipocambio)
 ORDER BY tc.id DESC;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_listartipocambio(p_fecha date) OWNER TO postgres;

--
-- TOC entry 424 (class 1255 OID 256643)
-- Name: fn_proveedorxservicio(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_proveedorxservicio(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT per.id, per.nombres, proser.porcencomnacional, proser.porcencominternacional
  FROM negocio."Persona" per,
       negocio."ProveedorTipoServicio" proser
 WHERE per.idestadoregistro    = 1 
   AND proser.idestadoregistro = 1 
   AND per.idtipopersona       = 2
   AND per.id                  = proser.idproveedor
   AND proser.idtiposervicio   = p_idservicio;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_proveedorxservicio(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 425 (class 1255 OID 256644)
-- Name: fn_registrarcomprobanteobligacion(integer, integer, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarcomprobanteobligacion(p_idcomprobante integer, p_idobligacion integer, p_iddetalleservicio integer, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

Begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ComprobanteObligacion"(
            idcomprobante, idobligacion, iddetalleservicio, idservicio, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (p_idcomprobante, p_idobligacion, p_iddetalleservicio, p_idservicio, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrarcomprobanteobligacion(p_idcomprobante integer, p_idobligacion integer, p_iddetalleservicio integer, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 426 (class 1255 OID 256645)
-- Name: fn_registrarcuentabancaria(character varying, character varying, integer, integer, integer, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarcuentabancaria(p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_saldocuenta numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_cuentabancaria');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."CuentaBancaria"(
            id, nombrecuenta, numerocuenta, idtipocuenta, idbanco, idmoneda, saldocuenta, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, p_nombrecuenta, p_numerocuenta, p_idtipocuenta, p_idbanco, p_idmoneda, p_saldocuenta, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrarcuentabancaria(p_nombrecuenta character varying, p_numerocuenta character varying, p_idtipocuenta integer, p_idbanco integer, p_idmoneda integer, p_saldocuenta numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 427 (class 1255 OID 256646)
-- Name: fn_registrardocumentosustentoservicio(integer, integer, character varying, bytea, character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrardocumentosustentoservicio(p_idservicio integer, p_idtipodocumento integer, p_descripciondocumento character varying, p_archivo bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_documentoservicio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."DocumentoAdjuntoServicio"(
            id, idservicio, idtipodocumento, descripciondocumento, archivo, nombrearchivo, tipocontenido, 
            extensionarchivo, usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idservicio, p_idtipodocumento, p_descripciondocumento, p_archivo, p_nombrearchivo, p_tipocontenido, 
            p_extensionarchivo, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrardocumentosustentoservicio(p_idservicio integer, p_idtipodocumento integer, p_descripciondocumento character varying, p_archivo bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 428 (class 1255 OID 256647)
-- Name: fn_registrareventoservicio(integer, character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrareventoservicio(p_idtipoevento integer, p_comentario character varying, p_idservicio integer, p_estadonuevoservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

Begin

maxid = nextval('negocio.seq_eventoservicio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."EventoObsAnuServicio"(
            id, idtipoevento, comentario, idservicio, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idtipoevento, p_comentario, p_idservicio, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

UPDATE negocio."ServicioCabecera"
   SET idestadoservicio = p_estadonuevoservicio
 WHERE id               = p_idservicio;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_registrareventoservicio(p_idtipoevento integer, p_comentario character varying, p_idservicio integer, p_estadonuevoservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 429 (class 1255 OID 256648)
-- Name: fn_registrarmovimientocuenta(integer, integer, integer, character varying, numeric, integer, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarmovimientocuenta(p_idcuenta integer, p_idtipomovimiento integer, p_idtransaccion integer, p_descripcionnovimiento character varying, p_importemovimiento numeric, p_idautorizador integer, p_idmovimientopadre integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare v_saldocuenta decimal(20,6);
declare v_saldocuenta_actualiza decimal(20,6);
declare v_resultado boolean;

begin

maxid = nextval('negocio.seq_movimientocuenta');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."MovimientoCuenta"(
            id, idcuenta, idtipomovimiento, idtransaccion, descripcionnovimiento, 
            importemovimiento, idautorizador, idmovimientopadre, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, p_idcuenta, p_idtipomovimiento, p_idtransaccion, p_descripcionnovimiento, 
            p_importemovimiento, p_idautorizador, p_idmovimientopadre, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

SELECT saldocuenta
  INTO v_saldocuenta
  FROM negocio."CuentaBancaria"
 WHERE id = p_idcuenta;

if p_idtipomovimiento = 1 then -- ingreso
    v_saldocuenta_actualiza = v_saldocuenta + p_importemovimiento;
else -- egreso
    v_saldocuenta_actualiza = v_saldocuenta - p_importemovimiento;
end if;

select negocio.fn_actualizarcuentabancariasaldo(p_idcuenta, v_saldocuenta_actualiza, p_usuariocreacion, p_ipcreacion) into v_resultado;

return v_resultado;

end;
$$;


ALTER FUNCTION negocio.fn_registrarmovimientocuenta(p_idcuenta integer, p_idtipomovimiento integer, p_idtransaccion integer, p_descripcionnovimiento character varying, p_importemovimiento numeric, p_idautorizador integer, p_idmovimientopadre integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 430 (class 1255 OID 256649)
-- Name: fn_registrarpagoobligacion(integer, integer, integer, integer, integer, integer, character varying, character varying, date, character varying, numeric, integer, bytea, character varying, character varying, character varying, character varying, boolean, boolean, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarpagoobligacion(p_idobligacion integer, p_idformapago integer, p_idcuentaorigen integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuarioautoriza integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;
declare v_montocomprobante decimal(12,3);
declare v_montosaldo decimal(12,3);
declare v_montopagado decimal(12,3);
declare v_tipomovimiento integer;
declare v_tipotransaccion integer;
declare v_desctransaccion character varying;
declare v_registramovimiento boolean;

begin

maxid = nextval('negocio.seq_pago');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

SELECT totalcomprobante
  INTO v_montocomprobante
  FROM negocio."ObligacionesXPagar"
 WHERE id = p_idobligacion;

SELECT SUM(montopagado)
  into v_montopagado
  FROM negocio."PagosObligacion"
 WHERE idobligacion = p_idobligacion;

if v_montopagado is not null then
	v_montosaldo = v_montocomprobante - v_montopagado;
	IF v_montosaldo < p_montopago THEN
		raise USING MESSAGE = 'El monto a pagar es mayor que el saldo pendiente';
	END IF;
else
    v_montosaldo = v_montocomprobante - p_montopago;
end if;

INSERT INTO negocio."PagosObligacion"(
            idpago, idobligacion, idformapago, idcuentaorigen, idcuentadestino, idbancotarjeta, 
            idtipotarjeta, nombretitular, numerotarjeta, fechapago, numerooperacion, montopagado, idmoneda,
            sustentopago, tipocontenido, nombrearchivo, extensionarchivo, 
            comentario, espagodetraccion, espagoretencion, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (maxid, p_idobligacion, p_idformapago, p_idcuentaorigen, p_idcuentadestino, p_idbancotarjeta, 
            p_idtipotarjeta, p_nombretitular, p_numerotarjeta, p_fechapago, p_numerooperacion, p_montopago, p_idmoneda,
            p_sustentopago, p_tipocontenido, p_nombrearchivo, p_extensionarchivo, 
            p_comentario, p_espagodetraccion, p_espagoretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);


UPDATE negocio."ObligacionesXPagar"
   SET saldocomprobante = v_montosaldo
 WHERE id               = p_idobligacion;


-- 1: ingreso
-- 2: egreso
v_tipomovimiento = 2;
if p_idformapago = 2 then
    v_tipotransaccion = 1;-- deposito en cuenta
    v_desctransaccion = 'Deposito en cuenta';
elsif p_idformapago = 3 then
    v_tipotransaccion = 2;-- transferencia
    v_desctransaccion = 'Transferencia de fondos a cuenta';
end if;

select negocio.fn_registrarmovimientocuenta(p_idcuentaorigen, v_tipomovimiento, v_tipotransaccion, v_desctransaccion, p_montopago, 
p_usuarioautoriza, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_registrarpagoobligacion(p_idobligacion integer, p_idformapago integer, p_idcuentaorigen integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuarioautoriza integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 432 (class 1255 OID 256650)
-- Name: fn_registrarpagoservicio(integer, integer, integer, integer, integer, character varying, character varying, date, character varying, numeric, integer, bytea, character varying, character varying, character varying, character varying, boolean, boolean, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarpagoservicio(p_idservicio integer, p_idformapago integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare maxidss integer;
declare fechahoy timestamp with time zone;
declare montosaldo decimal(12,3);
declare montosaldofinal decimal(12,3);
declare fechaservicio date;
declare montoservicio decimal(12,3);
declare estadoPago integer;
declare v_tipotransaccion integer;
declare v_desctransaccion character varying;
declare v_registramovimiento boolean;
declare v_monedaservicio integer;
declare v_tipocambio decimal(12,3);
declare v_montoaplicar decimal(12,3);
declare v_registrotranstc integer;

begin

v_monedaservicio = 2;

select idestadopago
  into estadoPago
  from negocio."ServicioCabecera"
 where id = p_idservicio;

if estadoPago = 2 then
    raise USING MESSAGE = 'El servicio se encuentra pagado ya no acepta mas pagos';
end if;

select min(montosaldoservicio)
  into montosaldo
  from negocio."SaldosServicio" ss
 where ss.idservicio = p_idservicio;

if p_idmoneda <> v_monedaservicio then
    select negocio.fn_consultartipocambiomonto(p_idmoneda,v_monedaservicio) into v_tipocambio;
    v_montoaplicar = p_montopago * v_tipocambio;
else
    v_montoaplicar = p_montopago;
end if;

if v_montoaplicar > montosaldo then
   raise USING MESSAGE = 'El monto a pagar es mayor que el saldo pendiente';
end if;

maxid = nextval('negocio.seq_pago');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

select fechacompra, montototal
  into fechaservicio, montoservicio
  from negocio."ServicioCabecera"
 where id = p_idservicio;

if montosaldo is null then
    montosaldo = montoservicio;
end if;

INSERT INTO negocio."PagosServicio"(
            idpago, idservicio, idformapago, idcuentadestino, idbancotarjeta, idtipotarjeta, 
            nombretitular, numerotarjeta, fechapago, numerooperacion, montopagado, idmoneda, sustentopago, 
            tipocontenido, nombrearchivo, extensionarchivo, comentario, espagodetraccion, 
            espagoretencion, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idservicio, p_idformapago, p_idcuentadestino, p_idbancotarjeta, p_idtipotarjeta, 
            p_nombretitular, p_numerotarjeta, p_fechapago, p_numerooperacion, p_montopago, p_idmoneda, p_sustentopago, 
            p_tipocontenido, p_nombrearchivo, p_extensionarchivo, p_comentario, p_espagodetraccion, 
            p_espagoretencion, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

if p_idmoneda <> v_monedaservicio then
    select negocio.fn_registrartransacciontipocambio(p_idmoneda,p_montopago,v_tipocambio,v_monedaservicio,v_montoaplicar,p_usuariocreacion,p_ipcreacion) into v_registrotranstc;
end if;

montosaldofinal = montosaldo - v_montoaplicar;

maxidss = nextval('negocio.seq_salsoservicio');
INSERT INTO negocio."SaldosServicio"(
            idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
            montosaldoservicio, idtransaccionreferencia, usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxidss, p_idservicio, maxid, fechaservicio, montoservicio, 
            montosaldofinal, v_registrotranstc, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion);

if montosaldofinal = 0 then
   update negocio."ServicioCabecera"
      set idestadopago = 2
    where id           = p_idservicio;
end if;

-- 1: ingreso
-- 2: egreso
if p_idformapago = 2 then
    v_tipotransaccion = 1;-- deposito en cuenta
    v_desctransaccion = 'Deposito en cuenta';
elsif p_idformapago = 3 then
    v_tipotransaccion = 2;-- transferencia
    v_desctransaccion = 'Transferencia de fondos a cuenta';
end if;

select negocio.fn_registrarmovimientocuenta(p_idcuentadestino, 1, v_tipotransaccion, v_desctransaccion, p_montopago, null, null, p_usuariocreacion, p_ipcreacion) into v_registramovimiento;

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_registrarpagoservicio(p_idservicio integer, p_idformapago integer, p_idcuentadestino integer, p_idbancotarjeta integer, p_idtipotarjeta integer, p_nombretitular character varying, p_numerotarjeta character varying, p_fechapago date, p_numerooperacion character varying, p_montopago numeric, p_idmoneda integer, p_sustentopago bytea, p_nombrearchivo character varying, p_extensionarchivo character varying, p_tipocontenido character varying, p_comentario character varying, p_espagodetraccion boolean, p_espagoretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 433 (class 1255 OID 256651)
-- Name: fn_registrarsaldoservicio(integer, integer, date, numeric, integer, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrarsaldoservicio(p_idservicio integer, p_idpago integer, p_fechaservicio date, p_montototalservicio numeric, idreferencia integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_salsoservicio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;


INSERT INTO negocio."SaldosServicio"(
            idsaldoservicio, idservicio, idpago, fechaservicio, montototalservicio, 
            montosaldoservicio, idtransaccionreferencia, usuariocreacion, fechacreacion, ipcreacion, 
            usuariomodificacion, fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idservicio, p_idpago, p_fechaservicio, p_montototalservicio, 
            p_montototalservicio, idreferencia, p_usuariocreacion, fechahoy, p_ipcreacion, 
            p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;
end;
$$;


ALTER FUNCTION negocio.fn_registrarsaldoservicio(p_idservicio integer, p_idpago integer, p_fechaservicio date, p_montototalservicio numeric, idreferencia integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 434 (class 1255 OID 256652)
-- Name: fn_registrartransacciontipocambio(integer, numeric, numeric, integer, numeric, character varying, character varying); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_registrartransacciontipocambio(p_idmonedainicio integer, p_montoinicio numeric, p_tipocambio numeric, p_idmonedafin integer, p_montofin numeric, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_transacciontipocambio');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."TransaccionTipoCambio"(
            id, idmonedainicio, montoinicio, tipocambio, idmonedafin, montofin, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idmonedainicio, p_montoinicio, p_tipocambio, p_idmonedafin, p_montofin, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;
end;
$$;


ALTER FUNCTION negocio.fn_registrartransacciontipocambio(p_idmonedainicio integer, p_montoinicio numeric, p_tipocambio numeric, p_idmonedafin integer, p_montofin numeric, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 435 (class 1255 OID 256653)
-- Name: fn_siguienteruta(); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_siguienteruta() RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

Begin

maxid = nextval('negocio.seq_ruta');

return maxid;

end;
$$;


ALTER FUNCTION negocio.fn_siguienteruta() OWNER TO postgres;

--
-- TOC entry 436 (class 1255 OID 256654)
-- Name: fn_telefonosxdireccion(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_telefonosxdireccion(p_iddireccion integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT tel.id, tel.numero, tel.idempresaproveedor, tel.usuariocreacion, tel.fechacreacion, 
       tel.ipcreacion, tel.usuariomodificacion, tel.fechamodificacion, tel.ipmodificacion
  FROM negocio."TelefonoDireccion" tdir,
       negocio."Telefono" tel
 WHERE tdir.idestadoregistro = 1
   AND tel.idestadoregistro  = 1
   AND tdir.idtelefono       = tel.id
   AND tdir.iddireccion      = p_iddireccion;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_telefonosxdireccion(p_iddireccion integer) OWNER TO postgres;

--
-- TOC entry 437 (class 1255 OID 256655)
-- Name: fn_telefonosxpersona(integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_telefonosxpersona(p_idpersona integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT tel.id, tel.numero, tel.idempresaproveedor, tel.usuariocreacion, tel.fechacreacion, 
       tel.ipcreacion, tel.usuariomodificacion, tel.fechamodificacion, tel.ipmodificacion
  FROM negocio."TelefonoPersona" tper,
       negocio."Telefono" tel
 WHERE tper.idestadoregistro = 1
   AND tel.idestadoregistro  = 1
   AND tper.idtelefono       = tel.id
   AND tper.idpersona        = p_idpersona;

return micursor;

end;
$$;


ALTER FUNCTION negocio.fn_telefonosxpersona(p_idpersona integer) OWNER TO postgres;

--
-- TOC entry 438 (class 1255 OID 256656)
-- Name: fn_validareliminarcuentasproveedor(integer, integer); Type: FUNCTION; Schema: negocio; Owner: postgres
--

CREATE FUNCTION fn_validareliminarcuentasproveedor(p_idcuenta integer, p_idproveedor integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;
declare v_pagosACuenta integer;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

SELECT count(1)
  INTO v_pagosACuenta
  FROM negocio."PagosObligacion" po
 INNER JOIN negocio."ObligacionesXPagar" ON oxp.id = po.idobligacion
 WHERE oxp.idproveedor    = p_idproveedor
   AND po.idcuentadestino = p_idcuenta;

IF v_pagosACuenta > 0 THEN
	RAISE USING MESSAGE = 'No se puede eliminar la cuenta porque esta asociada a pagos';
END IF;

return true;

end;
$$;


ALTER FUNCTION negocio.fn_validareliminarcuentasproveedor(p_idcuenta integer, p_idproveedor integer) OWNER TO postgres;

SET search_path = reportes, pg_catalog;

--
-- TOC entry 439 (class 1255 OID 256657)
-- Name: fn_re_generalventas(date, date); Type: FUNCTION; Schema: reportes; Owner: postgres
--

CREATE FUNCTION fn_re_generalventas(p_desde date, p_hasta date) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT sd.idtiposervicio, ms.nombre, COUNT(sd.id) AS cantidad, SUM(sd.montototal) as montototal, SUM(montocomision) as montocomision
  FROM negocio."ServicioCabecera" sc
 INNER JOIN negocio."ServicioDetalle" sd  ON sd.idservicio     = sc.id AND sd.idestadoregistro = 1
 INNER JOIN negocio."MaestroServicios" ms ON sd.idtiposervicio = ms.id AND sd.idestadoregistro = 1 AND ms.visible = TRUE
 WHERE sc.idestadoservicio = 2
   AND sc.idestadoregistro = 1
   AND sc.fechacompra BETWEEN p_desde AND p_hasta
 GROUP BY sd.idtiposervicio, ms.nombre;

return micursor;

end;
$$;


ALTER FUNCTION reportes.fn_re_generalventas(p_desde date, p_hasta date) OWNER TO postgres;

--
-- TOC entry 441 (class 1255 OID 256658)
-- Name: fn_re_generalventas(date, date, integer); Type: FUNCTION; Schema: reportes; Owner: postgres
--

CREATE FUNCTION fn_re_generalventas(p_desde date, p_hasta date, p_idvendedor integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT sd.idtiposervicio, ms.nombre, COUNT(sd.id) AS cantidad, SUM(sd.montototal) as montototal, SUM(montocomision) as montocomision
  FROM negocio."ServicioCabecera" sc
 INNER JOIN negocio."ServicioDetalle" sd  ON sd.idservicio     = sc.id AND sd.idestadoregistro = 1
 INNER JOIN negocio."MaestroServicios" ms ON sd.idtiposervicio = ms.id AND sd.idestadoregistro = 1 AND ms.visible = TRUE
 WHERE sc.idestadoservicio = 2
   AND sc.idestadoregistro = 1
   AND sc.fechacompra BETWEEN p_desde AND p_hasta
   AND sc.idvendedor       = COALESCE(p_idvendedor,sc.idvendedor)
 GROUP BY sd.idtiposervicio, ms.nombre;

return micursor;

end;
$$;


ALTER FUNCTION reportes.fn_re_generalventas(p_desde date, p_hasta date, p_idvendedor integer) OWNER TO postgres;

SET search_path = seguridad, pg_catalog;

--
-- TOC entry 442 (class 1255 OID 256659)
-- Name: fn_actualizarclaveusuario(integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_actualizarclaveusuario(p_idusuario integer, p_credencialnueva character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare idusuario integer;

begin


update seguridad.usuario
   set credencial   = p_credencialnueva,
       cambiarclave = true
 where id 	    = p_idusuario;


return true;

end;
$$;


ALTER FUNCTION seguridad.fn_actualizarclaveusuario(p_idusuario integer, p_credencialnueva character varying) OWNER TO postgres;

--
-- TOC entry 443 (class 1255 OID 256660)
-- Name: fn_actualizarcredencialvencida(integer, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_actualizarcredencialvencida(p_idusuario integer, p_credencialnueva character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare salida boolean;
declare idusuario integer;
declare v_fechaexpiracion1 date;
declare v_fechaexpiracion2 date;

begin

select feccaducacredencial
  into v_fechaexpiracion1
  from seguridad.usuario
 where id = p_idusuario;

if v_fechaexpiracion1 is null then
   select current_date into v_fechaexpiracion1;
end if;

v_fechaexpiracion2 = v_fechaexpiracion1 + 45;

update seguridad.usuario
   set feccaducacredencial = v_fechaexpiracion2,
       credencial          = p_credencialnueva,
       cambiarclave        = false
 where id 	           = p_idusuario;


return salida;

end;
$$;


ALTER FUNCTION seguridad.fn_actualizarcredencialvencida(p_idusuario integer, p_credencialnueva character varying) OWNER TO postgres;

--
-- TOC entry 444 (class 1255 OID 256661)
-- Name: fn_actualizarusuario(integer, integer, character varying, character varying, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_actualizarusuario(p_id integer, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

begin

update seguridad.usuario
   set id_rol	  = p_rol,
       nombres    = p_nombres,
       apepaterno = p_apepaterno,
       apematerno = p_apematerno
 where id 	  = p_id;

return true;

end;
$$;


ALTER FUNCTION seguridad.fn_actualizarusuario(p_id integer, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying) OWNER TO postgres;

--
-- TOC entry 445 (class 1255 OID 256662)
-- Name: fn_cambiarclaveusuario(character varying, character varying, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_cambiarclaveusuario(p_usuario character varying, p_credencialactual character varying, p_credencialnueva character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare idusuario integer;

begin

select COALESCE(max(id),0) 
  into idusuario
  from seguridad.usuario
 where usuario    = p_usuario
   and credencial = p_credencialactual;

if idusuario = 0 then
 RAISE EXCEPTION 'Informacion de usuario incorrecta';
else
update seguridad.usuario
   set credencial = p_credencialnueva
 where id 	  = idusuario;
end if;

return true;

end;
$$;


ALTER FUNCTION seguridad.fn_cambiarclaveusuario(p_usuario character varying, p_credencialactual character varying, p_credencialnueva character varying) OWNER TO postgres;

--
-- TOC entry 446 (class 1255 OID 256663)
-- Name: fn_consultarusuarios(character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_consultarusuarios(p_usuario character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select id, usuario, credencial, id_rol, nombre, nombres, apepaterno, apematerno, cambiarclave, feccaducacredencial
  from seguridad.vw_listarusuarios 
 where upper(usuario) = p_usuario;

return micursor;

end;$$;


ALTER FUNCTION seguridad.fn_consultarusuarios(p_usuario character varying) OWNER TO postgres;

--
-- TOC entry 447 (class 1255 OID 256664)
-- Name: fn_ingresarusuario(character varying, character varying, integer, character varying, character varying, character varying, date, boolean); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_ingresarusuario(p_usuario character varying, p_credencial character varying, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_fecnacimiento date, p_vendedor boolean) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxusuario integer;

begin


select max(id)
  into maxusuario
  from seguridad.usuario;

maxusuario = maxusuario + 1;

insert into seguridad.usuario(id,usuario,credencial,id_rol,nombres,apepaterno,apematerno,fecnacimiento,vendedor)
values (maxusuario,p_usuario,p_credencial,p_rol,p_nombres,p_apepaterno,p_apematerno,p_fecnacimiento,p_vendedor);


return true;

exception
when others then
  return false;

end;
$$;


ALTER FUNCTION seguridad.fn_ingresarusuario(p_usuario character varying, p_credencial character varying, p_rol integer, p_nombres character varying, p_apepaterno character varying, p_apematerno character varying, p_fecnacimiento date, p_vendedor boolean) OWNER TO postgres;

--
-- TOC entry 448 (class 1255 OID 256665)
-- Name: fn_iniciosesion(character varying, character varying); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_iniciosesion(p_usuario character varying, p_credencial character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare cantidad integer;

begin

cantidad = 0;

select count(1)
  into cantidad
  from seguridad.usuario usr
 where upper(usr.usuario) = p_usuario
   and usr.credencial     = p_credencial;

if cantidad = 1 then
   return true;
else
   return false;
end if;

exception
when others then
  return false;

end;
$$;


ALTER FUNCTION seguridad.fn_iniciosesion(p_usuario character varying, p_credencial character varying) OWNER TO postgres;

--
-- TOC entry 449 (class 1255 OID 256666)
-- Name: fn_listarusuarios(); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_listarusuarios() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select * from seguridad.usuario;

return micursor;

end;$$;


ALTER FUNCTION seguridad.fn_listarusuarios() OWNER TO postgres;

--
-- TOC entry 450 (class 1255 OID 256667)
-- Name: fn_listarvendedores(); Type: FUNCTION; Schema: seguridad; Owner: postgres
--

CREATE FUNCTION fn_listarvendedores() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin
open micursor for
select * 
  from seguridad.usuario u
 where u.vendedor = true;

return micursor;

end;$$;


ALTER FUNCTION seguridad.fn_listarvendedores() OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 451 (class 1255 OID 256668)
-- Name: fn_actualizardestino(integer, integer, integer, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_actualizardestino(p_id integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

UPDATE soporte.destino
   SET idcontinente        = p_idcontinente, 
       idpais              = p_idpais, 
       codigoiata          = p_codigoiata, 
       idtipodestino       = p_idtipodestino, 
       descripcion         = p_descripcion, 
       usuariomodificacion = p_usuariomodificacion, 
       fechamodificacion   = fechahoy, 
       ipmodificacion      = p_ipmodificacion
 WHERE id                  = p_id;
 
return true;

end;
$$;


ALTER FUNCTION soporte.fn_actualizardestino(p_id integer, p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 452 (class 1255 OID 256669)
-- Name: fn_actualizarmaestro(integer, integer, character varying, character varying, character varying, integer, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_actualizarmaestro(p_id integer, p_idtipo integer, p_nombre character varying, p_descripcion character varying, p_estado character varying, p_orden integer, p_abreviatura character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

begin

UPDATE soporte."Tablamaestra"
   SET nombre      = p_nombre,
       descripcion = p_descripcion,
       estado      = p_estado,
       orden       = p_orden,
       abreviatura = p_abreviatura
 WHERE id          = p_id
   AND idmaestro   = p_idtipo;

return true;

end;
$$;


ALTER FUNCTION soporte.fn_actualizarmaestro(p_id integer, p_idtipo integer, p_nombre character varying, p_descripcion character varying, p_estado character varying, p_orden integer, p_abreviatura character varying) OWNER TO postgres;

--
-- TOC entry 453 (class 1255 OID 256670)
-- Name: fn_actualizarparametro(integer, character varying, character varying, character varying, character varying, boolean); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_actualizarparametro(p_id integer, p_nombre character varying, p_descripcion character varying, p_valor character varying, p_estado character varying, p_editable boolean) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

begin

update soporte."Parametro"
   set nombre      = p_nombre,
       descripcion = p_descripcion,
       valor       = p_valor,
       estado      = p_estado,
       editable    = p_editable
 where id          = p_id;


return true;

exception
when others then
  return false;

end;
$$;


ALTER FUNCTION soporte.fn_actualizarparametro(p_id integer, p_nombre character varying, p_descripcion character varying, p_valor character varying, p_estado character varying, p_editable boolean) OWNER TO postgres;

--
-- TOC entry 454 (class 1255 OID 256671)
-- Name: fn_buscardestinos1(character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_buscardestinos1(p_nombre character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT des.id, des.idcontinente, cont.nombre as nombrecontinente, idpais, pai.descripcion as nombrepais, codigoiata, idtipodestino, tipdes.nombre as nombretipdestino, des.descripcion, 
       des.usuariocreacion, des.fechacreacion, des.ipcreacion, des.usuariomodificacion, 
       des.fechamodificacion, des.ipmodificacion, des.idestadoregistro, pai.abreviado
  FROM soporte.destino des,
       soporte."Tablamaestra" cont,
       soporte."Tablamaestra" tipdes,
       soporte.pais pai       
 WHERE des.idestadoregistro = 1
   AND cont.idmaestro       = 10
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND tipdes.idmaestro     = 11
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
   AND des.descripcion      like '%'||p_nombre||'%';

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_buscardestinos1(p_nombre character varying) OWNER TO postgres;

--
-- TOC entry 455 (class 1255 OID 256672)
-- Name: fn_consultarconfiguracionservicio(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultarconfiguracionservicio(p_idservicio integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idtiposervicio, muestraaerolinea, muestraempresatransporte, muestrahotel, 
       muestraproveedor, muestradescservicio, muestrafechaservicio, 
       muestrafecharegreso, muestracantidad, muestraprecio, muestraruta, 
       muestracomision, muestraoperador, muestratarifanegociada, muestracodigoreserva, muestranumeroboleto
  FROM soporte."ConfiguracionTipoServicio"
 WHERE idestadoregistro = 1
   AND idtiposervicio   = p_idservicio;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultarconfiguracionservicio(p_idservicio integer) OWNER TO postgres;

--
-- TOC entry 456 (class 1255 OID 256673)
-- Name: fn_consultardestino(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultardestino(p_iddestino integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT d.id, d.idcontinente, d.idpais, p.descripcion as descpais, d.codigoiata, d.idtipodestino, d.descripcion as descdestino, 
       d.usuariocreacion, d.fechacreacion, d.ipcreacion, d.usuariomodificacion, 
       d.fechamodificacion, d.ipmodificacion, p.abreviado
  FROM soporte.destino d,
       soporte.pais p
 WHERE d.idestadoregistro = 1
   AND d.id               = p_iddestino
   AND d.idpais           = p.id
   AND p.idestadoregistro = 1;


return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultardestino(p_iddestino integer) OWNER TO postgres;

--
-- TOC entry 457 (class 1255 OID 256674)
-- Name: fn_consultardestinoiata(character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_consultardestinoiata(p_codigoiata character varying) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT d.id, d.idcontinente, d.idpais, p.descripcion as descpais, d.codigoiata, d.idtipodestino, d.descripcion as descdestino, 
       d.usuariocreacion, d.fechacreacion, d.ipcreacion, d.usuariomodificacion, 
       d.fechamodificacion, d.ipmodificacion, p.abreviado
  FROM soporte.destino d,
       soporte.pais p
 WHERE d.idestadoregistro = 1
   AND d.codigoiata       = p_codigoIATA
   AND d.idpais           = p.id
   AND p.idestadoregistro = 1;


return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_consultardestinoiata(p_codigoiata character varying) OWNER TO postgres;

--
-- TOC entry 458 (class 1255 OID 256675)
-- Name: fn_eliminarconfiguracion(character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_eliminarconfiguracion(p_usuariomodificacion character varying, p_ipmodificacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

update soporte."ConfiguracionTipoServicio"
   set idestadoregistro      = 0,
       usuariomodificacion   = p_usuariomodificacion,
       fechamodificacion     = fechahoy,
       ipmodificacion        = p_ipmodificacion;

return true;

end;
$$;


ALTER FUNCTION soporte.fn_eliminarconfiguracion(p_usuariomodificacion character varying, p_ipmodificacion character varying) OWNER TO postgres;

--
-- TOC entry 489 (class 1255 OID 257996)
-- Name: fn_ingresardestino(integer, integer, integer, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresardestino(p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('soporte.seq_destino');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.destino(
            id, idcontinente, idpais, codigoiata, idtipodestino, descripcion, 
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idcontinente, p_idpais, p_codigoiata, p_idtipodestino, p_descripcion, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, 
            fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresardestino(p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 486 (class 1255 OID 257960)
-- Name: fn_ingresardestino(integer, integer, integer, character varying, character varying, boolean, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresardestino(p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_aplicaigv boolean, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('soporte.seq_destino');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.destino(
            id, idcontinente, idpais, codigoiata, idtipodestino, descripcion, aplicaigv,
            usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idcontinente, p_idpais, p_codigoiata, p_idtipodestino, p_descripcion, p_aplicaigv, 
            p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, 
            fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresardestino(p_idcontinente integer, p_idpais integer, p_idtipodestino integer, p_codigoiata character varying, p_descripcion character varying, p_aplicaigv boolean, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 459 (class 1255 OID 256677)
-- Name: fn_ingresarhijomaestro(integer, character varying, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarhijomaestro(p_idmaestro integer, p_nombre character varying, p_descripcion character varying, p_abreviatura character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

begin

select max(id)
  into maxid
  from soporte."Tablamaestra"
 where idmaestro = p_idmaestro;

if (maxid is null) then
maxid = 0;
end if;

maxid = maxid + 1;

INSERT INTO soporte."Tablamaestra"(id, idmaestro, nombre, descripcion, abreviatura, orden, estado)
values (maxid,p_idmaestro,p_nombre,p_descripcion,p_abreviatura,maxid,'A');

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresarhijomaestro(p_idmaestro integer, p_nombre character varying, p_descripcion character varying, p_abreviatura character varying) OWNER TO postgres;

--
-- TOC entry 460 (class 1255 OID 256678)
-- Name: fn_ingresarmaestro(character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarmaestro(p_nombre character varying, p_descripcion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

begin


select max(id)
  into maxid
  from soporte."Tablamaestra"
 where idmaestro = 0;

if (maxid is null) then
maxid = 0;
end if;

maxid = maxid + 1;

INSERT INTO soporte."Tablamaestra"(id, nombre, descripcion, orden, estado)
values (maxid,p_nombre,p_descripcion,maxid,'A');


return true;


end;
$$;


ALTER FUNCTION soporte.fn_ingresarmaestro(p_nombre character varying, p_descripcion character varying) OWNER TO postgres;

--
-- TOC entry 461 (class 1255 OID 256679)
-- Name: fn_ingresarpais(character varying, integer, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarpais(p_descripcion character varying, p_idcontinente integer, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxpais integer;
declare fechahoy timestamp with time zone;

begin

maxpais = nextval('soporte.seq_pais');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte.pais(
            id, descripcion, idcontinente, usuariocreacion, fechacreacion, 
            ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion, 
            idestadoregistro)
    VALUES (maxpais, p_descripcion, p_idcontinente, p_usuariocreacion, fechahoy, 
            p_ipcreacion, p_usuariocreacion, fechahoy, 
            p_ipcreacion, 1);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_ingresarpais(p_descripcion character varying, p_idcontinente integer, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 462 (class 1255 OID 256680)
-- Name: fn_ingresarparametro(character varying, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_ingresarparametro(p_nombre character varying, p_descripcion character varying, p_valor character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare maxparametro integer;

begin


select max(id)
  into maxparametro
  from soporte."Parametro";

if (maxparametro is null) then
maxparametro = 0;
end if;

maxparametro = maxparametro + 1;

INSERT INTO soporte."Parametro"(id, nombre, descripcion, valor, estado, editable)
values (maxparametro,p_nombre,p_descripcion,p_valor,'A',true);


return true;


end;
$$;


ALTER FUNCTION soporte.fn_ingresarparametro(p_nombre character varying, p_descripcion character varying, p_valor character varying) OWNER TO postgres;

--
-- TOC entry 440 (class 1255 OID 256681)
-- Name: fn_listarconfiguracionservicio(); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listarconfiguracionservicio() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT idtiposervicio, muestraaerolinea, muestraempresatransporte, muestrahotel, 
       muestraproveedor, muestradescservicio, muestrafechaservicio, 
       muestrafecharegreso, muestracantidad, muestraprecio, muestraruta, 
       muestracomision, muestraoperador, muestratarifanegociada
  FROM soporte."ConfiguracionTipoServicio"
 WHERE idestadoregistro = 1;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listarconfiguracionservicio() OWNER TO postgres;

--
-- TOC entry 463 (class 1255 OID 256682)
-- Name: fn_listardestinos(); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listardestinos() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT des.id, des.idcontinente, cont.nombre as nombrecontinente, idpais, pai.descripcion as nombrepais, codigoiata, idtipodestino, tipdes.nombre as nombretipdestino, des.descripcion, 
       des.usuariocreacion, des.fechacreacion, des.ipcreacion, des.usuariomodificacion, 
       des.fechamodificacion, des.ipmodificacion, des.idestadoregistro, pai.abreviado
  FROM soporte.destino des,
       soporte."Tablamaestra" cont,
       soporte."Tablamaestra" tipdes,
       soporte.pais pai       
 WHERE des.idestadoregistro = 1
   AND cont.idmaestro       = 10
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND tipdes.idmaestro     = 11
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
 ORDER BY des.descripcion ASC;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listardestinos() OWNER TO postgres;

--
-- TOC entry 464 (class 1255 OID 256683)
-- Name: fn_listarpaises(integer); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listarpaises(p_idcontinente integer) RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, descripcion, idcontinente, usuariocreacion, fechacreacion, 
       ipcreacion, usuariomodificacion, fechamodificacion, ipmodificacion, 
       idestadoregistro
  FROM soporte.pais
 WHERE idcontinente = p_idcontinente
 ORDER BY descripcion ASC;


return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listarpaises(p_idcontinente integer) OWNER TO postgres;

--
-- TOC entry 465 (class 1255 OID 256684)
-- Name: fn_listartiposservicio(); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_listartiposservicio() RETURNS refcursor
    LANGUAGE plpgsql
    AS $$
declare micursor refcursor;

begin

open micursor for
SELECT id, nombre
  FROM negocio."MaestroServicios"
 WHERE idestadoregistro = 1
   --AND id               not in (select idtiposervicio from soporte."ConfiguracionTipoServicio" where idestadoregistro =1)
 ORDER BY id;

return micursor;

end;
$$;


ALTER FUNCTION soporte.fn_listartiposservicio() OWNER TO postgres;

--
-- TOC entry 466 (class 1255 OID 256685)
-- Name: fn_registrarconfiguracionservicio(integer, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, boolean, character varying, character varying); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_registrarconfiguracionservicio(p_idtiposervicio integer, p_muestraaerolinea boolean, p_muestraempresatransporte boolean, p_muestrahotel boolean, p_muestraproveedor boolean, p_muestradescservicio boolean, p_muestrafechaservicio boolean, p_muestrafecharegreso boolean, p_muestracantidad boolean, p_muestraprecio boolean, p_muestraruta boolean, p_muestracomision boolean, p_muestraoperador boolean, p_muestratarifanegociada boolean, p_muestracodigoreserva boolean, p_muestranumeroboleto boolean, p_usuariocreacion character varying, p_ipcreacion character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$

declare fechahoy timestamp with time zone;

begin

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO soporte."ConfiguracionTipoServicio"(
            idtiposervicio, muestraaerolinea, muestraempresatransporte, muestrahotel, 
            muestraproveedor, muestradescservicio, muestrafechaservicio, 
            muestrafecharegreso, muestracantidad, muestraprecio, muestraruta, 
            muestracomision, muestraoperador, muestratarifanegociada, muestracodigoreserva, muestranumeroboleto, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion)
    VALUES (p_idtiposervicio, p_muestraaerolinea, p_muestraempresatransporte, p_muestrahotel, 
            p_muestraproveedor, p_muestradescservicio, p_muestrafechaservicio, 
            p_muestrafecharegreso, p_muestracantidad, p_muestraprecio, p_muestraruta, 
            p_muestracomision, p_muestraoperador, p_muestratarifanegociada, p_muestracodigoreserva, p_muestranumeroboleto, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return true;

end;
$$;


ALTER FUNCTION soporte.fn_registrarconfiguracionservicio(p_idtiposervicio integer, p_muestraaerolinea boolean, p_muestraempresatransporte boolean, p_muestrahotel boolean, p_muestraproveedor boolean, p_muestradescservicio boolean, p_muestrafechaservicio boolean, p_muestrafecharegreso boolean, p_muestracantidad boolean, p_muestraprecio boolean, p_muestraruta boolean, p_muestracomision boolean, p_muestraoperador boolean, p_muestratarifanegociada boolean, p_muestracodigoreserva boolean, p_muestranumeroboleto boolean, p_usuariocreacion character varying, p_ipcreacion character varying) OWNER TO postgres;

--
-- TOC entry 467 (class 1255 OID 256686)
-- Name: fn_siguientesequencia(); Type: FUNCTION; Schema: soporte; Owner: postgres
--

CREATE FUNCTION fn_siguientesequencia() RETURNS integer
    LANGUAGE plpgsql
    AS $$

declare maxid integer;

begin

maxid = nextval('soporte.seq_comun');

return maxid;

end;
$$;


ALTER FUNCTION soporte.fn_siguientesequencia() OWNER TO postgres;

SET search_path = auditoria, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 173 (class 1259 OID 256687)
-- Name: eventosesionsistema; Type: TABLE; Schema: auditoria; Owner: postgres; Tablespace: 
--

CREATE TABLE eventosesionsistema (
    id integer NOT NULL,
    idusuario integer NOT NULL,
    usuario character varying(15) NOT NULL,
    fecharegistro timestamp with time zone NOT NULL,
    idtipoevento integer NOT NULL
);


ALTER TABLE auditoria.eventosesionsistema OWNER TO postgres;

--
-- TOC entry 174 (class 1259 OID 256690)
-- Name: seq_eventosesionsistema; Type: SEQUENCE; Schema: auditoria; Owner: postgres
--

CREATE SEQUENCE seq_eventosesionsistema
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auditoria.seq_eventosesionsistema OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 269 (class 1259 OID 266162)
-- Name: ArchivoCargado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ArchivoCargado" (
    id integer NOT NULL,
    nombrearchivo character varying(100) NOT NULL,
    nombrereporte character varying(100) NOT NULL,
    idproveedor integer NOT NULL,
    numerofilas integer NOT NULL,
    numerocolumnas integer NOT NULL,
    idmoneda integer NOT NULL,
    montosubtotal numeric(12,4) NOT NULL,
    montoigv numeric(12,4) NOT NULL,
    montototal numeric(12,4) NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ArchivoCargado" OWNER TO postgres;

--
-- TOC entry 175 (class 1259 OID 256696)
-- Name: ComprobanteAdicional; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ComprobanteAdicional" (
    id integer NOT NULL,
    idservicio integer NOT NULL,
    idtipocomprobante integer NOT NULL,
    numerocomprobante character varying(20) NOT NULL,
    idtitular integer,
    detallecomprobante text,
    fechacomprobante date,
    totaligv numeric(12,3),
    totalcomprobante numeric(12,3),
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ComprobanteAdicional" OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 266420)
-- Name: ComprobanteGenerado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ComprobanteGenerado" (
    id integer NOT NULL,
    idservicio integer NOT NULL,
    idtipocomprobante integer NOT NULL,
    numerocomprobante character varying(20) NOT NULL,
    idtitular integer NOT NULL,
    fechacomprobante date,
    idmoneda integer,
    totaligv numeric(12,3),
    totalcomprobante numeric(12,3),
    tienedetraccion boolean,
    tieneretencion boolean,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ComprobanteGenerado" OWNER TO postgres;

--
-- TOC entry 176 (class 1259 OID 256707)
-- Name: ComprobanteObligacion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ComprobanteObligacion" (
    idcomprobante integer NOT NULL,
    idobligacion integer NOT NULL,
    iddetalleservicio integer NOT NULL,
    idservicio integer NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ComprobanteObligacion" OWNER TO postgres;

--
-- TOC entry 177 (class 1259 OID 256711)
-- Name: CorreoElectronico; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "CorreoElectronico" (
    id integer NOT NULL,
    correo character varying(100) NOT NULL,
    idpersona integer NOT NULL,
    usuariocreacion character varying(15),
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    usuariomodificacion character varying(15),
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    recibirpromociones boolean DEFAULT false
);


ALTER TABLE negocio."CorreoElectronico" OWNER TO postgres;

--
-- TOC entry 178 (class 1259 OID 256716)
-- Name: CronogramaPago; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "CronogramaPago" (
    nrocuota integer NOT NULL,
    idservicio integer NOT NULL,
    fechavencimiento date NOT NULL,
    capital numeric NOT NULL,
    interes numeric NOT NULL,
    totalcuota numeric NOT NULL,
    idestadocuota integer NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."CronogramaPago" OWNER TO postgres;

--
-- TOC entry 179 (class 1259 OID 256723)
-- Name: CuentaBancaria; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "CuentaBancaria" (
    id integer NOT NULL,
    nombrecuenta character varying(40) NOT NULL,
    numerocuenta character varying(20) NOT NULL,
    idtipocuenta integer NOT NULL,
    idbanco integer,
    idmoneda integer NOT NULL,
    saldocuenta numeric(20,6) DEFAULT 0.000000 NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."CuentaBancaria" OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 266168)
-- Name: DetalleArchivoCargado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "DetalleArchivoCargado" (
    id integer NOT NULL,
    idarchivo integer NOT NULL,
    campo1 character varying(100),
    campo2 character varying(100),
    campo3 character varying(100),
    campo4 character varying(100),
    campo5 character varying(100),
    campo6 character varying(100),
    campo7 character varying(100),
    campo8 character varying(100),
    campo9 character varying(100),
    campo10 character varying(100),
    campo11 character varying(100),
    campo12 character varying(100),
    campo13 character varying(100),
    campo14 character varying(100),
    campo15 character varying(100),
    campo16 character varying(100),
    campo17 character varying(100),
    campo18 character varying(100),
    campo19 character varying(100),
    campo20 character varying(100),
    seleccionado boolean DEFAULT false NOT NULL,
    idtipocomprobante integer,
    numerocomprobante character varying(20),
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."DetalleArchivoCargado" OWNER TO postgres;

--
-- TOC entry 274 (class 1259 OID 266426)
-- Name: DetalleComprobanteGenerado; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "DetalleComprobanteGenerado" (
    id integer NOT NULL,
    idserviciodetalle integer NOT NULL,
    idcomprobante integer NOT NULL,
    cantidad integer NOT NULL,
    detalleconcepto character varying(300),
    preciounitario numeric(12,3),
    totaldetalle numeric(12,3),
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."DetalleComprobanteGenerado" OWNER TO postgres;

--
-- TOC entry 180 (class 1259 OID 256740)
-- Name: Direccion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Direccion" (
    id integer NOT NULL,
    idvia integer NOT NULL,
    nombrevia character varying(50),
    numero character varying(10),
    interior character varying(10),
    manzana character varying(10),
    lote character varying(10),
    principal character varying(1),
    idubigeo character(6),
    usuariocreacion character varying(50),
    fechacreacion timestamp with time zone,
    ipcreacion character varying(50),
    usuariomodificacion character varying(50),
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(50),
    idestadoregistro integer DEFAULT 1 NOT NULL,
    observacion character varying(300),
    referencia character varying(300)
);


ALTER TABLE negocio."Direccion" OWNER TO postgres;

--
-- TOC entry 181 (class 1259 OID 256747)
-- Name: DocumentoAdjuntoServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "DocumentoAdjuntoServicio" (
    id integer NOT NULL,
    idservicio integer NOT NULL,
    idtipodocumento integer NOT NULL,
    descripciondocumento character varying(150),
    archivo bytea NOT NULL,
    nombrearchivo character varying(50) NOT NULL,
    tipocontenido character varying(50) NOT NULL,
    extensionarchivo character varying(10) NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."DocumentoAdjuntoServicio" OWNER TO postgres;

--
-- TOC entry 182 (class 1259 OID 256754)
-- Name: EventoObsAnuServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "EventoObsAnuServicio" (
    id integer NOT NULL,
    idtipoevento integer NOT NULL,
    comentario character varying(300) NOT NULL,
    idservicio integer NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."EventoObsAnuServicio" OWNER TO postgres;

--
-- TOC entry 183 (class 1259 OID 256758)
-- Name: MaestroServicios; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "MaestroServicios" (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    desccorta character varying(100),
    desclarga character varying(300),
    requierefee boolean DEFAULT false NOT NULL,
    idmaeserfee integer,
    pagaimpto boolean DEFAULT false NOT NULL,
    idmaeserimpto integer,
    cargacomision boolean DEFAULT false NOT NULL,
    cargaigv boolean DEFAULT false NOT NULL,
    comisionporcen boolean DEFAULT false NOT NULL,
    valorporcomision numeric,
    esimpuesto boolean DEFAULT false NOT NULL,
    esfee boolean DEFAULT false NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    idparametroasociado integer,
    visible boolean DEFAULT true NOT NULL,
    esserviciopadre boolean DEFAULT false NOT NULL
);


ALTER TABLE negocio."MaestroServicios" OWNER TO postgres;

--
-- TOC entry 184 (class 1259 OID 256774)
-- Name: MovimientoCuenta; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "MovimientoCuenta" (
    id integer NOT NULL,
    idcuenta integer NOT NULL,
    idtipomovimiento integer NOT NULL,
    idtransaccion integer NOT NULL,
    descripcionnovimiento character varying(100),
    importemovimiento numeric(20,6) DEFAULT 0.000000 NOT NULL,
    idautorizador integer,
    idmovimientopadre integer,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."MovimientoCuenta" OWNER TO postgres;

--
-- TOC entry 185 (class 1259 OID 256779)
-- Name: ObligacionesXPagar; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ObligacionesXPagar" (
    id integer NOT NULL,
    idtipocomprobante integer NOT NULL,
    numerocomprobante character varying(20) NOT NULL,
    idproveedor integer NOT NULL,
    fechacomprobante date NOT NULL,
    fechapago date,
    detallecomprobante character varying(300),
    totaligv numeric(12,3) NOT NULL,
    totalcomprobante numeric(12,3) NOT NULL,
    saldocomprobante numeric(12,3) NOT NULL,
    tienedetraccion boolean,
    tieneretencion boolean,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ObligacionesXPagar" OWNER TO postgres;

--
-- TOC entry 186 (class 1259 OID 256783)
-- Name: PagosObligacion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PagosObligacion" (
    idpago integer NOT NULL,
    idobligacion integer NOT NULL,
    idformapago integer NOT NULL,
    idcuentaorigen integer,
    idcuentadestino integer,
    idbancotarjeta integer,
    idtipotarjeta integer,
    nombretitular character varying(50),
    numerotarjeta character varying(16),
    fechapago date NOT NULL,
    numerooperacion character varying(20),
    montopagado numeric(12,3) NOT NULL,
    idmoneda integer NOT NULL,
    sustentopago bytea,
    tipocontenido character varying(50),
    nombrearchivo character varying(20),
    extensionarchivo character varying(10),
    comentario character varying(300),
    espagodetraccion boolean,
    espagoretencion boolean,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."PagosObligacion" OWNER TO postgres;

--
-- TOC entry 187 (class 1259 OID 256790)
-- Name: PagosServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PagosServicio" (
    idpago integer NOT NULL,
    idservicio integer NOT NULL,
    idformapago integer NOT NULL,
    idcuentadestino integer,
    idbancotarjeta integer,
    idtipotarjeta integer,
    nombretitular character varying(50),
    numerotarjeta character varying(16),
    numerooperacion character varying(20),
    fechapago date NOT NULL,
    montopagado numeric(12,3) NOT NULL,
    idmoneda integer NOT NULL,
    sustentopago bytea,
    tipocontenido character varying(50),
    nombrearchivo character varying(20),
    extensionarchivo character varying(10),
    comentario character varying(300),
    espagodetraccion boolean,
    espagoretencion boolean,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."PagosServicio" OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 266405)
-- Name: PasajeroServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PasajeroServicio" (
    id bigint NOT NULL,
    nombres character varying(100) NOT NULL,
    apellidopaterno character varying(50) NOT NULL,
    apellidomaterno character varying(50) NOT NULL,
    correoelectronico character varying(100),
    telefono1 character varying(10),
    telefono2 character varying(10),
    nropaxfrecuente character varying(20),
    idaerolinea integer,
    idrelacion integer NOT NULL,
    idserviciodetalle integer NOT NULL,
    idservicio integer NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."PasajeroServicio" OWNER TO postgres;

--
-- TOC entry 188 (class 1259 OID 256797)
-- Name: Persona; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Persona" (
    id bigint NOT NULL,
    idtipopersona integer NOT NULL,
    nombres character varying(100),
    apellidopaterno character varying(50),
    apellidomaterno character varying(50),
    idgenero character varying(1),
    idestadocivil integer,
    idtipodocumento integer,
    numerodocumento character varying(15),
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    fecnacimiento date,
    nropasaporte character varying(12),
    fecvctopasaporte date
);


ALTER TABLE negocio."Persona" OWNER TO postgres;

--
-- TOC entry 189 (class 1259 OID 256801)
-- Name: PersonaAdicional; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PersonaAdicional" (
    idpersona integer NOT NULL,
    idrubro integer,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."PersonaAdicional" OWNER TO postgres;

--
-- TOC entry 190 (class 1259 OID 256805)
-- Name: PersonaContactoProveedor; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PersonaContactoProveedor" (
    idproveedor integer NOT NULL,
    idcontacto integer NOT NULL,
    idarea integer,
    anexo character varying(5),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."PersonaContactoProveedor" OWNER TO postgres;

--
-- TOC entry 191 (class 1259 OID 256809)
-- Name: PersonaDireccion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "PersonaDireccion" (
    idpersona bigint NOT NULL,
    iddireccion integer NOT NULL,
    idtipopersona integer NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."PersonaDireccion" OWNER TO postgres;

--
-- TOC entry 192 (class 1259 OID 256813)
-- Name: Personapotencial; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Personapotencial" (
    id integer NOT NULL,
    nombres character varying(50) NOT NULL,
    apellidopaterno character varying(20) NOT NULL,
    apellidomaterno character varying(20),
    telefono character varying(12),
    correoelectronico character varying(100),
    idnovios integer NOT NULL,
    fecnacimiento date,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."Personapotencial" OWNER TO postgres;

--
-- TOC entry 193 (class 1259 OID 256817)
-- Name: ProgramaNovios; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProgramaNovios" (
    id integer NOT NULL,
    codigonovios character varying(20) NOT NULL,
    idnovia integer NOT NULL,
    idnovio integer NOT NULL,
    iddestino integer NOT NULL,
    fechaboda date NOT NULL,
    fechaviaje date NOT NULL,
    fechashower date,
    idmoneda integer NOT NULL,
    cuotainicial numeric NOT NULL,
    dias integer NOT NULL,
    noches integer NOT NULL,
    observaciones text,
    montototal numeric NOT NULL,
    idservicio integer NOT NULL,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ProgramaNovios" OWNER TO postgres;

--
-- TOC entry 194 (class 1259 OID 256824)
-- Name: ProveedorCuentaBancaria; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProveedorCuentaBancaria" (
    id integer NOT NULL,
    nombrecuenta character varying(40) NOT NULL,
    numerocuenta character varying(20) NOT NULL,
    idtipocuenta integer NOT NULL,
    idbanco integer NOT NULL,
    idmoneda integer NOT NULL,
    idproveedor integer NOT NULL,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ProveedorCuentaBancaria" OWNER TO postgres;

--
-- TOC entry 195 (class 1259 OID 256828)
-- Name: ProveedorPersona; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProveedorPersona" (
    idproveedor integer NOT NULL,
    idtipoproveedor integer NOT NULL,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ProveedorPersona" OWNER TO postgres;

--
-- TOC entry 196 (class 1259 OID 256832)
-- Name: ProveedorTipoServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ProveedorTipoServicio" (
    idproveedor integer NOT NULL,
    idtiposervicio integer NOT NULL,
    idproveedorservicio integer NOT NULL,
    porcencomnacional numeric NOT NULL,
    porcencominternacional numeric,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ProveedorTipoServicio" OWNER TO postgres;

--
-- TOC entry 197 (class 1259 OID 256839)
-- Name: RutaServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "RutaServicio" (
    id integer NOT NULL,
    idtramo integer NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."RutaServicio" OWNER TO postgres;

--
-- TOC entry 198 (class 1259 OID 256843)
-- Name: SaldosServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "SaldosServicio" (
    idsaldoservicio integer NOT NULL,
    idservicio integer NOT NULL,
    idpago integer,
    fechaservicio date NOT NULL,
    montototalservicio numeric(12,3) NOT NULL,
    montosaldoservicio numeric(12,3) NOT NULL,
    idtransaccionreferencia integer,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."SaldosServicio" OWNER TO postgres;

--
-- TOC entry 199 (class 1259 OID 256847)
-- Name: ServicioCabecera; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ServicioCabecera" (
    id bigint NOT NULL,
    idcliente1 integer NOT NULL,
    idcliente2 integer,
    fechacompra date NOT NULL,
    idestadopago integer,
    idestadoservicio integer,
    nrocuotas integer,
    tea numeric,
    valorcuota numeric,
    fechaprimercuota date,
    fechaultcuota date,
    idmoneda integer NOT NULL,
    montocomisiontotal numeric NOT NULL,
    montototaligv numeric NOT NULL,
    montototal numeric NOT NULL,
    montototalfee numeric NOT NULL,
    idvendedor integer NOT NULL,
    observaciones text,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    generocomprobantes boolean DEFAULT false NOT NULL,
    guardorelacioncomprobantes boolean DEFAULT false NOT NULL
);


ALTER TABLE negocio."ServicioCabecera" OWNER TO postgres;

--
-- TOC entry 267 (class 1259 OID 257969)
-- Name: ServicioDetalle; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ServicioDetalle" (
    id bigint NOT NULL,
    idtiposervicio integer NOT NULL,
    descripcionservicio character varying(300) NOT NULL,
    idservicio integer NOT NULL,
    fechaida timestamp with time zone NOT NULL,
    fecharegreso timestamp with time zone,
    cantidad integer NOT NULL,
    idempresaproveedor integer,
    descripcionproveedor character varying(100),
    idempresaoperadora integer,
    descripcionoperador character varying(100),
    idempresatransporte integer,
    descripcionemptransporte character varying(100),
    idhotel integer,
    decripcionhotel character varying(100),
    idruta integer,
    idmoneda integer NOT NULL,
    preciobaseanterior numeric NOT NULL,
    tipocambio numeric(9,6) NOT NULL,
    preciobase numeric NOT NULL,
    editocomision boolean DEFAULT false,
    tarifanegociada boolean DEFAULT false,
    porcencomision numeric,
    montocomision numeric,
    montototal numeric NOT NULL,
    codigoreserva character varying(10),
    numeroboleto character varying(15),
    idservdetdepende integer,
    aplicaigv boolean DEFAULT true NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ServicioDetalle" OWNER TO postgres;

--
-- TOC entry 200 (class 1259 OID 256865)
-- Name: ServicioMaestroServicio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "ServicioMaestroServicio" (
    idservicio integer NOT NULL,
    idserviciodepende integer NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."ServicioMaestroServicio" OWNER TO postgres;

--
-- TOC entry 201 (class 1259 OID 256869)
-- Name: Telefono; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Telefono" (
    id integer NOT NULL,
    numero character varying(9) NOT NULL,
    idempresaproveedor integer NOT NULL,
    usuariocreacion character varying(15),
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    usuariomodificacion character varying(15),
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."Telefono" OWNER TO postgres;

--
-- TOC entry 202 (class 1259 OID 256873)
-- Name: TelefonoDireccion; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TelefonoDireccion" (
    idtelefono integer NOT NULL,
    iddireccion integer NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."TelefonoDireccion" OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 256877)
-- Name: TelefonoPersona; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TelefonoPersona" (
    idtelefono integer NOT NULL,
    idpersona integer NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."TelefonoPersona" OWNER TO postgres;

--
-- TOC entry 204 (class 1259 OID 256881)
-- Name: TipoCambio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TipoCambio" (
    id integer NOT NULL,
    fechatipocambio date NOT NULL,
    idmonedaorigen integer NOT NULL,
    idmonedadestino integer NOT NULL,
    montocambio numeric(9,6) NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."TipoCambio" OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 256885)
-- Name: Tramo; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "Tramo" (
    id integer NOT NULL,
    idorigen integer NOT NULL,
    descripcionorigen character varying(100) NOT NULL,
    fechasalida timestamp with time zone NOT NULL,
    iddestino integer NOT NULL,
    descripciondestino character varying(100) NOT NULL,
    fechallegada timestamp with time zone NOT NULL,
    preciobase numeric,
    idaerolinea integer NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."Tramo" OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 256892)
-- Name: TransaccionTipoCambio; Type: TABLE; Schema: negocio; Owner: postgres; Tablespace: 
--

CREATE TABLE "TransaccionTipoCambio" (
    id integer NOT NULL,
    idmonedainicio integer,
    montoinicio numeric(15,2) NOT NULL,
    tipocambio numeric(9,6) NOT NULL,
    idmonedafin integer,
    montofin numeric(15,2) NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE negocio."TransaccionTipoCambio" OWNER TO postgres;

--
-- TOC entry 207 (class 1259 OID 256896)
-- Name: seq_archivocargado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_archivocargado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_archivocargado OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 256898)
-- Name: seq_comprobanteadicional; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_comprobanteadicional
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_comprobanteadicional OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 256900)
-- Name: seq_comprobantegenerado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_comprobantegenerado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_comprobantegenerado OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 256902)
-- Name: seq_consolidador; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_consolidador
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_consolidador OWNER TO postgres;

--
-- TOC entry 211 (class 1259 OID 256904)
-- Name: seq_correoelectronico; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_correoelectronico
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_correoelectronico OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 256906)
-- Name: seq_cuentabancaria; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_cuentabancaria
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_cuentabancaria OWNER TO postgres;

--
-- TOC entry 213 (class 1259 OID 256908)
-- Name: seq_cuentabancariaproveedor; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_cuentabancariaproveedor
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_cuentabancariaproveedor OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 256910)
-- Name: seq_detallearchivocargado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_detallearchivocargado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_detallearchivocargado OWNER TO postgres;

--
-- TOC entry 215 (class 1259 OID 256912)
-- Name: seq_detallecomprobantegenerado; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_detallecomprobantegenerado
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_detallecomprobantegenerado OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 256914)
-- Name: seq_direccion; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_direccion
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_direccion OWNER TO postgres;

--
-- TOC entry 217 (class 1259 OID 256916)
-- Name: seq_documentoservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_documentoservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_documentoservicio OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 256918)
-- Name: seq_eventoservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_eventoservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_eventoservicio OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 256920)
-- Name: seq_maestroservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_maestroservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_maestroservicio OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 256922)
-- Name: seq_movimientocuenta; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_movimientocuenta
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_movimientocuenta OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 256924)
-- Name: seq_novios; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_novios
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_novios OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 256926)
-- Name: seq_obligacionxpagar; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_obligacionxpagar
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_obligacionxpagar OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 256928)
-- Name: seq_pago; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_pago
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_pago OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 266377)
-- Name: seq_pax; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_pax
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_pax OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 256930)
-- Name: seq_persona; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_persona
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_persona OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 256932)
-- Name: seq_personapotencial; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_personapotencial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_personapotencial OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 256934)
-- Name: seq_ruta; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_ruta
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_ruta OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 256936)
-- Name: seq_salsoservicio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_salsoservicio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_salsoservicio OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 256938)
-- Name: seq_serviciocabecera; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_serviciocabecera
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_serviciocabecera OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 256940)
-- Name: seq_serviciodetalle; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_serviciodetalle
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_serviciodetalle OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 256942)
-- Name: seq_serviciosnovios; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_serviciosnovios
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_serviciosnovios OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 256944)
-- Name: seq_telefono; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_telefono
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_telefono OWNER TO postgres;

--
-- TOC entry 232 (class 1259 OID 256946)
-- Name: seq_tipocambio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_tipocambio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_tipocambio OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 256948)
-- Name: seq_tramo; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_tramo
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_tramo OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 256950)
-- Name: seq_transacciontipocambio; Type: SEQUENCE; Schema: negocio; Owner: postgres
--

CREATE SEQUENCE seq_transacciontipocambio
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE negocio.seq_transacciontipocambio OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 256952)
-- Name: vw_clientesnova; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_clientesnova AS
    SELECT per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento, per.usuariocreacion, per.fechacreacion, per.ipcreacion, per.usuariomodificacion, per.fechamodificacion, per.ipmodificacion, per.idestadoregistro, per.fecnacimiento FROM "Persona" per WHERE ((per.idestadoregistro = 1) AND (per.idtipopersona = 1));


ALTER TABLE negocio.vw_clientesnova OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 256956)
-- Name: vw_consultacontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultacontacto AS
    SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, pro.usuariocreacion, pro.fechacreacion, pro.ipcreacion FROM "Persona" pro WHERE ((pro.idtipopersona = 3) AND (pro.idestadoregistro = 1));


ALTER TABLE negocio.vw_consultacontacto OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 256960)
-- Name: vw_consultacorreocontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultacorreocontacto AS
    SELECT cor.id, cor.correo, cor.idpersona, cor.recibirpromociones, cor.usuariocreacion, cor.fechacreacion, cor.ipcreacion, cor.usuariomodificacion, cor.fechamodificacion, cor.ipmodificacion FROM "CorreoElectronico" cor WHERE (cor.idestadoregistro = 1);


ALTER TABLE negocio.vw_consultacorreocontacto OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 238 (class 1259 OID 256964)
-- Name: ubigeo; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE ubigeo (
    id character varying(6) NOT NULL,
    iddepartamento character varying(2),
    idprovincia character varying(2),
    iddistrito character varying(2),
    descripcion character varying(50)
);


ALTER TABLE soporte.ubigeo OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 239 (class 1259 OID 256967)
-- Name: vw_consultadireccionproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultadireccionproveedor AS
    SELECT dir.id, dir.idvia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, dir.principal, dir.idubigeo, dir.usuariocreacion, dir.fechacreacion, dir.ipcreacion, dep.iddepartamento, dep.descripcion AS departamento, pro.idprovincia, pro.descripcion AS provincia, dis.iddistrito, dis.descripcion AS distrito, pdir.idpersona, dir.observacion, dir.referencia FROM "Direccion" dir, "PersonaDireccion" pdir, soporte.ubigeo dep, soporte.ubigeo pro, soporte.ubigeo dis WHERE ((((((((((((dir.idestadoregistro = 1) AND (pdir.idestadoregistro = 1)) AND (dir.id = pdir.iddireccion)) AND (("substring"((dir.idubigeo)::text, 1, 2) || '0000'::text) = (dep.id)::text)) AND ((dep.iddepartamento)::text <> '00'::text)) AND ((dep.idprovincia)::text = '00'::text)) AND ((dep.iddistrito)::text = '00'::text)) AND (("substring"((dir.idubigeo)::text, 1, 4) || '00'::text) = (pro.id)::text)) AND ((pro.iddepartamento)::text <> '00'::text)) AND ((pro.idprovincia)::text <> '00'::text)) AND ((pro.iddistrito)::text = '00'::text)) AND ((dis.id)::bpchar = dir.idubigeo));


ALTER TABLE negocio.vw_consultadireccionproveedor OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 256972)
-- Name: vw_consultaproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_consultaproveedor AS
    SELECT pro.id, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, pro.idgenero, pro.idestadocivil, pro.idtipodocumento, pro.numerodocumento, pro.usuariocreacion, pro.fechacreacion, pro.ipcreacion, ppro.idrubro, pper.idtipoproveedor FROM "Persona" pro, "PersonaAdicional" ppro, "ProveedorPersona" pper WHERE (((((pro.idestadoregistro = 1) AND (ppro.idestadoregistro = 1)) AND (pro.idtipopersona = 2)) AND (pro.id = ppro.idpersona)) AND (pper.idproveedor = pro.id));


ALTER TABLE negocio.vw_consultaproveedor OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 241 (class 1259 OID 256976)
-- Name: Tablamaestra; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "Tablamaestra" (
    id integer NOT NULL,
    idmaestro integer DEFAULT 0 NOT NULL,
    nombre character varying(50),
    descripcion character varying(100),
    orden integer,
    estado character(1),
    abreviatura character varying(5)
);


ALTER TABLE soporte."Tablamaestra" OWNER TO postgres;

SET search_path = negocio, pg_catalog;

--
-- TOC entry 242 (class 1259 OID 256980)
-- Name: vw_contactoproveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_contactoproveedor AS
    SELECT con.id, con.nombres, con.apellidopaterno, con.apellidomaterno, con.idgenero, con.idestadocivil, con.idtipodocumento, con.numerodocumento, con.usuariocreacion, con.fechacreacion, con.ipcreacion, pcpro.idproveedor, pcpro.idarea, area.nombre, pcpro.anexo FROM "Persona" con, ("PersonaContactoProveedor" pcpro LEFT JOIN soporte."Tablamaestra" area ON ((((pcpro.idarea = area.id) AND (area.estado = 'A'::bpchar)) AND (area.idmaestro = 4)))) WHERE ((((con.idestadoregistro = 1) AND (pcpro.idestadoregistro = 1)) AND (con.idtipopersona = 3)) AND (con.id = pcpro.idcontacto));


ALTER TABLE negocio.vw_contactoproveedor OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 256985)
-- Name: vw_direccioncliente; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_direccioncliente AS
    SELECT dir.id, dir.idvia, tvia.nombre AS nombretipovia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, pdir.idpersona FROM "PersonaDireccion" pdir, "Direccion" dir, soporte."Tablamaestra" tvia WHERE (((((pdir.idestadoregistro = 1) AND (dir.idestadoregistro = 1)) AND (pdir.iddireccion = dir.id)) AND (tvia.idmaestro = 2)) AND (dir.idvia = tvia.id));


ALTER TABLE negocio.vw_direccioncliente OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 256989)
-- Name: vw_proveedor; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_proveedor AS
    SELECT pro.id AS idproveedor, tdoc.id AS idtipodocumento, tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, pro.apellidopaterno, pro.apellidomaterno, ppro.idrubro, trub.nombre AS nombrerubro, dir.idvia, tvia.nombre AS nombretipovia, dir.nombrevia, dir.numero, dir.interior, dir.manzana, dir.lote, (SELECT tel.numero FROM "TelefonoDireccion" tedir, "Telefono" tel WHERE ((((tedir.idestadoregistro = 1) AND (tel.idestadoregistro = 1)) AND (tedir.iddireccion = dir.id)) AND (tedir.idtelefono = tel.id)) LIMIT 1) AS teledireccion FROM "Persona" pro, soporte."Tablamaestra" tdoc, "PersonaAdicional" ppro, soporte."Tablamaestra" trub, (("PersonaDireccion" pdir LEFT JOIN "Direccion" dir ON (((pdir.iddireccion = dir.id) AND ((dir.principal)::text = 'S'::text)))) LEFT JOIN soporte."Tablamaestra" tvia ON (((tvia.idmaestro = 2) AND (dir.idvia = tvia.id)))) WHERE (((((((((((pro.idestadoregistro = 1) AND (pro.idtipopersona = 2)) AND (tdoc.idmaestro = 1)) AND (pro.idtipodocumento = tdoc.id)) AND (pro.id = ppro.idpersona)) AND (trub.idmaestro = 3)) AND (ppro.idestadoregistro = 1)) AND (ppro.idrubro = trub.id)) AND (dir.idestadoregistro = 1)) AND (pdir.idestadoregistro = 1)) AND (pro.id = pdir.idpersona));


ALTER TABLE negocio.vw_proveedor OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 256994)
-- Name: vw_proveedoresnova; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_proveedoresnova AS
    SELECT per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento, per.usuariocreacion, per.fechacreacion, per.ipcreacion, per.usuariomodificacion, per.fechamodificacion, per.ipmodificacion, per.idestadoregistro, per.fecnacimiento FROM "Persona" per WHERE ((per.idestadoregistro = 1) AND (per.idtipopersona = 2));


ALTER TABLE negocio.vw_proveedoresnova OWNER TO postgres;

--
-- TOC entry 268 (class 1259 OID 257986)
-- Name: vw_servicio_detalle; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_servicio_detalle AS
    SELECT serdet.cantidad, serdet.descripcionservicio, serdet.fechaida, serdet.fecharegreso, serdet.idmoneda, tmmo.abreviatura, serdet.preciobase, serdet.montototal, serdet.codigoreserva, serdet.numeroboleto, serdet.idservicio FROM ("ServicioDetalle" serdet JOIN soporte."Tablamaestra" tmmo ON (((tmmo.idmaestro = 20) AND (serdet.idmoneda = tmmo.id))));


ALTER TABLE negocio.vw_servicio_detalle OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 257003)
-- Name: vw_telefonocontacto; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_telefonocontacto AS
    SELECT tel.id, tel.numero, tel.idempresaproveedor, tper.idpersona FROM "Telefono" tel, "TelefonoPersona" tper, "Persona" per WHERE ((((((tel.idestadoregistro = 1) AND (tper.idestadoregistro = 1)) AND (tel.id = tper.idtelefono)) AND (per.idestadoregistro = 1)) AND (tper.idpersona = per.id)) AND (per.idtipopersona = 3));


ALTER TABLE negocio.vw_telefonocontacto OWNER TO postgres;

--
-- TOC entry 247 (class 1259 OID 257007)
-- Name: vw_telefonodireccion; Type: VIEW; Schema: negocio; Owner: postgres
--

CREATE VIEW vw_telefonodireccion AS
    SELECT tel.id, tel.numero, tel.idempresaproveedor, teldir.iddireccion FROM "Telefono" tel, "TelefonoDireccion" teldir WHERE (((tel.idestadoregistro = 1) AND (teldir.idestadoregistro = 1)) AND (tel.id = teldir.idtelefono));


ALTER TABLE negocio.vw_telefonodireccion OWNER TO postgres;

SET search_path = seguridad, pg_catalog;

--
-- TOC entry 248 (class 1259 OID 257011)
-- Name: rol; Type: TABLE; Schema: seguridad; Owner: postgres; Tablespace: 
--

CREATE TABLE rol (
    id integer NOT NULL,
    nombre character varying(30)
);


ALTER TABLE seguridad.rol OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 257014)
-- Name: usuario; Type: TABLE; Schema: seguridad; Owner: postgres; Tablespace: 
--

CREATE TABLE usuario (
    id integer DEFAULT 0 NOT NULL,
    usuario character varying(15) NOT NULL,
    credencial character varying(50) NOT NULL,
    id_rol integer,
    nombres character varying(50),
    apepaterno character varying(20),
    apematerno character varying(20),
    fecnacimiento date,
    vendedor boolean DEFAULT false,
    cambiarclave boolean DEFAULT false NOT NULL,
    feccaducacredencial date
);


ALTER TABLE seguridad.usuario OWNER TO postgres;

--
-- TOC entry 2774 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN usuario.id; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN usuario.id IS 'identificador de usuario';


--
-- TOC entry 2775 (class 0 OID 0)
-- Dependencies: 249
-- Name: COLUMN usuario.usuario; Type: COMMENT; Schema: seguridad; Owner: postgres
--

COMMENT ON COLUMN usuario.usuario IS 'usuario de inicio de sesion';


--
-- TOC entry 250 (class 1259 OID 257020)
-- Name: vw_listarusuarios; Type: VIEW; Schema: seguridad; Owner: postgres
--

CREATE VIEW vw_listarusuarios AS
    SELECT u.id, u.usuario, u.credencial, u.id_rol, r.nombre, u.nombres, u.apepaterno, u.apematerno, u.vendedor, u.fecnacimiento, u.cambiarclave, u.feccaducacredencial FROM usuario u, rol r WHERE (u.id_rol = r.id);


ALTER TABLE seguridad.vw_listarusuarios OWNER TO postgres;

SET search_path = soporte, pg_catalog;

--
-- TOC entry 251 (class 1259 OID 257024)
-- Name: ConfiguracionTipoServicio; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "ConfiguracionTipoServicio" (
    idtiposervicio integer NOT NULL,
    muestraaerolinea boolean,
    muestraempresatransporte boolean,
    muestrahotel boolean,
    muestraproveedor boolean,
    muestradescservicio boolean,
    muestrafechaservicio boolean,
    muestrafecharegreso boolean,
    muestracantidad boolean,
    muestraprecio boolean,
    muestraruta boolean,
    muestracomision boolean,
    muestraoperador boolean,
    muestratarifanegociada boolean,
    muestracodigoreserva boolean,
    muestranumeroboleto boolean,
    usuariocreacion character varying(15),
    fechacreacion timestamp with time zone,
    ipcreacion character varying(15),
    usuariomodificacion character varying(15),
    fechamodificacion timestamp with time zone,
    ipmodificacion character varying(15),
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE soporte."ConfiguracionTipoServicio" OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 257028)
-- Name: Parametro; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "Parametro" (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion character varying(200),
    valor character varying(50) NOT NULL,
    estado character(1) NOT NULL,
    editable boolean NOT NULL
);


ALTER TABLE soporte."Parametro" OWNER TO postgres;

--
-- TOC entry 253 (class 1259 OID 257031)
-- Name: TipoCambio; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE "TipoCambio" (
    id integer NOT NULL,
    monedaorigen character varying(3),
    monedadestino character varying(3),
    tipocambiocompra numeric(9,6) NOT NULL,
    tipocambioventa numeric(9,6) NOT NULL,
    usuariocreacion character varying(20) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE soporte."TipoCambio" OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 257961)
-- Name: destino; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE destino (
    id integer NOT NULL,
    idcontinente integer NOT NULL,
    idpais integer NOT NULL,
    codigoiata character varying(3) NOT NULL,
    idtipodestino integer NOT NULL,
    descripcion character varying(100) NOT NULL,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL
);


ALTER TABLE soporte.destino OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 257039)
-- Name: pais; Type: TABLE; Schema: soporte; Owner: postgres; Tablespace: 
--

CREATE TABLE pais (
    id integer NOT NULL,
    descripcion character varying(100),
    idcontinente integer NOT NULL,
    usuariocreacion character varying(15) NOT NULL,
    fechacreacion timestamp with time zone NOT NULL,
    ipcreacion character varying(15) NOT NULL,
    usuariomodificacion character varying(15) NOT NULL,
    fechamodificacion timestamp with time zone NOT NULL,
    ipmodificacion character varying(15) NOT NULL,
    idestadoregistro integer DEFAULT 1 NOT NULL,
    abreviado character varying(2)
);


ALTER TABLE soporte.pais OWNER TO postgres;

--
-- TOC entry 255 (class 1259 OID 257043)
-- Name: seq_comun; Type: SEQUENCE; Schema: soporte; Owner: postgres
--

CREATE SEQUENCE seq_comun
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soporte.seq_comun OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 257045)
-- Name: seq_destino; Type: SEQUENCE; Schema: soporte; Owner: postgres
--

CREATE SEQUENCE seq_destino
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soporte.seq_destino OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 257047)
-- Name: seq_pais; Type: SEQUENCE; Schema: soporte; Owner: postgres
--

CREATE SEQUENCE seq_pais
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE soporte.seq_pais OWNER TO postgres;

--
-- TOC entry 258 (class 1259 OID 257049)
-- Name: vw_catalogodepartamento; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogodepartamento AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.descripcion FROM ubigeo WHERE ((((ubigeo.idprovincia)::text = '00'::text) AND ((ubigeo.iddistrito)::text = '00'::text)) AND ((ubigeo.iddepartamento)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogodepartamento OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 257053)
-- Name: vw_catalogodistrito; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogodistrito AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.iddistrito, ubigeo.descripcion FROM ubigeo WHERE (((ubigeo.iddepartamento)::text <> '00'::text) AND ((ubigeo.idprovincia)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogodistrito OWNER TO postgres;

--
-- TOC entry 260 (class 1259 OID 257057)
-- Name: vw_catalogomaestro; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogomaestro AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion FROM "Tablamaestra" WHERE (("Tablamaestra".idmaestro <> 0) AND ("Tablamaestra".estado = 'A'::bpchar));


ALTER TABLE soporte.vw_catalogomaestro OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 257061)
-- Name: vw_catalogoprovincia; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_catalogoprovincia AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.descripcion FROM ubigeo WHERE ((((ubigeo.iddistrito)::text = '00'::text) AND ((ubigeo.idprovincia)::text <> '00'::text)) AND ((ubigeo.iddepartamento)::text <> '00'::text));


ALTER TABLE soporte.vw_catalogoprovincia OWNER TO postgres;

--
-- TOC entry 262 (class 1259 OID 257065)
-- Name: vw_listahijosmaestro; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listahijosmaestro AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".orden, "Tablamaestra".estado, CASE WHEN ("Tablamaestra".estado = 'A'::bpchar) THEN 'Activo'::text ELSE 'Inactivo'::text END AS descestado, "Tablamaestra".abreviatura FROM "Tablamaestra" WHERE ("Tablamaestra".idmaestro <> 0);


ALTER TABLE soporte.vw_listahijosmaestro OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 257069)
-- Name: vw_listamaestros; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listamaestros AS
    SELECT "Tablamaestra".id, "Tablamaestra".idmaestro, "Tablamaestra".nombre, "Tablamaestra".descripcion, "Tablamaestra".orden, "Tablamaestra".estado, CASE WHEN ("Tablamaestra".estado = 'A'::bpchar) THEN 'ACTIVO'::text ELSE 'INACTIVO'::text END AS descestado FROM "Tablamaestra" WHERE ("Tablamaestra".idmaestro = 0);


ALTER TABLE soporte.vw_listamaestros OWNER TO postgres;

--
-- TOC entry 264 (class 1259 OID 257073)
-- Name: vw_listaparametros; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_listaparametros AS
    SELECT "Parametro".id, "Parametro".nombre, "Parametro".descripcion, "Parametro".valor, "Parametro".estado, "Parametro".editable FROM "Parametro";


ALTER TABLE soporte.vw_listaparametros OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 257077)
-- Name: vw_ubigeo; Type: VIEW; Schema: soporte; Owner: postgres
--

CREATE VIEW vw_ubigeo AS
    SELECT ubigeo.id, ubigeo.iddepartamento, ubigeo.idprovincia, ubigeo.iddistrito, ubigeo.descripcion FROM ubigeo;


ALTER TABLE soporte.vw_ubigeo OWNER TO postgres;

SET search_path = seguridad, pg_catalog;

INSERT INTO rol VALUES (1, 'admin');
INSERT INTO rol VALUES (2, 'vendedor');
INSERT INTO rol VALUES (3, 'Supervisor Administrativo');
INSERT INTO rol VALUES (4, 'Supervisor Ventas');

INSERT INTO usuario VALUES (1, 'admin', 'a046juN5Vet0Y2mwZ2ty4Q==', 1, 'ADMIN', 'ADMIN', 'ADMIN', '1980-01-01', NULL, false, '2015-11-03');

SET search_path = soporte, pg_catalog;

INSERT INTO "Parametro" VALUES (1, 'IGV', 'IMPUSTO GENERAL A LAS VENTAS', '0.18', 'A', true);
INSERT INTO "Parametro" VALUES (2, 'TIPO DE CAMBIO', 'TIPO DE CAMBIO', '2.8', 'A', true);
INSERT INTO "Parametro" VALUES (3, 'TASA PRE CREDITO', 'TASA PREDETERMINADA DE CREDITO', '0.015', 'A', true);
INSERT INTO "Parametro" VALUES (4, 'CODIGO FEE', 'CODIGO DE SERVICIO FEE', '6', 'A', true);
INSERT INTO "Parametro" VALUES (5, 'CODIGO IGV', 'CODIGO DEL SERVIDIO DE IMPUESTO IGV', '13', 'A', true);


INSERT INTO ubigeo VALUES ('010000', '01', '00', '00', 'AMAZONAS');
INSERT INTO ubigeo VALUES ('010100', '01', '01', '00', 'CHACHAPOYAS');
INSERT INTO ubigeo VALUES ('010101', '01', '01', '01', 'CHACHAPOYAS');
INSERT INTO ubigeo VALUES ('010102', '01', '01', '02', 'ASUNCION');
INSERT INTO ubigeo VALUES ('010103', '01', '01', '03', 'BALSAS');
INSERT INTO ubigeo VALUES ('010104', '01', '01', '04', 'CHETO');
INSERT INTO ubigeo VALUES ('010105', '01', '01', '05', 'CHILIQUIN');
INSERT INTO ubigeo VALUES ('010106', '01', '01', '06', 'CHUQUIBAMBA');
INSERT INTO ubigeo VALUES ('010107', '01', '01', '07', 'GRANADA');
INSERT INTO ubigeo VALUES ('010108', '01', '01', '08', 'HUANCAS');
INSERT INTO ubigeo VALUES ('010109', '01', '01', '09', 'LA JALCA');
INSERT INTO ubigeo VALUES ('010110', '01', '01', '10', 'LEIMEBAMBA');
INSERT INTO ubigeo VALUES ('010111', '01', '01', '11', 'LEVANTO');
INSERT INTO ubigeo VALUES ('010112', '01', '01', '12', 'MAGDALENA');
INSERT INTO ubigeo VALUES ('010113', '01', '01', '13', 'MARISCAL CASTILLA');
INSERT INTO ubigeo VALUES ('010114', '01', '01', '14', 'MOLINOPAMPA');
INSERT INTO ubigeo VALUES ('010115', '01', '01', '15', 'MONTEVIDEO');
INSERT INTO ubigeo VALUES ('010116', '01', '01', '16', 'OLLEROS');
INSERT INTO ubigeo VALUES ('010117', '01', '01', '17', 'QUINJALCA');
INSERT INTO ubigeo VALUES ('010118', '01', '01', '18', 'SAN FRANCISCO DE DAGUAS');
INSERT INTO ubigeo VALUES ('010119', '01', '01', '19', 'SAN ISIDRO DE MAINO');
INSERT INTO ubigeo VALUES ('010120', '01', '01', '20', 'SOLOCO');
INSERT INTO ubigeo VALUES ('010121', '01', '01', '21', 'SONCHE');
INSERT INTO ubigeo VALUES ('010200', '01', '02', '00', 'BAGUA');
INSERT INTO ubigeo VALUES ('010201', '01', '02', '01', 'BAGUA');
INSERT INTO ubigeo VALUES ('010202', '01', '02', '02', 'ARAMANGO');
INSERT INTO ubigeo VALUES ('010203', '01', '02', '03', 'COPALLIN');
INSERT INTO ubigeo VALUES ('010204', '01', '02', '04', 'EL PARCO');
INSERT INTO ubigeo VALUES ('010205', '01', '02', '05', 'IMAZA');
INSERT INTO ubigeo VALUES ('010206', '01', '02', '06', 'LA PECA');
INSERT INTO ubigeo VALUES ('010300', '01', '03', '00', 'BONGARA');
INSERT INTO ubigeo VALUES ('010301', '01', '03', '01', 'JUMBILLA');
INSERT INTO ubigeo VALUES ('010302', '01', '03', '02', 'CHISQUILLA');
INSERT INTO ubigeo VALUES ('010303', '01', '03', '03', 'CHURUJA');
INSERT INTO ubigeo VALUES ('010304', '01', '03', '04', 'COROSHA');
INSERT INTO ubigeo VALUES ('010305', '01', '03', '05', 'CUISPES');
INSERT INTO ubigeo VALUES ('010306', '01', '03', '06', 'FLORIDA');
INSERT INTO ubigeo VALUES ('010307', '01', '03', '07', 'JAZAN');
INSERT INTO ubigeo VALUES ('010308', '01', '03', '08', 'RECTA');
INSERT INTO ubigeo VALUES ('010309', '01', '03', '09', 'SAN CARLOS');
INSERT INTO ubigeo VALUES ('010310', '01', '03', '10', 'SHIPASBAMBA');
INSERT INTO ubigeo VALUES ('010311', '01', '03', '11', 'VALERA');
INSERT INTO ubigeo VALUES ('010312', '01', '03', '12', 'YAMBRASBAMBA');
INSERT INTO ubigeo VALUES ('010400', '01', '04', '00', 'CONDORCANQUI');
INSERT INTO ubigeo VALUES ('010401', '01', '04', '01', 'NIEVA');
INSERT INTO ubigeo VALUES ('010402', '01', '04', '02', 'EL CENEPA');
INSERT INTO ubigeo VALUES ('010403', '01', '04', '03', 'RIO SANTIAGO');
INSERT INTO ubigeo VALUES ('010500', '01', '05', '00', 'LUYA');
INSERT INTO ubigeo VALUES ('010501', '01', '05', '01', 'LAMUD');
INSERT INTO ubigeo VALUES ('010502', '01', '05', '02', 'CAMPORREDONDO');
INSERT INTO ubigeo VALUES ('010503', '01', '05', '03', 'COCABAMBA');
INSERT INTO ubigeo VALUES ('010504', '01', '05', '04', 'COLCAMAR');
INSERT INTO ubigeo VALUES ('010505', '01', '05', '05', 'CONILA');
INSERT INTO ubigeo VALUES ('010506', '01', '05', '06', 'INGUILPATA');
INSERT INTO ubigeo VALUES ('010507', '01', '05', '07', 'LONGUITA');
INSERT INTO ubigeo VALUES ('010508', '01', '05', '08', 'LONYA CHICO');
INSERT INTO ubigeo VALUES ('010509', '01', '05', '09', 'LUYA');
INSERT INTO ubigeo VALUES ('010510', '01', '05', '10', 'LUYA VIEJO');
INSERT INTO ubigeo VALUES ('010511', '01', '05', '11', 'MARIA');
INSERT INTO ubigeo VALUES ('010512', '01', '05', '12', 'OCALLI');
INSERT INTO ubigeo VALUES ('010513', '01', '05', '13', 'OCUMAL');
INSERT INTO ubigeo VALUES ('010514', '01', '05', '14', 'PISUQUIA');
INSERT INTO ubigeo VALUES ('010515', '01', '05', '15', 'PROVIDENCIA');
INSERT INTO ubigeo VALUES ('010516', '01', '05', '16', 'SAN CRISTOBAL');
INSERT INTO ubigeo VALUES ('010517', '01', '05', '17', 'SAN FRANCISCO DEL YESO');
INSERT INTO ubigeo VALUES ('010518', '01', '05', '18', 'SAN JERONIMO');
INSERT INTO ubigeo VALUES ('010519', '01', '05', '19', 'SAN JUAN DE LOPECANCHA');
INSERT INTO ubigeo VALUES ('010520', '01', '05', '20', 'SANTA CATALINA');
INSERT INTO ubigeo VALUES ('010521', '01', '05', '21', 'SANTO TOMAS');
INSERT INTO ubigeo VALUES ('010522', '01', '05', '22', 'TINGO');
INSERT INTO ubigeo VALUES ('010523', '01', '05', '23', 'TRITA');
INSERT INTO ubigeo VALUES ('010600', '01', '06', '00', 'RODRIGUEZ DE MENDOZA');
INSERT INTO ubigeo VALUES ('010601', '01', '06', '01', 'SAN NICOLAS');
INSERT INTO ubigeo VALUES ('010602', '01', '06', '02', 'CHIRIMOTO');
INSERT INTO ubigeo VALUES ('010603', '01', '06', '03', 'COCHAMAL');
INSERT INTO ubigeo VALUES ('010604', '01', '06', '04', 'HUAMBO');
INSERT INTO ubigeo VALUES ('010605', '01', '06', '05', 'LIMABAMBA');
INSERT INTO ubigeo VALUES ('010606', '01', '06', '06', 'LONGAR');
INSERT INTO ubigeo VALUES ('010607', '01', '06', '07', 'MARISCAL BENAVIDES');
INSERT INTO ubigeo VALUES ('010608', '01', '06', '08', 'MILPUC');
INSERT INTO ubigeo VALUES ('010609', '01', '06', '09', 'OMIA');
INSERT INTO ubigeo VALUES ('010610', '01', '06', '10', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('010611', '01', '06', '11', 'TOTORA');
INSERT INTO ubigeo VALUES ('010612', '01', '06', '12', 'VISTA ALEGRE');
INSERT INTO ubigeo VALUES ('010700', '01', '07', '00', 'UTCUBAMBA');
INSERT INTO ubigeo VALUES ('010701', '01', '07', '01', 'BAGUA GRANDE');
INSERT INTO ubigeo VALUES ('010702', '01', '07', '02', 'CAJARURO');
INSERT INTO ubigeo VALUES ('010703', '01', '07', '03', 'CUMBA');
INSERT INTO ubigeo VALUES ('010704', '01', '07', '04', 'EL MILAGRO');
INSERT INTO ubigeo VALUES ('010705', '01', '07', '05', 'JAMALCA');
INSERT INTO ubigeo VALUES ('010706', '01', '07', '06', 'LONYA GRANDE');
INSERT INTO ubigeo VALUES ('010707', '01', '07', '07', 'YAMON');
INSERT INTO ubigeo VALUES ('020000', '02', '00', '00', 'ANCASH');
INSERT INTO ubigeo VALUES ('020100', '02', '01', '00', 'HUARAZ');
INSERT INTO ubigeo VALUES ('020101', '02', '01', '01', 'HUARAZ');
INSERT INTO ubigeo VALUES ('020102', '02', '01', '02', 'COCHABAMBA');
INSERT INTO ubigeo VALUES ('020103', '02', '01', '03', 'COLCABAMBA');
INSERT INTO ubigeo VALUES ('020104', '02', '01', '04', 'HUANCHAY');
INSERT INTO ubigeo VALUES ('020105', '02', '01', '05', 'INDEPENDENCIA');
INSERT INTO ubigeo VALUES ('020106', '02', '01', '06', 'JANGAS');
INSERT INTO ubigeo VALUES ('020107', '02', '01', '07', 'LA LIBERTAD');
INSERT INTO ubigeo VALUES ('020108', '02', '01', '08', 'OLLEROS');
INSERT INTO ubigeo VALUES ('020109', '02', '01', '09', 'PAMPAS');
INSERT INTO ubigeo VALUES ('020110', '02', '01', '10', 'PARIACOTO');
INSERT INTO ubigeo VALUES ('020111', '02', '01', '11', 'PIRA');
INSERT INTO ubigeo VALUES ('020112', '02', '01', '12', 'TARICA');
INSERT INTO ubigeo VALUES ('020200', '02', '02', '00', 'AIJA');
INSERT INTO ubigeo VALUES ('020201', '02', '02', '01', 'AIJA');
INSERT INTO ubigeo VALUES ('020202', '02', '02', '02', 'CORIS');
INSERT INTO ubigeo VALUES ('020203', '02', '02', '03', 'HUACLLAN');
INSERT INTO ubigeo VALUES ('020204', '02', '02', '04', 'LA MERCED');
INSERT INTO ubigeo VALUES ('020205', '02', '02', '05', 'SUCCHA');
INSERT INTO ubigeo VALUES ('020300', '02', '03', '00', 'ANTONIO RAYMONDI');
INSERT INTO ubigeo VALUES ('020301', '02', '03', '01', 'LLAMELLIN');
INSERT INTO ubigeo VALUES ('020302', '02', '03', '02', 'ACZO');
INSERT INTO ubigeo VALUES ('020303', '02', '03', '03', 'CHACCHO');
INSERT INTO ubigeo VALUES ('020304', '02', '03', '04', 'CHINGAS');
INSERT INTO ubigeo VALUES ('020305', '02', '03', '05', 'MIRGAS');
INSERT INTO ubigeo VALUES ('020306', '02', '03', '06', 'SAN JUAN DE RONTOY');
INSERT INTO ubigeo VALUES ('020400', '02', '04', '00', 'ASUNCION');
INSERT INTO ubigeo VALUES ('020401', '02', '04', '01', 'CHACAS');
INSERT INTO ubigeo VALUES ('020402', '02', '04', '02', 'ACOCHACA');
INSERT INTO ubigeo VALUES ('020500', '02', '05', '00', 'BOLOGNESI');
INSERT INTO ubigeo VALUES ('020501', '02', '05', '01', 'CHIQUIAN');
INSERT INTO ubigeo VALUES ('020502', '02', '05', '02', 'ABELARDO PARDO LEZAMETA');
INSERT INTO ubigeo VALUES ('020503', '02', '05', '03', 'ANTONIO RAYMONDI');
INSERT INTO ubigeo VALUES ('020504', '02', '05', '04', 'AQUIA');
INSERT INTO ubigeo VALUES ('020505', '02', '05', '05', 'CAJACAY');
INSERT INTO ubigeo VALUES ('020506', '02', '05', '06', 'CANIS');
INSERT INTO ubigeo VALUES ('020507', '02', '05', '07', 'COLQUIOC');
INSERT INTO ubigeo VALUES ('020508', '02', '05', '08', 'HUALLANCA');
INSERT INTO ubigeo VALUES ('020509', '02', '05', '09', 'HUASTA');
INSERT INTO ubigeo VALUES ('020510', '02', '05', '10', 'HUAYLLACAYAN');
INSERT INTO ubigeo VALUES ('020511', '02', '05', '11', 'LA PRIMAVERA');
INSERT INTO ubigeo VALUES ('020512', '02', '05', '12', 'MANGAS');
INSERT INTO ubigeo VALUES ('020513', '02', '05', '13', 'PACLLON');
INSERT INTO ubigeo VALUES ('020514', '02', '05', '14', 'SAN MIGUEL DE CORPANQUI');
INSERT INTO ubigeo VALUES ('020515', '02', '05', '15', 'TICLLOS');
INSERT INTO ubigeo VALUES ('020600', '02', '06', '00', 'CARHUAZ');
INSERT INTO ubigeo VALUES ('020601', '02', '06', '01', 'CARHUAZ');
INSERT INTO ubigeo VALUES ('020602', '02', '06', '02', 'ACOPAMPA');
INSERT INTO ubigeo VALUES ('020603', '02', '06', '03', 'AMASHCA');
INSERT INTO ubigeo VALUES ('020604', '02', '06', '04', 'ANTA');
INSERT INTO ubigeo VALUES ('020605', '02', '06', '05', 'ATAQUERO');
INSERT INTO ubigeo VALUES ('020606', '02', '06', '06', 'MARCARA');
INSERT INTO ubigeo VALUES ('020607', '02', '06', '07', 'PARIAHUANCA');
INSERT INTO ubigeo VALUES ('020608', '02', '06', '08', 'SAN MIGUEL DE ACO');
INSERT INTO ubigeo VALUES ('020609', '02', '06', '09', 'SHILLA');
INSERT INTO ubigeo VALUES ('020610', '02', '06', '10', 'TINCO');
INSERT INTO ubigeo VALUES ('020611', '02', '06', '11', 'YUNGAR');
INSERT INTO ubigeo VALUES ('020700', '02', '07', '00', 'CARLOS FERMIN FITZCARRALD');
INSERT INTO ubigeo VALUES ('020701', '02', '07', '01', 'SAN LUIS');
INSERT INTO ubigeo VALUES ('020702', '02', '07', '02', 'SAN NICOLAS');
INSERT INTO ubigeo VALUES ('020703', '02', '07', '03', 'YAUYA');
INSERT INTO ubigeo VALUES ('020800', '02', '08', '00', 'CASMA');
INSERT INTO ubigeo VALUES ('020801', '02', '08', '01', 'CASMA');
INSERT INTO ubigeo VALUES ('020802', '02', '08', '02', 'BUENA VISTA ALTA');
INSERT INTO ubigeo VALUES ('020803', '02', '08', '03', 'COMANDANTE NOEL');
INSERT INTO ubigeo VALUES ('020804', '02', '08', '04', 'YAUTAN');
INSERT INTO ubigeo VALUES ('020900', '02', '09', '00', 'CORONGO');
INSERT INTO ubigeo VALUES ('020901', '02', '09', '01', 'CORONGO');
INSERT INTO ubigeo VALUES ('020902', '02', '09', '02', 'ACO');
INSERT INTO ubigeo VALUES ('020903', '02', '09', '03', 'BAMBAS');
INSERT INTO ubigeo VALUES ('020904', '02', '09', '04', 'CUSCA');
INSERT INTO ubigeo VALUES ('020905', '02', '09', '05', 'LA PAMPA');
INSERT INTO ubigeo VALUES ('020906', '02', '09', '06', 'YANAC');
INSERT INTO ubigeo VALUES ('020907', '02', '09', '07', 'YUPAN');
INSERT INTO ubigeo VALUES ('021000', '02', '10', '00', 'HUARI');
INSERT INTO ubigeo VALUES ('021001', '02', '10', '01', 'HUARI');
INSERT INTO ubigeo VALUES ('021002', '02', '10', '02', 'ANRA');
INSERT INTO ubigeo VALUES ('021003', '02', '10', '03', 'CAJAY');
INSERT INTO ubigeo VALUES ('021004', '02', '10', '04', 'CHAVIN DE HUANTAR');
INSERT INTO ubigeo VALUES ('021005', '02', '10', '05', 'HUACACHI');
INSERT INTO ubigeo VALUES ('021006', '02', '10', '06', 'HUACCHIS');
INSERT INTO ubigeo VALUES ('021007', '02', '10', '07', 'HUACHIS');
INSERT INTO ubigeo VALUES ('021008', '02', '10', '08', 'HUANTAR');
INSERT INTO ubigeo VALUES ('021009', '02', '10', '09', 'MASIN');
INSERT INTO ubigeo VALUES ('021010', '02', '10', '10', 'PAUCAS');
INSERT INTO ubigeo VALUES ('021011', '02', '10', '11', 'PONTO');
INSERT INTO ubigeo VALUES ('021012', '02', '10', '12', 'RAHUAPAMPA');
INSERT INTO ubigeo VALUES ('021013', '02', '10', '13', 'RAPAYAN');
INSERT INTO ubigeo VALUES ('021014', '02', '10', '14', 'SAN MARCOS');
INSERT INTO ubigeo VALUES ('021015', '02', '10', '15', 'SAN PEDRO DE CHANA');
INSERT INTO ubigeo VALUES ('021016', '02', '10', '16', 'UCO');
INSERT INTO ubigeo VALUES ('021100', '02', '11', '00', 'HUARMEY');
INSERT INTO ubigeo VALUES ('021101', '02', '11', '01', 'HUARMEY');
INSERT INTO ubigeo VALUES ('021102', '02', '11', '02', 'COCHAPETI');
INSERT INTO ubigeo VALUES ('021103', '02', '11', '03', 'CULEBRAS');
INSERT INTO ubigeo VALUES ('021104', '02', '11', '04', 'HUAYAN');
INSERT INTO ubigeo VALUES ('021105', '02', '11', '05', 'MALVAS');
INSERT INTO ubigeo VALUES ('021200', '02', '12', '00', 'HUAYLAS');
INSERT INTO ubigeo VALUES ('021201', '02', '12', '01', 'CARAZ');
INSERT INTO ubigeo VALUES ('021202', '02', '12', '02', 'HUALLANCA');
INSERT INTO ubigeo VALUES ('021203', '02', '12', '03', 'HUATA');
INSERT INTO ubigeo VALUES ('021204', '02', '12', '04', 'HUAYLAS');
INSERT INTO ubigeo VALUES ('021205', '02', '12', '05', 'MATO');
INSERT INTO ubigeo VALUES ('021206', '02', '12', '06', 'PAMPAROMAS');
INSERT INTO ubigeo VALUES ('021207', '02', '12', '07', 'PUEBLO LIBRE');
INSERT INTO ubigeo VALUES ('021208', '02', '12', '08', 'SANTA CRUZ');
INSERT INTO ubigeo VALUES ('021209', '02', '12', '09', 'SANTO TORIBIO');
INSERT INTO ubigeo VALUES ('021210', '02', '12', '10', 'YURACMARCA');
INSERT INTO ubigeo VALUES ('021300', '02', '13', '00', 'MARISCAL LUZURIAGA');
INSERT INTO ubigeo VALUES ('021301', '02', '13', '01', 'PISCOBAMBA');
INSERT INTO ubigeo VALUES ('021302', '02', '13', '02', 'CASCA');
INSERT INTO ubigeo VALUES ('021303', '02', '13', '03', 'ELEAZAR GUZMAN BARRON');
INSERT INTO ubigeo VALUES ('021304', '02', '13', '04', 'FIDEL OLIVAS ESCUDERO');
INSERT INTO ubigeo VALUES ('021305', '02', '13', '05', 'LLAMA');
INSERT INTO ubigeo VALUES ('021306', '02', '13', '06', 'LLUMPA');
INSERT INTO ubigeo VALUES ('021307', '02', '13', '07', 'LUCMA');
INSERT INTO ubigeo VALUES ('021308', '02', '13', '08', 'MUSGA');
INSERT INTO ubigeo VALUES ('021400', '02', '14', '00', 'OCROS');
INSERT INTO ubigeo VALUES ('021401', '02', '14', '01', 'OCROS');
INSERT INTO ubigeo VALUES ('021402', '02', '14', '02', 'ACAS');
INSERT INTO ubigeo VALUES ('021403', '02', '14', '03', 'CAJAMARQUILLA');
INSERT INTO ubigeo VALUES ('021404', '02', '14', '04', 'CARHUAPAMPA');
INSERT INTO ubigeo VALUES ('021405', '02', '14', '05', 'COCHAS');
INSERT INTO ubigeo VALUES ('021406', '02', '14', '06', 'CONGAS');
INSERT INTO ubigeo VALUES ('021407', '02', '14', '07', 'LLIPA');
INSERT INTO ubigeo VALUES ('021408', '02', '14', '08', 'SAN CRISTOBAL DE RAJAN');
INSERT INTO ubigeo VALUES ('021409', '02', '14', '09', 'SAN PEDRO');
INSERT INTO ubigeo VALUES ('021410', '02', '14', '10', 'SANTIAGO DE CHILCAS');
INSERT INTO ubigeo VALUES ('021500', '02', '15', '00', 'PALLASCA');
INSERT INTO ubigeo VALUES ('021501', '02', '15', '01', 'CABANA');
INSERT INTO ubigeo VALUES ('021502', '02', '15', '02', 'BOLOGNESI');
INSERT INTO ubigeo VALUES ('021503', '02', '15', '03', 'CONCHUCOS');
INSERT INTO ubigeo VALUES ('021504', '02', '15', '04', 'HUACASCHUQUE');
INSERT INTO ubigeo VALUES ('021505', '02', '15', '05', 'HUANDOVAL');
INSERT INTO ubigeo VALUES ('021506', '02', '15', '06', 'LACABAMBA');
INSERT INTO ubigeo VALUES ('021507', '02', '15', '07', 'LLAPO');
INSERT INTO ubigeo VALUES ('021508', '02', '15', '08', 'PALLASCA');
INSERT INTO ubigeo VALUES ('021509', '02', '15', '09', 'PAMPAS');
INSERT INTO ubigeo VALUES ('021510', '02', '15', '10', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('021511', '02', '15', '11', 'TAUCA');
INSERT INTO ubigeo VALUES ('021600', '02', '16', '00', 'POMABAMBA');
INSERT INTO ubigeo VALUES ('021601', '02', '16', '01', 'POMABAMBA');
INSERT INTO ubigeo VALUES ('021602', '02', '16', '02', 'HUAYLLAN');
INSERT INTO ubigeo VALUES ('021603', '02', '16', '03', 'PAROBAMBA');
INSERT INTO ubigeo VALUES ('021604', '02', '16', '04', 'QUINUABAMBA');
INSERT INTO ubigeo VALUES ('021700', '02', '17', '00', 'RECUAY');
INSERT INTO ubigeo VALUES ('021701', '02', '17', '01', 'RECUAY');
INSERT INTO ubigeo VALUES ('021702', '02', '17', '02', 'CATAC');
INSERT INTO ubigeo VALUES ('021703', '02', '17', '03', 'COTAPARACO');
INSERT INTO ubigeo VALUES ('021704', '02', '17', '04', 'HUAYLLAPAMPA');
INSERT INTO ubigeo VALUES ('021705', '02', '17', '05', 'LLACLLIN');
INSERT INTO ubigeo VALUES ('021706', '02', '17', '06', 'MARCA');
INSERT INTO ubigeo VALUES ('021707', '02', '17', '07', 'PAMPAS CHICO');
INSERT INTO ubigeo VALUES ('021708', '02', '17', '08', 'PARARIN');
INSERT INTO ubigeo VALUES ('021709', '02', '17', '09', 'TAPACOCHA');
INSERT INTO ubigeo VALUES ('021710', '02', '17', '10', 'TICAPAMPA');
INSERT INTO ubigeo VALUES ('021800', '02', '18', '00', 'SANTA');
INSERT INTO ubigeo VALUES ('021801', '02', '18', '01', 'CHIMBOTE');
INSERT INTO ubigeo VALUES ('021802', '02', '18', '02', 'CACERES DEL PERU');
INSERT INTO ubigeo VALUES ('021803', '02', '18', '03', 'COISHCO');
INSERT INTO ubigeo VALUES ('021804', '02', '18', '04', 'MACATE');
INSERT INTO ubigeo VALUES ('021805', '02', '18', '05', 'MORO');
INSERT INTO ubigeo VALUES ('021806', '02', '18', '06', 'NEPEÑA');
INSERT INTO ubigeo VALUES ('021807', '02', '18', '07', 'SAMANCO');
INSERT INTO ubigeo VALUES ('021808', '02', '18', '08', 'SANTA');
INSERT INTO ubigeo VALUES ('021809', '02', '18', '09', 'NUEVO CHIMBOTE');
INSERT INTO ubigeo VALUES ('021900', '02', '19', '00', 'SIHUAS');
INSERT INTO ubigeo VALUES ('021901', '02', '19', '01', 'SIHUAS');
INSERT INTO ubigeo VALUES ('021902', '02', '19', '02', 'ACOBAMBA');
INSERT INTO ubigeo VALUES ('021903', '02', '19', '03', 'ALFONSO UGARTE');
INSERT INTO ubigeo VALUES ('021904', '02', '19', '04', 'CASHAPAMPA');
INSERT INTO ubigeo VALUES ('021905', '02', '19', '05', 'CHINGALPO');
INSERT INTO ubigeo VALUES ('021906', '02', '19', '06', 'HUAYLLABAMBA');
INSERT INTO ubigeo VALUES ('021907', '02', '19', '07', 'QUICHES');
INSERT INTO ubigeo VALUES ('021908', '02', '19', '08', 'RAGASH');
INSERT INTO ubigeo VALUES ('021909', '02', '19', '09', 'SAN JUAN');
INSERT INTO ubigeo VALUES ('021910', '02', '19', '10', 'SICSIBAMBA');
INSERT INTO ubigeo VALUES ('022000', '02', '20', '00', 'YUNGAY');
INSERT INTO ubigeo VALUES ('022001', '02', '20', '01', 'YUNGAY');
INSERT INTO ubigeo VALUES ('022002', '02', '20', '02', 'CASCAPARA');
INSERT INTO ubigeo VALUES ('022003', '02', '20', '03', 'MANCOS');
INSERT INTO ubigeo VALUES ('022004', '02', '20', '04', 'MATACOTO');
INSERT INTO ubigeo VALUES ('022005', '02', '20', '05', 'QUILLO');
INSERT INTO ubigeo VALUES ('022006', '02', '20', '06', 'RANRAHIRCA');
INSERT INTO ubigeo VALUES ('022007', '02', '20', '07', 'SHUPLUY');
INSERT INTO ubigeo VALUES ('022008', '02', '20', '08', 'YANAMA');
INSERT INTO ubigeo VALUES ('030000', '03', '00', '00', 'APURIMAC');
INSERT INTO ubigeo VALUES ('030100', '03', '01', '00', 'ABANCAY');
INSERT INTO ubigeo VALUES ('030101', '03', '01', '01', 'ABANCAY');
INSERT INTO ubigeo VALUES ('030102', '03', '01', '02', 'CHACOCHE');
INSERT INTO ubigeo VALUES ('030103', '03', '01', '03', 'CIRCA');
INSERT INTO ubigeo VALUES ('030104', '03', '01', '04', 'CURAHUASI');
INSERT INTO ubigeo VALUES ('030105', '03', '01', '05', 'HUANIPACA');
INSERT INTO ubigeo VALUES ('030106', '03', '01', '06', 'LAMBRAMA');
INSERT INTO ubigeo VALUES ('030107', '03', '01', '07', 'PICHIRHUA');
INSERT INTO ubigeo VALUES ('030108', '03', '01', '08', 'SAN PEDRO DE CACHORA');
INSERT INTO ubigeo VALUES ('030109', '03', '01', '09', 'TAMBURCO');
INSERT INTO ubigeo VALUES ('030200', '03', '02', '00', 'ANDAHUAYLAS');
INSERT INTO ubigeo VALUES ('030201', '03', '02', '01', 'ANDAHUAYLAS');
INSERT INTO ubigeo VALUES ('030202', '03', '02', '02', 'ANDARAPA');
INSERT INTO ubigeo VALUES ('030203', '03', '02', '03', 'CHIARA');
INSERT INTO ubigeo VALUES ('030204', '03', '02', '04', 'HUANCARAMA');
INSERT INTO ubigeo VALUES ('030205', '03', '02', '05', 'HUANCARAY');
INSERT INTO ubigeo VALUES ('030206', '03', '02', '06', 'HUAYANA');
INSERT INTO ubigeo VALUES ('030207', '03', '02', '07', 'KISHUARA');
INSERT INTO ubigeo VALUES ('030208', '03', '02', '08', 'PACOBAMBA');
INSERT INTO ubigeo VALUES ('030209', '03', '02', '09', 'PACUCHA');
INSERT INTO ubigeo VALUES ('030210', '03', '02', '10', 'PAMPACHIRI');
INSERT INTO ubigeo VALUES ('030211', '03', '02', '11', 'POMACOCHA');
INSERT INTO ubigeo VALUES ('030212', '03', '02', '12', 'SAN ANTONIO DE CACHI');
INSERT INTO ubigeo VALUES ('030213', '03', '02', '13', 'SAN JERONIMO');
INSERT INTO ubigeo VALUES ('030214', '03', '02', '14', 'SAN MIGUEL DE CHACCRAMPA');
INSERT INTO ubigeo VALUES ('030215', '03', '02', '15', 'SANTA MARIA DE CHICMO');
INSERT INTO ubigeo VALUES ('030216', '03', '02', '16', 'TALAVERA');
INSERT INTO ubigeo VALUES ('030217', '03', '02', '17', 'TUMAY HUARACA');
INSERT INTO ubigeo VALUES ('030218', '03', '02', '18', 'TURPO');
INSERT INTO ubigeo VALUES ('030219', '03', '02', '19', 'KAQUIABAMBA');
INSERT INTO ubigeo VALUES ('030300', '03', '03', '00', 'ANTABAMBA');
INSERT INTO ubigeo VALUES ('030301', '03', '03', '01', 'ANTABAMBA');
INSERT INTO ubigeo VALUES ('030302', '03', '03', '02', 'EL ORO');
INSERT INTO ubigeo VALUES ('030303', '03', '03', '03', 'HUAQUIRCA');
INSERT INTO ubigeo VALUES ('030304', '03', '03', '04', 'JUAN ESPINOZA MEDRANO');
INSERT INTO ubigeo VALUES ('030305', '03', '03', '05', 'OROPESA');
INSERT INTO ubigeo VALUES ('030306', '03', '03', '06', 'PACHACONAS');
INSERT INTO ubigeo VALUES ('030307', '03', '03', '07', 'SABAINO');
INSERT INTO ubigeo VALUES ('030400', '03', '04', '00', 'AYMARAES');
INSERT INTO ubigeo VALUES ('030401', '03', '04', '01', 'CHALHUANCA');
INSERT INTO ubigeo VALUES ('030402', '03', '04', '02', 'CAPAYA');
INSERT INTO ubigeo VALUES ('030403', '03', '04', '03', 'CARAYBAMBA');
INSERT INTO ubigeo VALUES ('030404', '03', '04', '04', 'CHAPIMARCA');
INSERT INTO ubigeo VALUES ('030405', '03', '04', '05', 'COLCABAMBA');
INSERT INTO ubigeo VALUES ('030406', '03', '04', '06', 'COTARUSE');
INSERT INTO ubigeo VALUES ('030407', '03', '04', '07', 'HUAYLLO');
INSERT INTO ubigeo VALUES ('030408', '03', '04', '08', 'JUSTO APU SAHUARAURA');
INSERT INTO ubigeo VALUES ('030409', '03', '04', '09', 'LUCRE');
INSERT INTO ubigeo VALUES ('030410', '03', '04', '10', 'POCOHUANCA');
INSERT INTO ubigeo VALUES ('030411', '03', '04', '11', 'SAN JUAN DE CHACÑA');
INSERT INTO ubigeo VALUES ('030412', '03', '04', '12', 'SAÑAYCA');
INSERT INTO ubigeo VALUES ('030413', '03', '04', '13', 'SORAYA');
INSERT INTO ubigeo VALUES ('030414', '03', '04', '14', 'TAPAIRIHUA');
INSERT INTO ubigeo VALUES ('030415', '03', '04', '15', 'TINTAY');
INSERT INTO ubigeo VALUES ('030416', '03', '04', '16', 'TORAYA');
INSERT INTO ubigeo VALUES ('030417', '03', '04', '17', 'YANACA');
INSERT INTO ubigeo VALUES ('030500', '03', '05', '00', 'COTABAMBAS');
INSERT INTO ubigeo VALUES ('030501', '03', '05', '01', 'TAMBOBAMBA');
INSERT INTO ubigeo VALUES ('030502', '03', '05', '02', 'COTABAMBAS');
INSERT INTO ubigeo VALUES ('030503', '03', '05', '03', 'COYLLURQUI');
INSERT INTO ubigeo VALUES ('030504', '03', '05', '04', 'HAQUIRA');
INSERT INTO ubigeo VALUES ('030505', '03', '05', '05', 'MARA');
INSERT INTO ubigeo VALUES ('030506', '03', '05', '06', 'CHALLHUAHUACHO');
INSERT INTO ubigeo VALUES ('030600', '03', '06', '00', 'CHINCHEROS');
INSERT INTO ubigeo VALUES ('030601', '03', '06', '01', 'CHINCHEROS');
INSERT INTO ubigeo VALUES ('030602', '03', '06', '02', 'ANCO_HUALLO');
INSERT INTO ubigeo VALUES ('030603', '03', '06', '03', 'COCHARCAS');
INSERT INTO ubigeo VALUES ('030604', '03', '06', '04', 'HUACCANA');
INSERT INTO ubigeo VALUES ('030605', '03', '06', '05', 'OCOBAMBA');
INSERT INTO ubigeo VALUES ('030606', '03', '06', '06', 'ONGOY');
INSERT INTO ubigeo VALUES ('030607', '03', '06', '07', 'URANMARCA');
INSERT INTO ubigeo VALUES ('030608', '03', '06', '08', 'RANRACANCHA');
INSERT INTO ubigeo VALUES ('030700', '03', '07', '00', 'GRAU');
INSERT INTO ubigeo VALUES ('030701', '03', '07', '01', 'CHUQUIBAMBILLA');
INSERT INTO ubigeo VALUES ('030702', '03', '07', '02', 'CURPAHUASI');
INSERT INTO ubigeo VALUES ('030703', '03', '07', '03', 'GAMARRA');
INSERT INTO ubigeo VALUES ('030704', '03', '07', '04', 'HUAYLLATI');
INSERT INTO ubigeo VALUES ('030705', '03', '07', '05', 'MAMARA');
INSERT INTO ubigeo VALUES ('030706', '03', '07', '06', 'MICAELA BASTIDAS');
INSERT INTO ubigeo VALUES ('030707', '03', '07', '07', 'PATAYPAMPA');
INSERT INTO ubigeo VALUES ('030708', '03', '07', '08', 'PROGRESO');
INSERT INTO ubigeo VALUES ('030709', '03', '07', '09', 'SAN ANTONIO');
INSERT INTO ubigeo VALUES ('030710', '03', '07', '10', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('030711', '03', '07', '11', 'TURPAY');
INSERT INTO ubigeo VALUES ('030712', '03', '07', '12', 'VILCABAMBA');
INSERT INTO ubigeo VALUES ('030713', '03', '07', '13', 'VIRUNDO');
INSERT INTO ubigeo VALUES ('030714', '03', '07', '14', 'CURASCO');
INSERT INTO ubigeo VALUES ('040000', '04', '00', '00', 'AREQUIPA');
INSERT INTO ubigeo VALUES ('040100', '04', '01', '00', 'AREQUIPA');
INSERT INTO ubigeo VALUES ('040101', '04', '01', '01', 'AREQUIPA');
INSERT INTO ubigeo VALUES ('040102', '04', '01', '02', 'ALTO SELVA ALEGRE');
INSERT INTO ubigeo VALUES ('040103', '04', '01', '03', 'CAYMA');
INSERT INTO ubigeo VALUES ('040104', '04', '01', '04', 'CERRO COLORADO');
INSERT INTO ubigeo VALUES ('040105', '04', '01', '05', 'CHARACATO');
INSERT INTO ubigeo VALUES ('040106', '04', '01', '06', 'CHIGUATA');
INSERT INTO ubigeo VALUES ('040107', '04', '01', '07', 'JACOBO HUNTER');
INSERT INTO ubigeo VALUES ('040108', '04', '01', '08', 'LA JOYA');
INSERT INTO ubigeo VALUES ('040109', '04', '01', '09', 'MARIANO MELGAR');
INSERT INTO ubigeo VALUES ('040110', '04', '01', '10', 'MIRAFLORES');
INSERT INTO ubigeo VALUES ('040111', '04', '01', '11', 'MOLLEBAYA');
INSERT INTO ubigeo VALUES ('040112', '04', '01', '12', 'PAUCARPATA');
INSERT INTO ubigeo VALUES ('040113', '04', '01', '13', 'POCSI');
INSERT INTO ubigeo VALUES ('040114', '04', '01', '14', 'POLOBAYA');
INSERT INTO ubigeo VALUES ('040115', '04', '01', '15', 'QUEQUEÑA');
INSERT INTO ubigeo VALUES ('040116', '04', '01', '16', 'SABANDIA');
INSERT INTO ubigeo VALUES ('040117', '04', '01', '17', 'SACHACA');
INSERT INTO ubigeo VALUES ('040118', '04', '01', '18', 'SAN JUAN DE SIGUAS');
INSERT INTO ubigeo VALUES ('040119', '04', '01', '19', 'SAN JUAN DE TARUCANI');
INSERT INTO ubigeo VALUES ('040120', '04', '01', '20', 'SANTA ISABEL DE SIGUAS');
INSERT INTO ubigeo VALUES ('040121', '04', '01', '21', 'SANTA RITA DE SIGUAS');
INSERT INTO ubigeo VALUES ('040122', '04', '01', '22', 'SOCABAYA');
INSERT INTO ubigeo VALUES ('040123', '04', '01', '23', 'TIABAYA');
INSERT INTO ubigeo VALUES ('040124', '04', '01', '24', 'UCHUMAYO');
INSERT INTO ubigeo VALUES ('040125', '04', '01', '25', 'VITOR');
INSERT INTO ubigeo VALUES ('040126', '04', '01', '26', 'YANAHUARA');
INSERT INTO ubigeo VALUES ('040127', '04', '01', '27', 'YARABAMBA');
INSERT INTO ubigeo VALUES ('040128', '04', '01', '28', 'YURA');
INSERT INTO ubigeo VALUES ('040129', '04', '01', '29', 'JOSE LUIS BUSTAMANTE Y RIVERO');
INSERT INTO ubigeo VALUES ('040200', '04', '02', '00', 'CAMANA');
INSERT INTO ubigeo VALUES ('040201', '04', '02', '01', 'CAMANA');
INSERT INTO ubigeo VALUES ('040202', '04', '02', '02', 'JOSE MARIA QUIMPER');
INSERT INTO ubigeo VALUES ('040203', '04', '02', '03', 'MARIANO NICOLAS VALCARCEL');
INSERT INTO ubigeo VALUES ('040204', '04', '02', '04', 'MARISCAL CACERES');
INSERT INTO ubigeo VALUES ('040205', '04', '02', '05', 'NICOLAS DE PIEROLA');
INSERT INTO ubigeo VALUES ('040206', '04', '02', '06', 'OCOÑA');
INSERT INTO ubigeo VALUES ('040207', '04', '02', '07', 'QUILCA');
INSERT INTO ubigeo VALUES ('040208', '04', '02', '08', 'SAMUEL PASTOR');
INSERT INTO ubigeo VALUES ('040300', '04', '03', '00', 'CARAVELI');
INSERT INTO ubigeo VALUES ('040301', '04', '03', '01', 'CARAVELI');
INSERT INTO ubigeo VALUES ('040302', '04', '03', '02', 'ACARI');
INSERT INTO ubigeo VALUES ('040303', '04', '03', '03', 'ATICO');
INSERT INTO ubigeo VALUES ('040304', '04', '03', '04', 'ATIQUIPA');
INSERT INTO ubigeo VALUES ('040305', '04', '03', '05', 'BELLA UNION');
INSERT INTO ubigeo VALUES ('040306', '04', '03', '06', 'CAHUACHO');
INSERT INTO ubigeo VALUES ('040307', '04', '03', '07', 'CHALA');
INSERT INTO ubigeo VALUES ('040308', '04', '03', '08', 'CHAPARRA');
INSERT INTO ubigeo VALUES ('040309', '04', '03', '09', 'HUANUHUANU');
INSERT INTO ubigeo VALUES ('040310', '04', '03', '10', 'JAQUI');
INSERT INTO ubigeo VALUES ('040311', '04', '03', '11', 'LOMAS');
INSERT INTO ubigeo VALUES ('040312', '04', '03', '12', 'QUICACHA');
INSERT INTO ubigeo VALUES ('040313', '04', '03', '13', 'YAUCA');
INSERT INTO ubigeo VALUES ('040400', '04', '04', '00', 'CASTILLA');
INSERT INTO ubigeo VALUES ('040401', '04', '04', '01', 'APLAO');
INSERT INTO ubigeo VALUES ('040402', '04', '04', '02', 'ANDAGUA');
INSERT INTO ubigeo VALUES ('040403', '04', '04', '03', 'AYO');
INSERT INTO ubigeo VALUES ('040404', '04', '04', '04', 'CHACHAS');
INSERT INTO ubigeo VALUES ('040405', '04', '04', '05', 'CHILCAYMARCA');
INSERT INTO ubigeo VALUES ('040406', '04', '04', '06', 'CHOCO');
INSERT INTO ubigeo VALUES ('040407', '04', '04', '07', 'HUANCARQUI');
INSERT INTO ubigeo VALUES ('040408', '04', '04', '08', 'MACHAGUAY');
INSERT INTO ubigeo VALUES ('040409', '04', '04', '09', 'ORCOPAMPA');
INSERT INTO ubigeo VALUES ('040410', '04', '04', '10', 'PAMPACOLCA');
INSERT INTO ubigeo VALUES ('040411', '04', '04', '11', 'TIPAN');
INSERT INTO ubigeo VALUES ('040412', '04', '04', '12', 'UÑON');
INSERT INTO ubigeo VALUES ('040413', '04', '04', '13', 'URACA');
INSERT INTO ubigeo VALUES ('040414', '04', '04', '14', 'VIRACO');
INSERT INTO ubigeo VALUES ('040500', '04', '05', '00', 'CAYLLOMA');
INSERT INTO ubigeo VALUES ('040501', '04', '05', '01', 'CHIVAY');
INSERT INTO ubigeo VALUES ('040502', '04', '05', '02', 'ACHOMA');
INSERT INTO ubigeo VALUES ('040503', '04', '05', '03', 'CABANACONDE');
INSERT INTO ubigeo VALUES ('040504', '04', '05', '04', 'CALLALLI');
INSERT INTO ubigeo VALUES ('040505', '04', '05', '05', 'CAYLLOMA');
INSERT INTO ubigeo VALUES ('040506', '04', '05', '06', 'COPORAQUE');
INSERT INTO ubigeo VALUES ('040507', '04', '05', '07', 'HUAMBO');
INSERT INTO ubigeo VALUES ('040508', '04', '05', '08', 'HUANCA');
INSERT INTO ubigeo VALUES ('040509', '04', '05', '09', 'ICHUPAMPA');
INSERT INTO ubigeo VALUES ('040510', '04', '05', '10', 'LARI');
INSERT INTO ubigeo VALUES ('040511', '04', '05', '11', 'LLUTA');
INSERT INTO ubigeo VALUES ('040512', '04', '05', '12', 'MACA');
INSERT INTO ubigeo VALUES ('040513', '04', '05', '13', 'MADRIGAL');
INSERT INTO ubigeo VALUES ('040514', '04', '05', '14', 'SAN ANTONIO DE CHUCA');
INSERT INTO ubigeo VALUES ('040515', '04', '05', '15', 'SIBAYO');
INSERT INTO ubigeo VALUES ('040516', '04', '05', '16', 'TAPAY');
INSERT INTO ubigeo VALUES ('040517', '04', '05', '17', 'TISCO');
INSERT INTO ubigeo VALUES ('040518', '04', '05', '18', 'TUTI');
INSERT INTO ubigeo VALUES ('040519', '04', '05', '19', 'YANQUE');
INSERT INTO ubigeo VALUES ('040520', '04', '05', '20', 'MAJES');
INSERT INTO ubigeo VALUES ('040600', '04', '06', '00', 'CONDESUYOS');
INSERT INTO ubigeo VALUES ('040601', '04', '06', '01', 'CHUQUIBAMBA');
INSERT INTO ubigeo VALUES ('040602', '04', '06', '02', 'ANDARAY');
INSERT INTO ubigeo VALUES ('040603', '04', '06', '03', 'CAYARANI');
INSERT INTO ubigeo VALUES ('040604', '04', '06', '04', 'CHICHAS');
INSERT INTO ubigeo VALUES ('040605', '04', '06', '05', 'IRAY');
INSERT INTO ubigeo VALUES ('040606', '04', '06', '06', 'RIO GRANDE');
INSERT INTO ubigeo VALUES ('040607', '04', '06', '07', 'SALAMANCA');
INSERT INTO ubigeo VALUES ('040608', '04', '06', '08', 'YANAQUIHUA');
INSERT INTO ubigeo VALUES ('040700', '04', '07', '00', 'ISLAY');
INSERT INTO ubigeo VALUES ('040701', '04', '07', '01', 'MOLLENDO');
INSERT INTO ubigeo VALUES ('040702', '04', '07', '02', 'COCACHACRA');
INSERT INTO ubigeo VALUES ('040703', '04', '07', '03', 'DEAN VALDIVIA');
INSERT INTO ubigeo VALUES ('040704', '04', '07', '04', 'ISLAY');
INSERT INTO ubigeo VALUES ('040705', '04', '07', '05', 'MEJIA');
INSERT INTO ubigeo VALUES ('040706', '04', '07', '06', 'PUNTA DE BOMBON');
INSERT INTO ubigeo VALUES ('040800', '04', '08', '00', 'LA UNION');
INSERT INTO ubigeo VALUES ('040801', '04', '08', '01', 'COTAHUASI');
INSERT INTO ubigeo VALUES ('040802', '04', '08', '02', 'ALCA');
INSERT INTO ubigeo VALUES ('040803', '04', '08', '03', 'CHARCANA');
INSERT INTO ubigeo VALUES ('040804', '04', '08', '04', 'HUAYNACOTAS');
INSERT INTO ubigeo VALUES ('040805', '04', '08', '05', 'PAMPAMARCA');
INSERT INTO ubigeo VALUES ('040806', '04', '08', '06', 'PUYCA');
INSERT INTO ubigeo VALUES ('040807', '04', '08', '07', 'QUECHUALLA');
INSERT INTO ubigeo VALUES ('040808', '04', '08', '08', 'SAYLA');
INSERT INTO ubigeo VALUES ('040809', '04', '08', '09', 'TAURIA');
INSERT INTO ubigeo VALUES ('040810', '04', '08', '10', 'TOMEPAMPA');
INSERT INTO ubigeo VALUES ('040811', '04', '08', '11', 'TORO');
INSERT INTO ubigeo VALUES ('050000', '05', '00', '00', 'AYACUCHO');
INSERT INTO ubigeo VALUES ('050100', '05', '01', '00', 'HUAMANGA');
INSERT INTO ubigeo VALUES ('050101', '05', '01', '01', 'AYACUCHO');
INSERT INTO ubigeo VALUES ('050102', '05', '01', '02', 'ACOCRO');
INSERT INTO ubigeo VALUES ('050103', '05', '01', '03', 'ACOS VINCHOS');
INSERT INTO ubigeo VALUES ('050104', '05', '01', '04', 'CARMEN ALTO');
INSERT INTO ubigeo VALUES ('050105', '05', '01', '05', 'CHIARA');
INSERT INTO ubigeo VALUES ('050106', '05', '01', '06', 'OCROS');
INSERT INTO ubigeo VALUES ('050107', '05', '01', '07', 'PACAYCASA');
INSERT INTO ubigeo VALUES ('050108', '05', '01', '08', 'QUINUA');
INSERT INTO ubigeo VALUES ('050109', '05', '01', '09', 'SAN JOSE DE TICLLAS');
INSERT INTO ubigeo VALUES ('050110', '05', '01', '10', 'SAN JUAN BAUTISTA');
INSERT INTO ubigeo VALUES ('050111', '05', '01', '11', 'SANTIAGO DE PISCHA');
INSERT INTO ubigeo VALUES ('050112', '05', '01', '12', 'SOCOS');
INSERT INTO ubigeo VALUES ('050113', '05', '01', '13', 'TAMBILLO');
INSERT INTO ubigeo VALUES ('050114', '05', '01', '14', 'VINCHOS');
INSERT INTO ubigeo VALUES ('050115', '05', '01', '15', 'JESUS NAZARENO');
INSERT INTO ubigeo VALUES ('050200', '05', '02', '00', 'CANGALLO');
INSERT INTO ubigeo VALUES ('050201', '05', '02', '01', 'CANGALLO');
INSERT INTO ubigeo VALUES ('050202', '05', '02', '02', 'CHUSCHI');
INSERT INTO ubigeo VALUES ('050203', '05', '02', '03', 'LOS MOROCHUCOS');
INSERT INTO ubigeo VALUES ('050204', '05', '02', '04', 'MARIA PARADO DE BELLIDO');
INSERT INTO ubigeo VALUES ('050205', '05', '02', '05', 'PARAS');
INSERT INTO ubigeo VALUES ('050206', '05', '02', '06', 'TOTOS');
INSERT INTO ubigeo VALUES ('050300', '05', '03', '00', 'HUANCA SANCOS');
INSERT INTO ubigeo VALUES ('050301', '05', '03', '01', 'SANCOS');
INSERT INTO ubigeo VALUES ('050302', '05', '03', '02', 'CARAPO');
INSERT INTO ubigeo VALUES ('050303', '05', '03', '03', 'SACSAMARCA');
INSERT INTO ubigeo VALUES ('050304', '05', '03', '04', 'SANTIAGO DE LUCANAMARCA');
INSERT INTO ubigeo VALUES ('050400', '05', '04', '00', 'HUANTA');
INSERT INTO ubigeo VALUES ('050401', '05', '04', '01', 'HUANTA');
INSERT INTO ubigeo VALUES ('050402', '05', '04', '02', 'AYAHUANCO');
INSERT INTO ubigeo VALUES ('050403', '05', '04', '03', 'HUAMANGUILLA');
INSERT INTO ubigeo VALUES ('050404', '05', '04', '04', 'IGUAIN');
INSERT INTO ubigeo VALUES ('050405', '05', '04', '05', 'LURICOCHA');
INSERT INTO ubigeo VALUES ('050406', '05', '04', '06', 'SANTILLANA');
INSERT INTO ubigeo VALUES ('050407', '05', '04', '07', 'SIVIA');
INSERT INTO ubigeo VALUES ('050408', '05', '04', '08', 'LLOCHEGUA');
INSERT INTO ubigeo VALUES ('050500', '05', '05', '00', 'LA MAR');
INSERT INTO ubigeo VALUES ('050501', '05', '05', '01', 'SAN MIGUEL');
INSERT INTO ubigeo VALUES ('050502', '05', '05', '02', 'ANCO');
INSERT INTO ubigeo VALUES ('050503', '05', '05', '03', 'AYNA');
INSERT INTO ubigeo VALUES ('050504', '05', '05', '04', 'CHILCAS');
INSERT INTO ubigeo VALUES ('050505', '05', '05', '05', 'CHUNGUI');
INSERT INTO ubigeo VALUES ('050506', '05', '05', '06', 'LUIS CARRANZA');
INSERT INTO ubigeo VALUES ('050507', '05', '05', '07', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('050508', '05', '05', '08', 'TAMBO');
INSERT INTO ubigeo VALUES ('050509', '05', '05', '09', 'SAMUGARI');
INSERT INTO ubigeo VALUES ('050600', '05', '06', '00', 'LUCANAS');
INSERT INTO ubigeo VALUES ('050601', '05', '06', '01', 'PUQUIO');
INSERT INTO ubigeo VALUES ('050602', '05', '06', '02', 'AUCARA');
INSERT INTO ubigeo VALUES ('050603', '05', '06', '03', 'CABANA');
INSERT INTO ubigeo VALUES ('050604', '05', '06', '04', 'CARMEN SALCEDO');
INSERT INTO ubigeo VALUES ('050605', '05', '06', '05', 'CHAVIÑA');
INSERT INTO ubigeo VALUES ('050606', '05', '06', '06', 'CHIPAO');
INSERT INTO ubigeo VALUES ('050607', '05', '06', '07', 'HUAC-HUAS');
INSERT INTO ubigeo VALUES ('050608', '05', '06', '08', 'LARAMATE');
INSERT INTO ubigeo VALUES ('050609', '05', '06', '09', 'LEONCIO PRADO');
INSERT INTO ubigeo VALUES ('050610', '05', '06', '10', 'LLAUTA');
INSERT INTO ubigeo VALUES ('050611', '05', '06', '11', 'LUCANAS');
INSERT INTO ubigeo VALUES ('050612', '05', '06', '12', 'OCAÑA');
INSERT INTO ubigeo VALUES ('050613', '05', '06', '13', 'OTOCA');
INSERT INTO ubigeo VALUES ('050614', '05', '06', '14', 'SAISA');
INSERT INTO ubigeo VALUES ('050615', '05', '06', '15', 'SAN CRISTOBAL');
INSERT INTO ubigeo VALUES ('050616', '05', '06', '16', 'SAN JUAN');
INSERT INTO ubigeo VALUES ('050617', '05', '06', '17', 'SAN PEDRO');
INSERT INTO ubigeo VALUES ('050618', '05', '06', '18', 'SAN PEDRO DE PALCO');
INSERT INTO ubigeo VALUES ('050619', '05', '06', '19', 'SANCOS');
INSERT INTO ubigeo VALUES ('050620', '05', '06', '20', 'SANTA ANA DE HUAYCAHUACHO');
INSERT INTO ubigeo VALUES ('050621', '05', '06', '21', 'SANTA LUCIA');
INSERT INTO ubigeo VALUES ('050700', '05', '07', '00', 'PARINACOCHAS');
INSERT INTO ubigeo VALUES ('050701', '05', '07', '01', 'CORACORA');
INSERT INTO ubigeo VALUES ('050702', '05', '07', '02', 'CHUMPI');
INSERT INTO ubigeo VALUES ('050703', '05', '07', '03', 'CORONEL CASTAÑEDA');
INSERT INTO ubigeo VALUES ('050704', '05', '07', '04', 'PACAPAUSA');
INSERT INTO ubigeo VALUES ('050705', '05', '07', '05', 'PULLO');
INSERT INTO ubigeo VALUES ('050706', '05', '07', '06', 'PUYUSCA');
INSERT INTO ubigeo VALUES ('050707', '05', '07', '07', 'SAN FRANCISCO DE RAVACAYCO');
INSERT INTO ubigeo VALUES ('050708', '05', '07', '08', 'UPAHUACHO');
INSERT INTO ubigeo VALUES ('050800', '05', '08', '00', 'PAUCAR DEL SARA SARA');
INSERT INTO ubigeo VALUES ('050801', '05', '08', '01', 'PAUSA');
INSERT INTO ubigeo VALUES ('050802', '05', '08', '02', 'COLTA');
INSERT INTO ubigeo VALUES ('050803', '05', '08', '03', 'CORCULLA');
INSERT INTO ubigeo VALUES ('050804', '05', '08', '04', 'LAMPA');
INSERT INTO ubigeo VALUES ('050805', '05', '08', '05', 'MARCABAMBA');
INSERT INTO ubigeo VALUES ('050806', '05', '08', '06', 'OYOLO');
INSERT INTO ubigeo VALUES ('050807', '05', '08', '07', 'PARARCA');
INSERT INTO ubigeo VALUES ('050808', '05', '08', '08', 'SAN JAVIER DE ALPABAMBA');
INSERT INTO ubigeo VALUES ('050809', '05', '08', '09', 'SAN JOSE DE USHUA');
INSERT INTO ubigeo VALUES ('050810', '05', '08', '10', 'SARA SARA');
INSERT INTO ubigeo VALUES ('050900', '05', '09', '00', 'SUCRE');
INSERT INTO ubigeo VALUES ('050901', '05', '09', '01', 'QUEROBAMBA');
INSERT INTO ubigeo VALUES ('050902', '05', '09', '02', 'BELEN');
INSERT INTO ubigeo VALUES ('050903', '05', '09', '03', 'CHALCOS');
INSERT INTO ubigeo VALUES ('050904', '05', '09', '04', 'CHILCAYOC');
INSERT INTO ubigeo VALUES ('050905', '05', '09', '05', 'HUACAÑA');
INSERT INTO ubigeo VALUES ('050906', '05', '09', '06', 'MORCOLLA');
INSERT INTO ubigeo VALUES ('050907', '05', '09', '07', 'PAICO');
INSERT INTO ubigeo VALUES ('050908', '05', '09', '08', 'SAN PEDRO DE LARCAY');
INSERT INTO ubigeo VALUES ('050909', '05', '09', '09', 'SAN SALVADOR DE QUIJE');
INSERT INTO ubigeo VALUES ('050910', '05', '09', '10', 'SANTIAGO DE PAUCARAY');
INSERT INTO ubigeo VALUES ('050911', '05', '09', '11', 'SORAS');
INSERT INTO ubigeo VALUES ('051000', '05', '10', '00', 'VICTOR FAJARDO');
INSERT INTO ubigeo VALUES ('051001', '05', '10', '01', 'HUANCAPI');
INSERT INTO ubigeo VALUES ('051002', '05', '10', '02', 'ALCAMENCA');
INSERT INTO ubigeo VALUES ('051003', '05', '10', '03', 'APONGO');
INSERT INTO ubigeo VALUES ('051004', '05', '10', '04', 'ASQUIPATA');
INSERT INTO ubigeo VALUES ('051005', '05', '10', '05', 'CANARIA');
INSERT INTO ubigeo VALUES ('051006', '05', '10', '06', 'CAYARA');
INSERT INTO ubigeo VALUES ('051007', '05', '10', '07', 'COLCA');
INSERT INTO ubigeo VALUES ('051008', '05', '10', '08', 'HUAMANQUIQUIA');
INSERT INTO ubigeo VALUES ('051009', '05', '10', '09', 'HUANCARAYLLA');
INSERT INTO ubigeo VALUES ('051010', '05', '10', '10', 'HUAYA');
INSERT INTO ubigeo VALUES ('051011', '05', '10', '11', 'SARHUA');
INSERT INTO ubigeo VALUES ('051012', '05', '10', '12', 'VILCANCHOS');
INSERT INTO ubigeo VALUES ('051100', '05', '11', '00', 'VILCAS HUAMAN');
INSERT INTO ubigeo VALUES ('051101', '05', '11', '01', 'VILCAS HUAMAN');
INSERT INTO ubigeo VALUES ('051102', '05', '11', '02', 'ACCOMARCA');
INSERT INTO ubigeo VALUES ('051103', '05', '11', '03', 'CARHUANCA');
INSERT INTO ubigeo VALUES ('051104', '05', '11', '04', 'CONCEPCION');
INSERT INTO ubigeo VALUES ('051105', '05', '11', '05', 'HUAMBALPA');
INSERT INTO ubigeo VALUES ('051106', '05', '11', '06', 'INDEPENDENCIA');
INSERT INTO ubigeo VALUES ('051107', '05', '11', '07', 'SAURAMA');
INSERT INTO ubigeo VALUES ('051108', '05', '11', '08', 'VISCHONGO');
INSERT INTO ubigeo VALUES ('060000', '06', '00', '00', 'CAJAMARCA');
INSERT INTO ubigeo VALUES ('060100', '06', '01', '00', 'CAJAMARCA');
INSERT INTO ubigeo VALUES ('060101', '06', '01', '01', 'CAJAMARCA');
INSERT INTO ubigeo VALUES ('060102', '06', '01', '02', 'ASUNCION');
INSERT INTO ubigeo VALUES ('060103', '06', '01', '03', 'CHETILLA');
INSERT INTO ubigeo VALUES ('060104', '06', '01', '04', 'COSPAN');
INSERT INTO ubigeo VALUES ('060105', '06', '01', '05', 'ENCAÑADA');
INSERT INTO ubigeo VALUES ('060106', '06', '01', '06', 'JESUS');
INSERT INTO ubigeo VALUES ('060107', '06', '01', '07', 'LLACANORA');
INSERT INTO ubigeo VALUES ('060108', '06', '01', '08', 'LOS BAÑOS DEL INCA');
INSERT INTO ubigeo VALUES ('060109', '06', '01', '09', 'MAGDALENA');
INSERT INTO ubigeo VALUES ('060110', '06', '01', '10', 'MATARA');
INSERT INTO ubigeo VALUES ('060111', '06', '01', '11', 'NAMORA');
INSERT INTO ubigeo VALUES ('060112', '06', '01', '12', 'SAN JUAN');
INSERT INTO ubigeo VALUES ('060200', '06', '02', '00', 'CAJABAMBA');
INSERT INTO ubigeo VALUES ('060201', '06', '02', '01', 'CAJABAMBA');
INSERT INTO ubigeo VALUES ('060202', '06', '02', '02', 'CACHACHI');
INSERT INTO ubigeo VALUES ('060203', '06', '02', '03', 'CONDEBAMBA');
INSERT INTO ubigeo VALUES ('060204', '06', '02', '04', 'SITACOCHA');
INSERT INTO ubigeo VALUES ('060300', '06', '03', '00', 'CELENDIN');
INSERT INTO ubigeo VALUES ('060301', '06', '03', '01', 'CELENDIN');
INSERT INTO ubigeo VALUES ('060302', '06', '03', '02', 'CHUMUCH');
INSERT INTO ubigeo VALUES ('060303', '06', '03', '03', 'CORTEGANA');
INSERT INTO ubigeo VALUES ('060304', '06', '03', '04', 'HUASMIN');
INSERT INTO ubigeo VALUES ('060305', '06', '03', '05', 'JORGE CHAVEZ');
INSERT INTO ubigeo VALUES ('060306', '06', '03', '06', 'JOSE GALVEZ');
INSERT INTO ubigeo VALUES ('060307', '06', '03', '07', 'MIGUEL IGLESIAS');
INSERT INTO ubigeo VALUES ('060308', '06', '03', '08', 'OXAMARCA');
INSERT INTO ubigeo VALUES ('060309', '06', '03', '09', 'SOROCHUCO');
INSERT INTO ubigeo VALUES ('060310', '06', '03', '10', 'SUCRE');
INSERT INTO ubigeo VALUES ('060311', '06', '03', '11', 'UTCO');
INSERT INTO ubigeo VALUES ('060312', '06', '03', '12', 'LA LIBERTAD DE PALLAN');
INSERT INTO ubigeo VALUES ('060400', '06', '04', '00', 'CHOTA');
INSERT INTO ubigeo VALUES ('060401', '06', '04', '01', 'CHOTA');
INSERT INTO ubigeo VALUES ('060402', '06', '04', '02', 'ANGUIA');
INSERT INTO ubigeo VALUES ('060403', '06', '04', '03', 'CHADIN');
INSERT INTO ubigeo VALUES ('060404', '06', '04', '04', 'CHIGUIRIP');
INSERT INTO ubigeo VALUES ('060405', '06', '04', '05', 'CHIMBAN');
INSERT INTO ubigeo VALUES ('060406', '06', '04', '06', 'CHOROPAMPA');
INSERT INTO ubigeo VALUES ('060407', '06', '04', '07', 'COCHABAMBA');
INSERT INTO ubigeo VALUES ('060408', '06', '04', '08', 'CONCHAN');
INSERT INTO ubigeo VALUES ('060409', '06', '04', '09', 'HUAMBOS');
INSERT INTO ubigeo VALUES ('060410', '06', '04', '10', 'LAJAS');
INSERT INTO ubigeo VALUES ('060411', '06', '04', '11', 'LLAMA');
INSERT INTO ubigeo VALUES ('060412', '06', '04', '12', 'MIRACOSTA');
INSERT INTO ubigeo VALUES ('060413', '06', '04', '13', 'PACCHA');
INSERT INTO ubigeo VALUES ('060414', '06', '04', '14', 'PION');
INSERT INTO ubigeo VALUES ('060415', '06', '04', '15', 'QUEROCOTO');
INSERT INTO ubigeo VALUES ('060416', '06', '04', '16', 'SAN JUAN DE LICUPIS');
INSERT INTO ubigeo VALUES ('060417', '06', '04', '17', 'TACABAMBA');
INSERT INTO ubigeo VALUES ('060418', '06', '04', '18', 'TOCMOCHE');
INSERT INTO ubigeo VALUES ('060419', '06', '04', '19', 'CHALAMARCA');
INSERT INTO ubigeo VALUES ('060500', '06', '05', '00', 'CONTUMAZA');
INSERT INTO ubigeo VALUES ('060501', '06', '05', '01', 'CONTUMAZA');
INSERT INTO ubigeo VALUES ('060502', '06', '05', '02', 'CHILETE');
INSERT INTO ubigeo VALUES ('060503', '06', '05', '03', 'CUPISNIQUE');
INSERT INTO ubigeo VALUES ('060504', '06', '05', '04', 'GUZMANGO');
INSERT INTO ubigeo VALUES ('060505', '06', '05', '05', 'SAN BENITO');
INSERT INTO ubigeo VALUES ('060506', '06', '05', '06', 'SANTA CRUZ DE TOLED');
INSERT INTO ubigeo VALUES ('060507', '06', '05', '07', 'TANTARICA');
INSERT INTO ubigeo VALUES ('060508', '06', '05', '08', 'YONAN');
INSERT INTO ubigeo VALUES ('060600', '06', '06', '00', 'CUTERVO');
INSERT INTO ubigeo VALUES ('060601', '06', '06', '01', 'CUTERVO');
INSERT INTO ubigeo VALUES ('060602', '06', '06', '02', 'CALLAYUC');
INSERT INTO ubigeo VALUES ('060603', '06', '06', '03', 'CHOROS');
INSERT INTO ubigeo VALUES ('060604', '06', '06', '04', 'CUJILLO');
INSERT INTO ubigeo VALUES ('060605', '06', '06', '05', 'LA RAMADA');
INSERT INTO ubigeo VALUES ('060606', '06', '06', '06', 'PIMPINGOS');
INSERT INTO ubigeo VALUES ('060607', '06', '06', '07', 'QUEROCOTILLO');
INSERT INTO ubigeo VALUES ('060608', '06', '06', '08', 'SAN ANDRES DE CUTERVO');
INSERT INTO ubigeo VALUES ('060609', '06', '06', '09', 'SAN JUAN DE CUTERVO');
INSERT INTO ubigeo VALUES ('060610', '06', '06', '10', 'SAN LUIS DE LUCMA');
INSERT INTO ubigeo VALUES ('060611', '06', '06', '11', 'SANTA CRUZ');
INSERT INTO ubigeo VALUES ('060612', '06', '06', '12', 'SANTO DOMINGO DE LA CAPILLA');
INSERT INTO ubigeo VALUES ('060613', '06', '06', '13', 'SANTO TOMAS');
INSERT INTO ubigeo VALUES ('060614', '06', '06', '14', 'SOCOTA');
INSERT INTO ubigeo VALUES ('060615', '06', '06', '15', 'TORIBIO CASANOVA');
INSERT INTO ubigeo VALUES ('060700', '06', '07', '00', 'HUALGAYOC');
INSERT INTO ubigeo VALUES ('060701', '06', '07', '01', 'BAMBAMARCA');
INSERT INTO ubigeo VALUES ('060702', '06', '07', '02', 'CHUGUR');
INSERT INTO ubigeo VALUES ('060703', '06', '07', '03', 'HUALGAYOC');
INSERT INTO ubigeo VALUES ('060800', '06', '08', '00', 'JAEN');
INSERT INTO ubigeo VALUES ('060801', '06', '08', '01', 'JAEN');
INSERT INTO ubigeo VALUES ('060802', '06', '08', '02', 'BELLAVISTA');
INSERT INTO ubigeo VALUES ('060803', '06', '08', '03', 'CHONTALI');
INSERT INTO ubigeo VALUES ('060804', '06', '08', '04', 'COLASAY');
INSERT INTO ubigeo VALUES ('060805', '06', '08', '05', 'HUABAL');
INSERT INTO ubigeo VALUES ('060806', '06', '08', '06', 'LAS PIRIAS');
INSERT INTO ubigeo VALUES ('060807', '06', '08', '07', 'POMAHUACA');
INSERT INTO ubigeo VALUES ('060808', '06', '08', '08', 'PUCARA');
INSERT INTO ubigeo VALUES ('060809', '06', '08', '09', 'SALLIQUE');
INSERT INTO ubigeo VALUES ('060810', '06', '08', '10', 'SAN FELIPE');
INSERT INTO ubigeo VALUES ('060811', '06', '08', '11', 'SAN JOSE DEL ALTO');
INSERT INTO ubigeo VALUES ('060812', '06', '08', '12', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('060900', '06', '09', '00', 'SAN IGNACIO');
INSERT INTO ubigeo VALUES ('060901', '06', '09', '01', 'SAN IGNACIO');
INSERT INTO ubigeo VALUES ('060902', '06', '09', '02', 'CHIRINOS');
INSERT INTO ubigeo VALUES ('060903', '06', '09', '03', 'HUARANGO');
INSERT INTO ubigeo VALUES ('060904', '06', '09', '04', 'LA COIPA');
INSERT INTO ubigeo VALUES ('060905', '06', '09', '05', 'NAMBALLE');
INSERT INTO ubigeo VALUES ('060906', '06', '09', '06', 'SAN JOSE DE LOURDES');
INSERT INTO ubigeo VALUES ('060907', '06', '09', '07', 'TABACONAS');
INSERT INTO ubigeo VALUES ('061000', '06', '10', '00', 'SAN MARCOS');
INSERT INTO ubigeo VALUES ('061001', '06', '10', '01', 'PEDRO GALVEZ');
INSERT INTO ubigeo VALUES ('061002', '06', '10', '02', 'CHANCAY');
INSERT INTO ubigeo VALUES ('061003', '06', '10', '03', 'EDUARDO VILLANUEVA');
INSERT INTO ubigeo VALUES ('061004', '06', '10', '04', 'GREGORIO PITA');
INSERT INTO ubigeo VALUES ('061005', '06', '10', '05', 'ICHOCAN');
INSERT INTO ubigeo VALUES ('061006', '06', '10', '06', 'JOSE MANUEL QUIROZ');
INSERT INTO ubigeo VALUES ('061007', '06', '10', '07', 'JOSE SABOGAL');
INSERT INTO ubigeo VALUES ('061100', '06', '11', '00', 'SAN MIGUEL');
INSERT INTO ubigeo VALUES ('061101', '06', '11', '01', 'SAN MIGUEL');
INSERT INTO ubigeo VALUES ('061102', '06', '11', '02', 'BOLIVAR');
INSERT INTO ubigeo VALUES ('061103', '06', '11', '03', 'CALQUIS');
INSERT INTO ubigeo VALUES ('061104', '06', '11', '04', 'CATILLUC');
INSERT INTO ubigeo VALUES ('061105', '06', '11', '05', 'EL PRADO');
INSERT INTO ubigeo VALUES ('061106', '06', '11', '06', 'LA FLORIDA');
INSERT INTO ubigeo VALUES ('061107', '06', '11', '07', 'LLAPA');
INSERT INTO ubigeo VALUES ('061108', '06', '11', '08', 'NANCHOC');
INSERT INTO ubigeo VALUES ('061109', '06', '11', '09', 'NIEPOS');
INSERT INTO ubigeo VALUES ('061110', '06', '11', '10', 'SAN GREGORIO');
INSERT INTO ubigeo VALUES ('061111', '06', '11', '11', 'SAN SILVESTRE DE COCHAN');
INSERT INTO ubigeo VALUES ('061112', '06', '11', '12', 'TONGOD');
INSERT INTO ubigeo VALUES ('061113', '06', '11', '13', 'UNION AGUA BLANCA');
INSERT INTO ubigeo VALUES ('061200', '06', '12', '00', 'SAN PABLO');
INSERT INTO ubigeo VALUES ('061201', '06', '12', '01', 'SAN PABLO');
INSERT INTO ubigeo VALUES ('061202', '06', '12', '02', 'SAN BERNARDINO');
INSERT INTO ubigeo VALUES ('061203', '06', '12', '03', 'SAN LUIS');
INSERT INTO ubigeo VALUES ('061204', '06', '12', '04', 'TUMBADEN');
INSERT INTO ubigeo VALUES ('061300', '06', '13', '00', 'SANTA CRUZ');
INSERT INTO ubigeo VALUES ('061301', '06', '13', '01', 'SANTA CRUZ');
INSERT INTO ubigeo VALUES ('061302', '06', '13', '02', 'ANDABAMBA');
INSERT INTO ubigeo VALUES ('061303', '06', '13', '03', 'CATACHE');
INSERT INTO ubigeo VALUES ('061304', '06', '13', '04', 'CHANCAYBAÑOS');
INSERT INTO ubigeo VALUES ('061305', '06', '13', '05', 'LA ESPERANZA');
INSERT INTO ubigeo VALUES ('061306', '06', '13', '06', 'NINABAMBA');
INSERT INTO ubigeo VALUES ('061307', '06', '13', '07', 'PULAN');
INSERT INTO ubigeo VALUES ('061308', '06', '13', '08', 'SAUCEPAMPA');
INSERT INTO ubigeo VALUES ('061309', '06', '13', '09', 'SEXI');
INSERT INTO ubigeo VALUES ('061310', '06', '13', '10', 'UTICYACU');
INSERT INTO ubigeo VALUES ('061311', '06', '13', '11', 'YAUYUCAN');
INSERT INTO ubigeo VALUES ('070000', '07', '00', '00', 'CALLAO');
INSERT INTO ubigeo VALUES ('070100', '07', '01', '00', 'CALLAO');
INSERT INTO ubigeo VALUES ('070101', '07', '01', '01', 'CALLAO');
INSERT INTO ubigeo VALUES ('070102', '07', '01', '02', 'BELLAVISTA');
INSERT INTO ubigeo VALUES ('070103', '07', '01', '03', 'CARMEN DE LA LEGUA REYNOSO');
INSERT INTO ubigeo VALUES ('070104', '07', '01', '04', 'LA PERLA');
INSERT INTO ubigeo VALUES ('070105', '07', '01', '05', 'LA PUNTA');
INSERT INTO ubigeo VALUES ('070106', '07', '01', '06', 'VENTANILLA');
INSERT INTO ubigeo VALUES ('080000', '08', '00', '00', 'CUSCO');
INSERT INTO ubigeo VALUES ('080100', '08', '01', '00', 'CUSCO');
INSERT INTO ubigeo VALUES ('080101', '08', '01', '01', 'CUSCO');
INSERT INTO ubigeo VALUES ('080102', '08', '01', '02', 'CCORCA');
INSERT INTO ubigeo VALUES ('080103', '08', '01', '03', 'POROY');
INSERT INTO ubigeo VALUES ('080104', '08', '01', '04', 'SAN JERONIMO');
INSERT INTO ubigeo VALUES ('080105', '08', '01', '05', 'SAN SEBASTIAN');
INSERT INTO ubigeo VALUES ('080106', '08', '01', '06', 'SANTIAGO');
INSERT INTO ubigeo VALUES ('080107', '08', '01', '07', 'SAYLLA');
INSERT INTO ubigeo VALUES ('080108', '08', '01', '08', 'WANCHAQ');
INSERT INTO ubigeo VALUES ('080200', '08', '02', '00', 'ACOMAYO');
INSERT INTO ubigeo VALUES ('080201', '08', '02', '01', 'ACOMAYO');
INSERT INTO ubigeo VALUES ('080202', '08', '02', '02', 'ACOPIA');
INSERT INTO ubigeo VALUES ('080203', '08', '02', '03', 'ACOS');
INSERT INTO ubigeo VALUES ('080204', '08', '02', '04', 'MOSOC LLACTA');
INSERT INTO ubigeo VALUES ('080205', '08', '02', '05', 'POMACANCHI');
INSERT INTO ubigeo VALUES ('080206', '08', '02', '06', 'RONDOCAN');
INSERT INTO ubigeo VALUES ('080207', '08', '02', '07', 'SANGARARA');
INSERT INTO ubigeo VALUES ('080300', '08', '03', '00', 'ANTA');
INSERT INTO ubigeo VALUES ('080301', '08', '03', '01', 'ANTA');
INSERT INTO ubigeo VALUES ('080302', '08', '03', '02', 'ANCAHUASI');
INSERT INTO ubigeo VALUES ('080303', '08', '03', '03', 'CACHIMAYO');
INSERT INTO ubigeo VALUES ('080304', '08', '03', '04', 'CHINCHAYPUJIO');
INSERT INTO ubigeo VALUES ('080305', '08', '03', '05', 'HUAROCONDO');
INSERT INTO ubigeo VALUES ('080306', '08', '03', '06', 'LIMATAMBO');
INSERT INTO ubigeo VALUES ('080307', '08', '03', '07', 'MOLLEPATA');
INSERT INTO ubigeo VALUES ('080308', '08', '03', '08', 'PUCYURA');
INSERT INTO ubigeo VALUES ('080309', '08', '03', '09', 'ZURITE');
INSERT INTO ubigeo VALUES ('080400', '08', '04', '00', 'CALCA');
INSERT INTO ubigeo VALUES ('080401', '08', '04', '01', 'CALCA');
INSERT INTO ubigeo VALUES ('080402', '08', '04', '02', 'COYA');
INSERT INTO ubigeo VALUES ('080403', '08', '04', '03', 'LAMAY');
INSERT INTO ubigeo VALUES ('080404', '08', '04', '04', 'LARES');
INSERT INTO ubigeo VALUES ('080405', '08', '04', '05', 'PISAC');
INSERT INTO ubigeo VALUES ('080406', '08', '04', '06', 'SAN SALVADOR');
INSERT INTO ubigeo VALUES ('080407', '08', '04', '07', 'TARAY');
INSERT INTO ubigeo VALUES ('080408', '08', '04', '08', 'YANATILE');
INSERT INTO ubigeo VALUES ('080500', '08', '05', '00', 'CANAS');
INSERT INTO ubigeo VALUES ('080501', '08', '05', '01', 'YANAOCA');
INSERT INTO ubigeo VALUES ('080502', '08', '05', '02', 'CHECCA');
INSERT INTO ubigeo VALUES ('080503', '08', '05', '03', 'KUNTURKANKI');
INSERT INTO ubigeo VALUES ('080504', '08', '05', '04', 'LANGUI');
INSERT INTO ubigeo VALUES ('080505', '08', '05', '05', 'LAYO');
INSERT INTO ubigeo VALUES ('080506', '08', '05', '06', 'PAMPAMARCA');
INSERT INTO ubigeo VALUES ('080507', '08', '05', '07', 'QUEHUE');
INSERT INTO ubigeo VALUES ('080508', '08', '05', '08', 'TUPAC AMARU');
INSERT INTO ubigeo VALUES ('080600', '08', '06', '00', 'CANCHIS');
INSERT INTO ubigeo VALUES ('080601', '08', '06', '01', 'SICUANI');
INSERT INTO ubigeo VALUES ('080602', '08', '06', '02', 'CHECACUPE');
INSERT INTO ubigeo VALUES ('080603', '08', '06', '03', 'COMBAPATA');
INSERT INTO ubigeo VALUES ('080604', '08', '06', '04', 'MARANGANI');
INSERT INTO ubigeo VALUES ('080605', '08', '06', '05', 'PITUMARCA');
INSERT INTO ubigeo VALUES ('080606', '08', '06', '06', 'SAN PABLO');
INSERT INTO ubigeo VALUES ('080607', '08', '06', '07', 'SAN PEDRO');
INSERT INTO ubigeo VALUES ('080608', '08', '06', '08', 'TINTA');
INSERT INTO ubigeo VALUES ('080700', '08', '07', '00', 'CHUMBIVILCAS');
INSERT INTO ubigeo VALUES ('080701', '08', '07', '01', 'SANTO TOMAS');
INSERT INTO ubigeo VALUES ('080702', '08', '07', '02', 'CAPACMARCA');
INSERT INTO ubigeo VALUES ('080703', '08', '07', '03', 'CHAMACA');
INSERT INTO ubigeo VALUES ('080704', '08', '07', '04', 'COLQUEMARCA');
INSERT INTO ubigeo VALUES ('080705', '08', '07', '05', 'LIVITACA');
INSERT INTO ubigeo VALUES ('080706', '08', '07', '06', 'LLUSCO');
INSERT INTO ubigeo VALUES ('080707', '08', '07', '07', 'QUIÑOTA');
INSERT INTO ubigeo VALUES ('080708', '08', '07', '08', 'VELILLE');
INSERT INTO ubigeo VALUES ('080800', '08', '08', '00', 'ESPINAR');
INSERT INTO ubigeo VALUES ('080801', '08', '08', '01', 'ESPINAR');
INSERT INTO ubigeo VALUES ('080802', '08', '08', '02', 'CONDOROMA');
INSERT INTO ubigeo VALUES ('080803', '08', '08', '03', 'COPORAQUE');
INSERT INTO ubigeo VALUES ('080804', '08', '08', '04', 'OCORURO');
INSERT INTO ubigeo VALUES ('080805', '08', '08', '05', 'PALLPATA');
INSERT INTO ubigeo VALUES ('080806', '08', '08', '06', 'PICHIGUA');
INSERT INTO ubigeo VALUES ('080807', '08', '08', '07', 'SUYCKUTAMBO');
INSERT INTO ubigeo VALUES ('080808', '08', '08', '08', 'ALTO PICHIGUA');
INSERT INTO ubigeo VALUES ('080900', '08', '09', '00', 'LA CONVENCION');
INSERT INTO ubigeo VALUES ('080901', '08', '09', '01', 'SANTA ANA');
INSERT INTO ubigeo VALUES ('080902', '08', '09', '02', 'ECHARATE');
INSERT INTO ubigeo VALUES ('080903', '08', '09', '03', 'HUAYOPATA');
INSERT INTO ubigeo VALUES ('080904', '08', '09', '04', 'MARANURA');
INSERT INTO ubigeo VALUES ('080905', '08', '09', '05', 'OCOBAMBA');
INSERT INTO ubigeo VALUES ('080906', '08', '09', '06', 'QUELLOUNO');
INSERT INTO ubigeo VALUES ('080907', '08', '09', '07', 'KIMBIRI');
INSERT INTO ubigeo VALUES ('080908', '08', '09', '08', 'SANTA TERESA');
INSERT INTO ubigeo VALUES ('080909', '08', '09', '09', 'VILCABAMBA');
INSERT INTO ubigeo VALUES ('080910', '08', '09', '10', 'PICHARI');
INSERT INTO ubigeo VALUES ('081000', '08', '10', '00', 'PARURO');
INSERT INTO ubigeo VALUES ('081001', '08', '10', '01', 'PARURO');
INSERT INTO ubigeo VALUES ('081002', '08', '10', '02', 'ACCHA');
INSERT INTO ubigeo VALUES ('081003', '08', '10', '03', 'CCAPI');
INSERT INTO ubigeo VALUES ('081004', '08', '10', '04', 'COLCHA');
INSERT INTO ubigeo VALUES ('081005', '08', '10', '05', 'HUANOQUITE');
INSERT INTO ubigeo VALUES ('081006', '08', '10', '06', 'OMACHA');
INSERT INTO ubigeo VALUES ('081007', '08', '10', '07', 'PACCARITAMBO');
INSERT INTO ubigeo VALUES ('081008', '08', '10', '08', 'PILLPINTO');
INSERT INTO ubigeo VALUES ('081009', '08', '10', '09', 'YAURISQUE');
INSERT INTO ubigeo VALUES ('081100', '08', '11', '00', 'PAUCARTAMBO');
INSERT INTO ubigeo VALUES ('081101', '08', '11', '01', 'PAUCARTAMBO');
INSERT INTO ubigeo VALUES ('081102', '08', '11', '02', 'CAICAY');
INSERT INTO ubigeo VALUES ('081103', '08', '11', '03', 'CHALLABAMBA');
INSERT INTO ubigeo VALUES ('081104', '08', '11', '04', 'COLQUEPATA');
INSERT INTO ubigeo VALUES ('081105', '08', '11', '05', 'HUANCARANI');
INSERT INTO ubigeo VALUES ('081106', '08', '11', '06', 'KOSÑIPATA');
INSERT INTO ubigeo VALUES ('081200', '08', '12', '00', 'QUISPICANCHI');
INSERT INTO ubigeo VALUES ('081201', '08', '12', '01', 'URCOS');
INSERT INTO ubigeo VALUES ('081202', '08', '12', '02', 'ANDAHUAYLILLAS');
INSERT INTO ubigeo VALUES ('081203', '08', '12', '03', 'CAMANTI');
INSERT INTO ubigeo VALUES ('081204', '08', '12', '04', 'CCARHUAYO');
INSERT INTO ubigeo VALUES ('081205', '08', '12', '05', 'CCATCA');
INSERT INTO ubigeo VALUES ('081206', '08', '12', '06', 'CUSIPATA');
INSERT INTO ubigeo VALUES ('081207', '08', '12', '07', 'HUARO');
INSERT INTO ubigeo VALUES ('081208', '08', '12', '08', 'LUCRE');
INSERT INTO ubigeo VALUES ('081209', '08', '12', '09', 'MARCAPATA');
INSERT INTO ubigeo VALUES ('081210', '08', '12', '10', 'OCONGATE');
INSERT INTO ubigeo VALUES ('081211', '08', '12', '11', 'OROPESA');
INSERT INTO ubigeo VALUES ('081212', '08', '12', '12', 'QUIQUIJANA');
INSERT INTO ubigeo VALUES ('081300', '08', '13', '00', 'URUBAMBA');
INSERT INTO ubigeo VALUES ('081301', '08', '13', '01', 'URUBAMBA');
INSERT INTO ubigeo VALUES ('081302', '08', '13', '02', 'CHINCHERO');
INSERT INTO ubigeo VALUES ('081303', '08', '13', '03', 'HUAYLLABAMBA');
INSERT INTO ubigeo VALUES ('081304', '08', '13', '04', 'MACHUPICCHU');
INSERT INTO ubigeo VALUES ('081305', '08', '13', '05', 'MARAS');
INSERT INTO ubigeo VALUES ('081306', '08', '13', '06', 'OLLANTAYTAMBO');
INSERT INTO ubigeo VALUES ('081307', '08', '13', '07', 'YUCAY');
INSERT INTO ubigeo VALUES ('090000', '09', '00', '00', 'HUANCAVELICA');
INSERT INTO ubigeo VALUES ('090100', '09', '01', '00', 'HUANCAVELICA');
INSERT INTO ubigeo VALUES ('090101', '09', '01', '01', 'HUANCAVELICA');
INSERT INTO ubigeo VALUES ('090102', '09', '01', '02', 'ACOBAMBILLA');
INSERT INTO ubigeo VALUES ('090103', '09', '01', '03', 'ACORIA');
INSERT INTO ubigeo VALUES ('090104', '09', '01', '04', 'CONAYCA');
INSERT INTO ubigeo VALUES ('090105', '09', '01', '05', 'CUENCA');
INSERT INTO ubigeo VALUES ('090106', '09', '01', '06', 'HUACHOCOLPA');
INSERT INTO ubigeo VALUES ('090107', '09', '01', '07', 'HUAYLLAHUARA');
INSERT INTO ubigeo VALUES ('090108', '09', '01', '08', 'IZCUCHACA');
INSERT INTO ubigeo VALUES ('090109', '09', '01', '09', 'LARIA');
INSERT INTO ubigeo VALUES ('090110', '09', '01', '10', 'MANTA');
INSERT INTO ubigeo VALUES ('090111', '09', '01', '11', 'MARISCAL CACERES');
INSERT INTO ubigeo VALUES ('090112', '09', '01', '12', 'MOYA');
INSERT INTO ubigeo VALUES ('090113', '09', '01', '13', 'NUEVO OCCORO');
INSERT INTO ubigeo VALUES ('090114', '09', '01', '14', 'PALCA');
INSERT INTO ubigeo VALUES ('090115', '09', '01', '15', 'PILCHACA');
INSERT INTO ubigeo VALUES ('090116', '09', '01', '16', 'VILCA');
INSERT INTO ubigeo VALUES ('090117', '09', '01', '17', 'YAULI');
INSERT INTO ubigeo VALUES ('090118', '09', '01', '18', 'ASCENSION');
INSERT INTO ubigeo VALUES ('090119', '09', '01', '19', 'HUANDO');
INSERT INTO ubigeo VALUES ('090200', '09', '02', '00', 'ACOBAMBA');
INSERT INTO ubigeo VALUES ('090201', '09', '02', '01', 'ACOBAMBA');
INSERT INTO ubigeo VALUES ('090202', '09', '02', '02', 'ANDABAMBA');
INSERT INTO ubigeo VALUES ('090203', '09', '02', '03', 'ANTA');
INSERT INTO ubigeo VALUES ('090204', '09', '02', '04', 'CAJA');
INSERT INTO ubigeo VALUES ('090205', '09', '02', '05', 'MARCAS');
INSERT INTO ubigeo VALUES ('090206', '09', '02', '06', 'PAUCARA');
INSERT INTO ubigeo VALUES ('090207', '09', '02', '07', 'POMACOCHA');
INSERT INTO ubigeo VALUES ('090208', '09', '02', '08', 'ROSARIO');
INSERT INTO ubigeo VALUES ('090300', '09', '03', '00', 'ANGARAES');
INSERT INTO ubigeo VALUES ('090301', '09', '03', '01', 'LIRCAY');
INSERT INTO ubigeo VALUES ('090302', '09', '03', '02', 'ANCHONGA');
INSERT INTO ubigeo VALUES ('090303', '09', '03', '03', 'CALLANMARCA');
INSERT INTO ubigeo VALUES ('090304', '09', '03', '04', 'CCOCHACCASA');
INSERT INTO ubigeo VALUES ('090305', '09', '03', '05', 'CHINCHO');
INSERT INTO ubigeo VALUES ('090306', '09', '03', '06', 'CONGALLA');
INSERT INTO ubigeo VALUES ('090307', '09', '03', '07', 'HUANCA-HUANCA');
INSERT INTO ubigeo VALUES ('090308', '09', '03', '08', 'HUAYLLAY GRANDE');
INSERT INTO ubigeo VALUES ('090309', '09', '03', '09', 'JULCAMARCA');
INSERT INTO ubigeo VALUES ('090310', '09', '03', '10', 'SAN ANTONIO DE ANTAPARCO');
INSERT INTO ubigeo VALUES ('090311', '09', '03', '11', 'SANTO TOMAS DE PATA');
INSERT INTO ubigeo VALUES ('090312', '09', '03', '12', 'SECCLLA');
INSERT INTO ubigeo VALUES ('090400', '09', '04', '00', 'CASTROVIRREYNA');
INSERT INTO ubigeo VALUES ('090401', '09', '04', '01', 'CASTROVIRREYNA');
INSERT INTO ubigeo VALUES ('090402', '09', '04', '02', 'ARMA');
INSERT INTO ubigeo VALUES ('090403', '09', '04', '03', 'AURAHUA');
INSERT INTO ubigeo VALUES ('090404', '09', '04', '04', 'CAPILLAS');
INSERT INTO ubigeo VALUES ('090405', '09', '04', '05', 'CHUPAMARCA');
INSERT INTO ubigeo VALUES ('090406', '09', '04', '06', 'COCAS');
INSERT INTO ubigeo VALUES ('090407', '09', '04', '07', 'HUACHOS');
INSERT INTO ubigeo VALUES ('090408', '09', '04', '08', 'HUAMATAMBO');
INSERT INTO ubigeo VALUES ('090409', '09', '04', '09', 'MOLLEPAMPA');
INSERT INTO ubigeo VALUES ('090410', '09', '04', '10', 'SAN JUAN');
INSERT INTO ubigeo VALUES ('090411', '09', '04', '11', 'SANTA ANA');
INSERT INTO ubigeo VALUES ('090412', '09', '04', '12', 'TANTARA');
INSERT INTO ubigeo VALUES ('090413', '09', '04', '13', 'TICRAPO');
INSERT INTO ubigeo VALUES ('090500', '09', '05', '00', 'CHURCAMPA');
INSERT INTO ubigeo VALUES ('090501', '09', '05', '01', 'CHURCAMPA');
INSERT INTO ubigeo VALUES ('090502', '09', '05', '02', 'ANCO');
INSERT INTO ubigeo VALUES ('090503', '09', '05', '03', 'CHINCHIHUASI');
INSERT INTO ubigeo VALUES ('090504', '09', '05', '04', 'EL CARMEN');
INSERT INTO ubigeo VALUES ('090505', '09', '05', '05', 'LA MERCED');
INSERT INTO ubigeo VALUES ('090506', '09', '05', '06', 'LOCROJA');
INSERT INTO ubigeo VALUES ('090507', '09', '05', '07', 'PAUCARBAMBA');
INSERT INTO ubigeo VALUES ('090508', '09', '05', '08', 'SAN MIGUEL DE MAYOCC');
INSERT INTO ubigeo VALUES ('090509', '09', '05', '09', 'SAN PEDRO DE CORIS');
INSERT INTO ubigeo VALUES ('090510', '09', '05', '10', 'PACHAMARCA');
INSERT INTO ubigeo VALUES ('090511', '09', '05', '11', 'COSME');
INSERT INTO ubigeo VALUES ('090600', '09', '06', '00', 'HUAYTARA');
INSERT INTO ubigeo VALUES ('090601', '09', '06', '01', 'HUAYTARA');
INSERT INTO ubigeo VALUES ('090602', '09', '06', '02', 'AYAVI');
INSERT INTO ubigeo VALUES ('090603', '09', '06', '03', 'CORDOVA');
INSERT INTO ubigeo VALUES ('090604', '09', '06', '04', 'HUAYACUNDO ARMA');
INSERT INTO ubigeo VALUES ('090605', '09', '06', '05', 'LARAMARCA');
INSERT INTO ubigeo VALUES ('090606', '09', '06', '06', 'OCOYO');
INSERT INTO ubigeo VALUES ('090607', '09', '06', '07', 'PILPICHACA');
INSERT INTO ubigeo VALUES ('090608', '09', '06', '08', 'QUERCO');
INSERT INTO ubigeo VALUES ('090609', '09', '06', '09', 'QUITO-ARMA');
INSERT INTO ubigeo VALUES ('090610', '09', '06', '10', 'SAN ANTONIO DE CUSICANCHA');
INSERT INTO ubigeo VALUES ('090611', '09', '06', '11', 'SAN FRANCISCO DE SANGAYAICO');
INSERT INTO ubigeo VALUES ('090612', '09', '06', '12', 'SAN ISIDRO');
INSERT INTO ubigeo VALUES ('090613', '09', '06', '13', 'SANTIAGO DE CHOCORVOS');
INSERT INTO ubigeo VALUES ('090614', '09', '06', '14', 'SANTIAGO DE QUIRAHUARA');
INSERT INTO ubigeo VALUES ('090615', '09', '06', '15', 'SANTO DOMINGO DE CAPILLAS');
INSERT INTO ubigeo VALUES ('090616', '09', '06', '16', 'TAMBO');
INSERT INTO ubigeo VALUES ('090700', '09', '07', '00', 'TAYACAJA');
INSERT INTO ubigeo VALUES ('090701', '09', '07', '01', 'PAMPAS');
INSERT INTO ubigeo VALUES ('090702', '09', '07', '02', 'ACOSTAMBO');
INSERT INTO ubigeo VALUES ('090703', '09', '07', '03', 'ACRAQUIA');
INSERT INTO ubigeo VALUES ('090704', '09', '07', '04', 'AHUAYCHA');
INSERT INTO ubigeo VALUES ('090705', '09', '07', '05', 'COLCABAMBA');
INSERT INTO ubigeo VALUES ('090706', '09', '07', '06', 'DANIEL HERNANDEZ');
INSERT INTO ubigeo VALUES ('090707', '09', '07', '07', 'HUACHOCOLPA');
INSERT INTO ubigeo VALUES ('090709', '09', '07', '09', 'HUARIBAMBA');
INSERT INTO ubigeo VALUES ('090710', '09', '07', '10', 'ÑAHUIMPUQUIO');
INSERT INTO ubigeo VALUES ('090711', '09', '07', '11', 'PAZOS');
INSERT INTO ubigeo VALUES ('090713', '09', '07', '13', 'QUISHUAR');
INSERT INTO ubigeo VALUES ('090714', '09', '07', '14', 'SALCABAMBA');
INSERT INTO ubigeo VALUES ('090715', '09', '07', '15', 'SALCAHUASI');
INSERT INTO ubigeo VALUES ('090716', '09', '07', '16', 'SAN MARCOS DE ROCCHAC');
INSERT INTO ubigeo VALUES ('090717', '09', '07', '17', 'SURCUBAMBA');
INSERT INTO ubigeo VALUES ('090718', '09', '07', '18', 'TINTAY PUNCU');
INSERT INTO ubigeo VALUES ('100000', '10', '00', '00', 'HUANUCO');
INSERT INTO ubigeo VALUES ('100100', '10', '01', '00', 'HUANUCO');
INSERT INTO ubigeo VALUES ('100101', '10', '01', '01', 'HUANUCO');
INSERT INTO ubigeo VALUES ('100102', '10', '01', '02', 'AMARILIS');
INSERT INTO ubigeo VALUES ('100103', '10', '01', '03', 'CHINCHAO');
INSERT INTO ubigeo VALUES ('100104', '10', '01', '04', 'CHURUBAMBA');
INSERT INTO ubigeo VALUES ('100105', '10', '01', '05', 'MARGOS');
INSERT INTO ubigeo VALUES ('100106', '10', '01', '06', 'QUISQUI (KICHKI)');
INSERT INTO ubigeo VALUES ('100107', '10', '01', '07', 'SAN FRANCISCO DE CAYRAN');
INSERT INTO ubigeo VALUES ('100108', '10', '01', '08', 'SAN PEDRO DE CHAULAN');
INSERT INTO ubigeo VALUES ('100109', '10', '01', '09', 'SANTA MARIA DEL VALLE');
INSERT INTO ubigeo VALUES ('100110', '10', '01', '10', 'YARUMAYO');
INSERT INTO ubigeo VALUES ('100111', '10', '01', '11', 'PILLCO MARCA');
INSERT INTO ubigeo VALUES ('100112', '10', '01', '12', 'YACUS');
INSERT INTO ubigeo VALUES ('100200', '10', '02', '00', 'AMBO');
INSERT INTO ubigeo VALUES ('100201', '10', '02', '01', 'AMBO');
INSERT INTO ubigeo VALUES ('100202', '10', '02', '02', 'CAYNA');
INSERT INTO ubigeo VALUES ('100203', '10', '02', '03', 'COLPAS');
INSERT INTO ubigeo VALUES ('100204', '10', '02', '04', 'CONCHAMARCA');
INSERT INTO ubigeo VALUES ('100205', '10', '02', '05', 'HUACAR');
INSERT INTO ubigeo VALUES ('100206', '10', '02', '06', 'SAN FRANCISCO');
INSERT INTO ubigeo VALUES ('100207', '10', '02', '07', 'SAN RAFAEL');
INSERT INTO ubigeo VALUES ('100208', '10', '02', '08', 'TOMAY KICHWA');
INSERT INTO ubigeo VALUES ('100300', '10', '03', '00', 'DOS DE MAYO');
INSERT INTO ubigeo VALUES ('100301', '10', '03', '01', 'LA UNION');
INSERT INTO ubigeo VALUES ('100307', '10', '03', '07', 'CHUQUIS');
INSERT INTO ubigeo VALUES ('100311', '10', '03', '11', 'MARIAS');
INSERT INTO ubigeo VALUES ('100313', '10', '03', '13', 'PACHAS');
INSERT INTO ubigeo VALUES ('100316', '10', '03', '16', 'QUIVILLA');
INSERT INTO ubigeo VALUES ('100317', '10', '03', '17', 'RIPAN');
INSERT INTO ubigeo VALUES ('100321', '10', '03', '21', 'SHUNQUI');
INSERT INTO ubigeo VALUES ('100322', '10', '03', '22', 'SILLAPATA');
INSERT INTO ubigeo VALUES ('100323', '10', '03', '23', 'YANAS');
INSERT INTO ubigeo VALUES ('100400', '10', '04', '00', 'HUACAYBAMBA');
INSERT INTO ubigeo VALUES ('100401', '10', '04', '01', 'HUACAYBAMBA');
INSERT INTO ubigeo VALUES ('100402', '10', '04', '02', 'CANCHABAMBA');
INSERT INTO ubigeo VALUES ('100403', '10', '04', '03', 'COCHABAMBA');
INSERT INTO ubigeo VALUES ('100404', '10', '04', '04', 'PINRA');
INSERT INTO ubigeo VALUES ('100500', '10', '05', '00', 'HUAMALIES');
INSERT INTO ubigeo VALUES ('100501', '10', '05', '01', 'LLATA');
INSERT INTO ubigeo VALUES ('100502', '10', '05', '02', 'ARANCAY');
INSERT INTO ubigeo VALUES ('100503', '10', '05', '03', 'CHAVIN DE PARIARCA');
INSERT INTO ubigeo VALUES ('100504', '10', '05', '04', 'JACAS GRANDE');
INSERT INTO ubigeo VALUES ('100505', '10', '05', '05', 'JIRCAN');
INSERT INTO ubigeo VALUES ('100506', '10', '05', '06', 'MIRAFLORES');
INSERT INTO ubigeo VALUES ('100507', '10', '05', '07', 'MONZON');
INSERT INTO ubigeo VALUES ('100508', '10', '05', '08', 'PUNCHAO');
INSERT INTO ubigeo VALUES ('100509', '10', '05', '09', 'PUÑOS');
INSERT INTO ubigeo VALUES ('100510', '10', '05', '10', 'SINGA');
INSERT INTO ubigeo VALUES ('100511', '10', '05', '11', 'TANTAMAYO');
INSERT INTO ubigeo VALUES ('100600', '10', '06', '00', 'LEONCIO PRADO');
INSERT INTO ubigeo VALUES ('100601', '10', '06', '01', 'RUPA-RUPA');
INSERT INTO ubigeo VALUES ('100602', '10', '06', '02', 'DANIEL ALOMIA ROBLES');
INSERT INTO ubigeo VALUES ('100603', '10', '06', '03', 'HERMILIO VALDIZAN');
INSERT INTO ubigeo VALUES ('100604', '10', '06', '04', 'JOSE CRESPO Y CASTILLO');
INSERT INTO ubigeo VALUES ('100605', '10', '06', '05', 'LUYANDO');
INSERT INTO ubigeo VALUES ('100606', '10', '06', '06', 'MARIANO DAMASO BERAUN');
INSERT INTO ubigeo VALUES ('100700', '10', '07', '00', 'MARAÑON');
INSERT INTO ubigeo VALUES ('100701', '10', '07', '01', 'HUACRACHUCO');
INSERT INTO ubigeo VALUES ('100702', '10', '07', '02', 'CHOLON');
INSERT INTO ubigeo VALUES ('100703', '10', '07', '03', 'SAN BUENAVENTURA');
INSERT INTO ubigeo VALUES ('100800', '10', '08', '00', 'PACHITEA');
INSERT INTO ubigeo VALUES ('100801', '10', '08', '01', 'PANAO');
INSERT INTO ubigeo VALUES ('100802', '10', '08', '02', 'CHAGLLA');
INSERT INTO ubigeo VALUES ('100803', '10', '08', '03', 'MOLINO');
INSERT INTO ubigeo VALUES ('100804', '10', '08', '04', 'UMARI');
INSERT INTO ubigeo VALUES ('100900', '10', '09', '00', 'PUERTO INCA');
INSERT INTO ubigeo VALUES ('100901', '10', '09', '01', 'PUERTO INCA');
INSERT INTO ubigeo VALUES ('100902', '10', '09', '02', 'CODO DEL POZUZO');
INSERT INTO ubigeo VALUES ('100903', '10', '09', '03', 'HONORIA');
INSERT INTO ubigeo VALUES ('100904', '10', '09', '04', 'TOURNAVISTA');
INSERT INTO ubigeo VALUES ('100905', '10', '09', '05', 'YUYAPICHIS');
INSERT INTO ubigeo VALUES ('101000', '10', '10', '00', 'LAURICOCHA');
INSERT INTO ubigeo VALUES ('101001', '10', '10', '01', 'JESUS');
INSERT INTO ubigeo VALUES ('101002', '10', '10', '02', 'BAÑOS');
INSERT INTO ubigeo VALUES ('101003', '10', '10', '03', 'JIVIA');
INSERT INTO ubigeo VALUES ('101004', '10', '10', '04', 'QUEROPALCA');
INSERT INTO ubigeo VALUES ('101005', '10', '10', '05', 'RONDOS');
INSERT INTO ubigeo VALUES ('101006', '10', '10', '06', 'SAN FRANCISCO DE ASIS');
INSERT INTO ubigeo VALUES ('101007', '10', '10', '07', 'SAN MIGUEL DE CAURI');
INSERT INTO ubigeo VALUES ('101100', '10', '11', '00', 'YAROWILCA');
INSERT INTO ubigeo VALUES ('101101', '10', '11', '01', 'CHAVINILLO');
INSERT INTO ubigeo VALUES ('101102', '10', '11', '02', 'CAHUAC');
INSERT INTO ubigeo VALUES ('101103', '10', '11', '03', 'CHACABAMBA');
INSERT INTO ubigeo VALUES ('101104', '10', '11', '04', 'APARICIO POMARES');
INSERT INTO ubigeo VALUES ('101105', '10', '11', '05', 'JACAS CHICO');
INSERT INTO ubigeo VALUES ('101106', '10', '11', '06', 'OBAS');
INSERT INTO ubigeo VALUES ('101107', '10', '11', '07', 'PAMPAMARCA');
INSERT INTO ubigeo VALUES ('101108', '10', '11', '08', 'CHORAS');
INSERT INTO ubigeo VALUES ('110000', '11', '00', '00', 'ICA');
INSERT INTO ubigeo VALUES ('110100', '11', '01', '00', 'ICA');
INSERT INTO ubigeo VALUES ('110101', '11', '01', '01', 'ICA');
INSERT INTO ubigeo VALUES ('110102', '11', '01', '02', 'LA TINGUIÑA');
INSERT INTO ubigeo VALUES ('110103', '11', '01', '03', 'LOS AQUIJES');
INSERT INTO ubigeo VALUES ('110104', '11', '01', '04', 'OCUCAJE');
INSERT INTO ubigeo VALUES ('110105', '11', '01', '05', 'PACHACUTEC');
INSERT INTO ubigeo VALUES ('110106', '11', '01', '06', 'PARCONA');
INSERT INTO ubigeo VALUES ('110107', '11', '01', '07', 'PUEBLO NUEVO');
INSERT INTO ubigeo VALUES ('110108', '11', '01', '08', 'SALAS');
INSERT INTO ubigeo VALUES ('110109', '11', '01', '09', 'SAN JOSE DE LOS MOLINOS');
INSERT INTO ubigeo VALUES ('110110', '11', '01', '10', 'SAN JUAN BAUTISTA');
INSERT INTO ubigeo VALUES ('110111', '11', '01', '11', 'SANTIAGO');
INSERT INTO ubigeo VALUES ('110112', '11', '01', '12', 'SUBTANJALLA');
INSERT INTO ubigeo VALUES ('110113', '11', '01', '13', 'TATE');
INSERT INTO ubigeo VALUES ('110114', '11', '01', '14', 'YAUCA DEL ROSARIO');
INSERT INTO ubigeo VALUES ('110200', '11', '02', '00', 'CHINCHA');
INSERT INTO ubigeo VALUES ('110201', '11', '02', '01', 'CHINCHA ALTA');
INSERT INTO ubigeo VALUES ('110202', '11', '02', '02', 'ALTO LARAN');
INSERT INTO ubigeo VALUES ('110203', '11', '02', '03', 'CHAVIN');
INSERT INTO ubigeo VALUES ('110204', '11', '02', '04', 'CHINCHA BAJA');
INSERT INTO ubigeo VALUES ('110205', '11', '02', '05', 'EL CARMEN');
INSERT INTO ubigeo VALUES ('110206', '11', '02', '06', 'GROCIO PRADO');
INSERT INTO ubigeo VALUES ('110207', '11', '02', '07', 'PUEBLO NUEVO');
INSERT INTO ubigeo VALUES ('110208', '11', '02', '08', 'SAN JUAN DE YANAC');
INSERT INTO ubigeo VALUES ('110209', '11', '02', '09', 'SAN PEDRO DE HUACARPANA');
INSERT INTO ubigeo VALUES ('110210', '11', '02', '10', 'SUNAMPE');
INSERT INTO ubigeo VALUES ('110211', '11', '02', '11', 'TAMBO DE MORA');
INSERT INTO ubigeo VALUES ('110300', '11', '03', '00', 'NAZCA');
INSERT INTO ubigeo VALUES ('110301', '11', '03', '01', 'NAZCA');
INSERT INTO ubigeo VALUES ('110302', '11', '03', '02', 'CHANGUILLO');
INSERT INTO ubigeo VALUES ('110303', '11', '03', '03', 'EL INGENIO');
INSERT INTO ubigeo VALUES ('110304', '11', '03', '04', 'MARCONA');
INSERT INTO ubigeo VALUES ('110305', '11', '03', '05', 'VISTA ALEGRE');
INSERT INTO ubigeo VALUES ('110400', '11', '04', '00', 'PALPA');
INSERT INTO ubigeo VALUES ('110401', '11', '04', '01', 'PALPA');
INSERT INTO ubigeo VALUES ('110402', '11', '04', '02', 'LLIPATA');
INSERT INTO ubigeo VALUES ('110403', '11', '04', '03', 'RIO GRANDE');
INSERT INTO ubigeo VALUES ('110404', '11', '04', '04', 'SANTA CRUZ');
INSERT INTO ubigeo VALUES ('110405', '11', '04', '05', 'TIBILLO');
INSERT INTO ubigeo VALUES ('110500', '11', '05', '00', 'PISCO');
INSERT INTO ubigeo VALUES ('110501', '11', '05', '01', 'PISCO');
INSERT INTO ubigeo VALUES ('110502', '11', '05', '02', 'HUANCANO');
INSERT INTO ubigeo VALUES ('110503', '11', '05', '03', 'HUMAY');
INSERT INTO ubigeo VALUES ('110504', '11', '05', '04', 'INDEPENDENCIA');
INSERT INTO ubigeo VALUES ('110505', '11', '05', '05', 'PARACAS');
INSERT INTO ubigeo VALUES ('110506', '11', '05', '06', 'SAN ANDRES');
INSERT INTO ubigeo VALUES ('110507', '11', '05', '07', 'SAN CLEMENTE');
INSERT INTO ubigeo VALUES ('110508', '11', '05', '08', 'TUPAC AMARU INCA');
INSERT INTO ubigeo VALUES ('120000', '12', '00', '00', 'JUNIN');
INSERT INTO ubigeo VALUES ('120100', '12', '01', '00', 'HUANCAYO');
INSERT INTO ubigeo VALUES ('120101', '12', '01', '01', 'HUANCAYO');
INSERT INTO ubigeo VALUES ('120104', '12', '01', '04', 'CARHUACALLANGA');
INSERT INTO ubigeo VALUES ('120105', '12', '01', '05', 'CHACAPAMPA');
INSERT INTO ubigeo VALUES ('120106', '12', '01', '06', 'CHICCHE');
INSERT INTO ubigeo VALUES ('120107', '12', '01', '07', 'CHILCA');
INSERT INTO ubigeo VALUES ('120108', '12', '01', '08', 'CHONGOS ALTO');
INSERT INTO ubigeo VALUES ('120111', '12', '01', '11', 'CHUPURO');
INSERT INTO ubigeo VALUES ('120112', '12', '01', '12', 'COLCA');
INSERT INTO ubigeo VALUES ('120113', '12', '01', '13', 'CULLHUAS');
INSERT INTO ubigeo VALUES ('120114', '12', '01', '14', 'EL TAMBO');
INSERT INTO ubigeo VALUES ('120116', '12', '01', '16', 'HUACRAPUQUIO');
INSERT INTO ubigeo VALUES ('120117', '12', '01', '17', 'HUALHUAS');
INSERT INTO ubigeo VALUES ('120119', '12', '01', '19', 'HUANCAN');
INSERT INTO ubigeo VALUES ('120120', '12', '01', '20', 'HUASICANCHA');
INSERT INTO ubigeo VALUES ('120121', '12', '01', '21', 'HUAYUCACHI');
INSERT INTO ubigeo VALUES ('120122', '12', '01', '22', 'INGENIO');
INSERT INTO ubigeo VALUES ('120124', '12', '01', '24', 'PARIAHUANCA');
INSERT INTO ubigeo VALUES ('120125', '12', '01', '25', 'PILCOMAYO');
INSERT INTO ubigeo VALUES ('120126', '12', '01', '26', 'PUCARA');
INSERT INTO ubigeo VALUES ('120127', '12', '01', '27', 'QUICHUAY');
INSERT INTO ubigeo VALUES ('120128', '12', '01', '28', 'QUILCAS');
INSERT INTO ubigeo VALUES ('120129', '12', '01', '29', 'SAN AGUSTIN');
INSERT INTO ubigeo VALUES ('120130', '12', '01', '30', 'SAN JERONIMO DE TUNAN');
INSERT INTO ubigeo VALUES ('120132', '12', '01', '32', 'SAÑO');
INSERT INTO ubigeo VALUES ('120133', '12', '01', '33', 'SAPALLANGA');
INSERT INTO ubigeo VALUES ('120134', '12', '01', '34', 'SICAYA');
INSERT INTO ubigeo VALUES ('120135', '12', '01', '35', 'SANTO DOMINGO DE ACOBAMBA');
INSERT INTO ubigeo VALUES ('120136', '12', '01', '36', 'VIQUES');
INSERT INTO ubigeo VALUES ('120200', '12', '02', '00', 'CONCEPCION');
INSERT INTO ubigeo VALUES ('120201', '12', '02', '01', 'CONCEPCION');
INSERT INTO ubigeo VALUES ('120202', '12', '02', '02', 'ACO');
INSERT INTO ubigeo VALUES ('120203', '12', '02', '03', 'ANDAMARCA');
INSERT INTO ubigeo VALUES ('120204', '12', '02', '04', 'CHAMBARA');
INSERT INTO ubigeo VALUES ('120205', '12', '02', '05', 'COCHAS');
INSERT INTO ubigeo VALUES ('120206', '12', '02', '06', 'COMAS');
INSERT INTO ubigeo VALUES ('120207', '12', '02', '07', 'HEROINAS TOLEDO');
INSERT INTO ubigeo VALUES ('120208', '12', '02', '08', 'MANZANARES');
INSERT INTO ubigeo VALUES ('120209', '12', '02', '09', 'MARISCAL CASTILLA');
INSERT INTO ubigeo VALUES ('120210', '12', '02', '10', 'MATAHUASI');
INSERT INTO ubigeo VALUES ('120211', '12', '02', '11', 'MITO');
INSERT INTO ubigeo VALUES ('120212', '12', '02', '12', 'NUEVE DE JULIO');
INSERT INTO ubigeo VALUES ('120213', '12', '02', '13', 'ORCOTUNA');
INSERT INTO ubigeo VALUES ('120214', '12', '02', '14', 'SAN JOSE DE QUERO');
INSERT INTO ubigeo VALUES ('120215', '12', '02', '15', 'SANTA ROSA DE OCOPA');
INSERT INTO ubigeo VALUES ('120300', '12', '03', '00', 'CHANCHAMAYO');
INSERT INTO ubigeo VALUES ('120301', '12', '03', '01', 'CHANCHAMAYO');
INSERT INTO ubigeo VALUES ('120302', '12', '03', '02', 'PERENE');
INSERT INTO ubigeo VALUES ('120303', '12', '03', '03', 'PICHANAQUI');
INSERT INTO ubigeo VALUES ('120304', '12', '03', '04', 'SAN LUIS DE SHUARO');
INSERT INTO ubigeo VALUES ('120305', '12', '03', '05', 'SAN RAMON');
INSERT INTO ubigeo VALUES ('120306', '12', '03', '06', 'VITOC');
INSERT INTO ubigeo VALUES ('120400', '12', '04', '00', 'JAUJA');
INSERT INTO ubigeo VALUES ('120401', '12', '04', '01', 'JAUJA');
INSERT INTO ubigeo VALUES ('120402', '12', '04', '02', 'ACOLLA');
INSERT INTO ubigeo VALUES ('120403', '12', '04', '03', 'APATA');
INSERT INTO ubigeo VALUES ('120404', '12', '04', '04', 'ATAURA');
INSERT INTO ubigeo VALUES ('120405', '12', '04', '05', 'CANCHAYLLO');
INSERT INTO ubigeo VALUES ('120406', '12', '04', '06', 'CURICACA');
INSERT INTO ubigeo VALUES ('120407', '12', '04', '07', 'EL MANTARO');
INSERT INTO ubigeo VALUES ('120408', '12', '04', '08', 'HUAMALI');
INSERT INTO ubigeo VALUES ('120409', '12', '04', '09', 'HUARIPAMPA');
INSERT INTO ubigeo VALUES ('120410', '12', '04', '10', 'HUERTAS');
INSERT INTO ubigeo VALUES ('120411', '12', '04', '11', 'JANJAILLO');
INSERT INTO ubigeo VALUES ('120412', '12', '04', '12', 'JULCAN');
INSERT INTO ubigeo VALUES ('120413', '12', '04', '13', 'LEONOR ORDOÑEZ');
INSERT INTO ubigeo VALUES ('120414', '12', '04', '14', 'LLOCLLAPAMPA');
INSERT INTO ubigeo VALUES ('120415', '12', '04', '15', 'MARCO');
INSERT INTO ubigeo VALUES ('120416', '12', '04', '16', 'MASMA');
INSERT INTO ubigeo VALUES ('120417', '12', '04', '17', 'MASMA CHICCHE');
INSERT INTO ubigeo VALUES ('120418', '12', '04', '18', 'MOLINOS');
INSERT INTO ubigeo VALUES ('120419', '12', '04', '19', 'MONOBAMBA');
INSERT INTO ubigeo VALUES ('120420', '12', '04', '20', 'MUQUI');
INSERT INTO ubigeo VALUES ('120421', '12', '04', '21', 'MUQUIYAUYO');
INSERT INTO ubigeo VALUES ('120422', '12', '04', '22', 'PACA');
INSERT INTO ubigeo VALUES ('120423', '12', '04', '23', 'PACCHA');
INSERT INTO ubigeo VALUES ('120424', '12', '04', '24', 'PANCAN');
INSERT INTO ubigeo VALUES ('120425', '12', '04', '25', 'PARCO');
INSERT INTO ubigeo VALUES ('120426', '12', '04', '26', 'POMACANCHA');
INSERT INTO ubigeo VALUES ('120427', '12', '04', '27', 'RICRAN');
INSERT INTO ubigeo VALUES ('120428', '12', '04', '28', 'SAN LORENZO');
INSERT INTO ubigeo VALUES ('120429', '12', '04', '29', 'SAN PEDRO DE CHUNAN');
INSERT INTO ubigeo VALUES ('120430', '12', '04', '30', 'SAUSA');
INSERT INTO ubigeo VALUES ('120431', '12', '04', '31', 'SINCOS');
INSERT INTO ubigeo VALUES ('120432', '12', '04', '32', 'TUNAN MARCA');
INSERT INTO ubigeo VALUES ('120433', '12', '04', '33', 'YAULI');
INSERT INTO ubigeo VALUES ('120434', '12', '04', '34', 'YAUYOS');
INSERT INTO ubigeo VALUES ('120500', '12', '05', '00', 'JUNIN');
INSERT INTO ubigeo VALUES ('120501', '12', '05', '01', 'JUNIN');
INSERT INTO ubigeo VALUES ('120502', '12', '05', '02', 'CARHUAMAYO');
INSERT INTO ubigeo VALUES ('120503', '12', '05', '03', 'ONDORES');
INSERT INTO ubigeo VALUES ('120504', '12', '05', '04', 'ULCUMAYO');
INSERT INTO ubigeo VALUES ('120600', '12', '06', '00', 'SATIPO');
INSERT INTO ubigeo VALUES ('120601', '12', '06', '01', 'SATIPO');
INSERT INTO ubigeo VALUES ('120602', '12', '06', '02', 'COVIRIALI');
INSERT INTO ubigeo VALUES ('120603', '12', '06', '03', 'LLAYLLA');
INSERT INTO ubigeo VALUES ('120605', '12', '06', '05', 'PAMPA HERMOSA');
INSERT INTO ubigeo VALUES ('120607', '12', '06', '07', 'RIO NEGRO');
INSERT INTO ubigeo VALUES ('120608', '12', '06', '08', 'RIO TAMBO');
INSERT INTO ubigeo VALUES ('120699', '12', '06', '99', 'MAZAMARI - PANGOA');
INSERT INTO ubigeo VALUES ('120700', '12', '07', '00', 'TARMA');
INSERT INTO ubigeo VALUES ('120701', '12', '07', '01', 'TARMA');
INSERT INTO ubigeo VALUES ('120702', '12', '07', '02', 'ACOBAMBA');
INSERT INTO ubigeo VALUES ('120703', '12', '07', '03', 'HUARICOLCA');
INSERT INTO ubigeo VALUES ('120704', '12', '07', '04', 'HUASAHUASI');
INSERT INTO ubigeo VALUES ('120705', '12', '07', '05', 'LA UNION');
INSERT INTO ubigeo VALUES ('120706', '12', '07', '06', 'PALCA');
INSERT INTO ubigeo VALUES ('120707', '12', '07', '07', 'PALCAMAYO');
INSERT INTO ubigeo VALUES ('120708', '12', '07', '08', 'SAN PEDRO DE CAJAS');
INSERT INTO ubigeo VALUES ('120709', '12', '07', '09', 'TAPO');
INSERT INTO ubigeo VALUES ('120800', '12', '08', '00', 'YAULI');
INSERT INTO ubigeo VALUES ('120801', '12', '08', '01', 'LA OROYA');
INSERT INTO ubigeo VALUES ('120802', '12', '08', '02', 'CHACAPALPA');
INSERT INTO ubigeo VALUES ('120803', '12', '08', '03', 'HUAY-HUAY');
INSERT INTO ubigeo VALUES ('120804', '12', '08', '04', 'MARCAPOMACOCHA');
INSERT INTO ubigeo VALUES ('120805', '12', '08', '05', 'MOROCOCHA');
INSERT INTO ubigeo VALUES ('120806', '12', '08', '06', 'PACCHA');
INSERT INTO ubigeo VALUES ('120807', '12', '08', '07', 'SANTA BARBARA DE CARHUACAYAN');
INSERT INTO ubigeo VALUES ('120808', '12', '08', '08', 'SANTA ROSA DE SACCO');
INSERT INTO ubigeo VALUES ('120809', '12', '08', '09', 'SUITUCANCHA');
INSERT INTO ubigeo VALUES ('120810', '12', '08', '10', 'YAULI');
INSERT INTO ubigeo VALUES ('120900', '12', '09', '00', 'CHUPACA');
INSERT INTO ubigeo VALUES ('120901', '12', '09', '01', 'CHUPACA');
INSERT INTO ubigeo VALUES ('120902', '12', '09', '02', 'AHUAC');
INSERT INTO ubigeo VALUES ('120903', '12', '09', '03', 'CHONGOS BAJO');
INSERT INTO ubigeo VALUES ('120904', '12', '09', '04', 'HUACHAC');
INSERT INTO ubigeo VALUES ('120905', '12', '09', '05', 'HUAMANCACA CHICO');
INSERT INTO ubigeo VALUES ('120906', '12', '09', '06', 'SAN JUAN DE ISCOS');
INSERT INTO ubigeo VALUES ('120907', '12', '09', '07', 'SAN JUAN DE JARPA');
INSERT INTO ubigeo VALUES ('120908', '12', '09', '08', 'TRES DE DICIEMBRE');
INSERT INTO ubigeo VALUES ('120909', '12', '09', '09', 'YANACANCHA');
INSERT INTO ubigeo VALUES ('130000', '13', '00', '00', 'LA LIBERTAD');
INSERT INTO ubigeo VALUES ('130100', '13', '01', '00', 'TRUJILLO');
INSERT INTO ubigeo VALUES ('130101', '13', '01', '01', 'TRUJILLO');
INSERT INTO ubigeo VALUES ('130102', '13', '01', '02', 'EL PORVENIR');
INSERT INTO ubigeo VALUES ('130103', '13', '01', '03', 'FLORENCIA DE MORA');
INSERT INTO ubigeo VALUES ('130104', '13', '01', '04', 'HUANCHACO');
INSERT INTO ubigeo VALUES ('130105', '13', '01', '05', 'LA ESPERANZA');
INSERT INTO ubigeo VALUES ('130106', '13', '01', '06', 'LAREDO');
INSERT INTO ubigeo VALUES ('130107', '13', '01', '07', 'MOCHE');
INSERT INTO ubigeo VALUES ('130108', '13', '01', '08', 'POROTO');
INSERT INTO ubigeo VALUES ('130109', '13', '01', '09', 'SALAVERRY');
INSERT INTO ubigeo VALUES ('130110', '13', '01', '10', 'SIMBAL');
INSERT INTO ubigeo VALUES ('130111', '13', '01', '11', 'VICTOR LARCO HERRERA');
INSERT INTO ubigeo VALUES ('130200', '13', '02', '00', 'ASCOPE');
INSERT INTO ubigeo VALUES ('130201', '13', '02', '01', 'ASCOPE');
INSERT INTO ubigeo VALUES ('130202', '13', '02', '02', 'CHICAMA');
INSERT INTO ubigeo VALUES ('130203', '13', '02', '03', 'CHOCOPE');
INSERT INTO ubigeo VALUES ('130204', '13', '02', '04', 'MAGDALENA DE CAO');
INSERT INTO ubigeo VALUES ('130205', '13', '02', '05', 'PAIJAN');
INSERT INTO ubigeo VALUES ('130206', '13', '02', '06', 'RAZURI');
INSERT INTO ubigeo VALUES ('130207', '13', '02', '07', 'SANTIAGO DE CAO');
INSERT INTO ubigeo VALUES ('130208', '13', '02', '08', 'CASA GRANDE');
INSERT INTO ubigeo VALUES ('130300', '13', '03', '00', 'BOLIVAR');
INSERT INTO ubigeo VALUES ('130301', '13', '03', '01', 'BOLIVAR');
INSERT INTO ubigeo VALUES ('130302', '13', '03', '02', 'BAMBAMARCA');
INSERT INTO ubigeo VALUES ('130303', '13', '03', '03', 'CONDORMARCA');
INSERT INTO ubigeo VALUES ('130304', '13', '03', '04', 'LONGOTEA');
INSERT INTO ubigeo VALUES ('130305', '13', '03', '05', 'UCHUMARCA');
INSERT INTO ubigeo VALUES ('130306', '13', '03', '06', 'UCUNCHA');
INSERT INTO ubigeo VALUES ('130400', '13', '04', '00', 'CHEPEN');
INSERT INTO ubigeo VALUES ('130401', '13', '04', '01', 'CHEPEN');
INSERT INTO ubigeo VALUES ('130402', '13', '04', '02', 'PACANGA');
INSERT INTO ubigeo VALUES ('130403', '13', '04', '03', 'PUEBLO NUEVO');
INSERT INTO ubigeo VALUES ('130500', '13', '05', '00', 'JULCAN');
INSERT INTO ubigeo VALUES ('130501', '13', '05', '01', 'JULCAN');
INSERT INTO ubigeo VALUES ('130502', '13', '05', '02', 'CALAMARCA');
INSERT INTO ubigeo VALUES ('130503', '13', '05', '03', 'CARABAMBA');
INSERT INTO ubigeo VALUES ('130504', '13', '05', '04', 'HUASO');
INSERT INTO ubigeo VALUES ('130600', '13', '06', '00', 'OTUZCO');
INSERT INTO ubigeo VALUES ('130601', '13', '06', '01', 'OTUZCO');
INSERT INTO ubigeo VALUES ('130602', '13', '06', '02', 'AGALLPAMPA');
INSERT INTO ubigeo VALUES ('130604', '13', '06', '04', 'CHARAT');
INSERT INTO ubigeo VALUES ('130605', '13', '06', '05', 'HUARANCHAL');
INSERT INTO ubigeo VALUES ('130606', '13', '06', '06', 'LA CUESTA');
INSERT INTO ubigeo VALUES ('130608', '13', '06', '08', 'MACHE');
INSERT INTO ubigeo VALUES ('130610', '13', '06', '10', 'PARANDAY');
INSERT INTO ubigeo VALUES ('130611', '13', '06', '11', 'SALPO');
INSERT INTO ubigeo VALUES ('130613', '13', '06', '13', 'SINSICAP');
INSERT INTO ubigeo VALUES ('130614', '13', '06', '14', 'USQUIL');
INSERT INTO ubigeo VALUES ('130700', '13', '07', '00', 'PACASMAYO');
INSERT INTO ubigeo VALUES ('130701', '13', '07', '01', 'SAN PEDRO DE LLOC');
INSERT INTO ubigeo VALUES ('130702', '13', '07', '02', 'GUADALUPE');
INSERT INTO ubigeo VALUES ('130703', '13', '07', '03', 'JEQUETEPEQUE');
INSERT INTO ubigeo VALUES ('130704', '13', '07', '04', 'PACASMAYO');
INSERT INTO ubigeo VALUES ('130705', '13', '07', '05', 'SAN JOSE');
INSERT INTO ubigeo VALUES ('130800', '13', '08', '00', 'PATAZ');
INSERT INTO ubigeo VALUES ('130801', '13', '08', '01', 'TAYABAMBA');
INSERT INTO ubigeo VALUES ('130802', '13', '08', '02', 'BULDIBUYO');
INSERT INTO ubigeo VALUES ('130803', '13', '08', '03', 'CHILLIA');
INSERT INTO ubigeo VALUES ('130804', '13', '08', '04', 'HUANCASPATA');
INSERT INTO ubigeo VALUES ('130805', '13', '08', '05', 'HUAYLILLAS');
INSERT INTO ubigeo VALUES ('130806', '13', '08', '06', 'HUAYO');
INSERT INTO ubigeo VALUES ('130807', '13', '08', '07', 'ONGON');
INSERT INTO ubigeo VALUES ('130808', '13', '08', '08', 'PARCOY');
INSERT INTO ubigeo VALUES ('130809', '13', '08', '09', 'PATAZ');
INSERT INTO ubigeo VALUES ('130810', '13', '08', '10', 'PIAS');
INSERT INTO ubigeo VALUES ('130811', '13', '08', '11', 'SANTIAGO DE CHALLAS');
INSERT INTO ubigeo VALUES ('130812', '13', '08', '12', 'TAURIJA');
INSERT INTO ubigeo VALUES ('130813', '13', '08', '13', 'URPAY');
INSERT INTO ubigeo VALUES ('130900', '13', '09', '00', 'SANCHEZ CARRION');
INSERT INTO ubigeo VALUES ('130901', '13', '09', '01', 'HUAMACHUCO');
INSERT INTO ubigeo VALUES ('130902', '13', '09', '02', 'CHUGAY');
INSERT INTO ubigeo VALUES ('130903', '13', '09', '03', 'COCHORCO');
INSERT INTO ubigeo VALUES ('130904', '13', '09', '04', 'CURGOS');
INSERT INTO ubigeo VALUES ('130905', '13', '09', '05', 'MARCABAL');
INSERT INTO ubigeo VALUES ('130906', '13', '09', '06', 'SANAGORAN');
INSERT INTO ubigeo VALUES ('130907', '13', '09', '07', 'SARIN');
INSERT INTO ubigeo VALUES ('130908', '13', '09', '08', 'SARTIMBAMBA');
INSERT INTO ubigeo VALUES ('131000', '13', '10', '00', 'SANTIAGO DE CHUCO');
INSERT INTO ubigeo VALUES ('131001', '13', '10', '01', 'SANTIAGO DE CHUCO');
INSERT INTO ubigeo VALUES ('131002', '13', '10', '02', 'ANGASMARCA');
INSERT INTO ubigeo VALUES ('131003', '13', '10', '03', 'CACHICADAN');
INSERT INTO ubigeo VALUES ('131004', '13', '10', '04', 'MOLLEBAMBA');
INSERT INTO ubigeo VALUES ('131005', '13', '10', '05', 'MOLLEPATA');
INSERT INTO ubigeo VALUES ('131006', '13', '10', '06', 'QUIRUVILCA');
INSERT INTO ubigeo VALUES ('131007', '13', '10', '07', 'SANTA CRUZ DE CHUCA');
INSERT INTO ubigeo VALUES ('131008', '13', '10', '08', 'SITABAMBA');
INSERT INTO ubigeo VALUES ('131100', '13', '11', '00', 'GRAN CHIMU');
INSERT INTO ubigeo VALUES ('131101', '13', '11', '01', 'CASCAS');
INSERT INTO ubigeo VALUES ('131102', '13', '11', '02', 'LUCMA');
INSERT INTO ubigeo VALUES ('131103', '13', '11', '03', 'MARMOT');
INSERT INTO ubigeo VALUES ('131104', '13', '11', '04', 'SAYAPULLO');
INSERT INTO ubigeo VALUES ('131200', '13', '12', '00', 'VIRU');
INSERT INTO ubigeo VALUES ('131201', '13', '12', '01', 'VIRU');
INSERT INTO ubigeo VALUES ('131202', '13', '12', '02', 'CHAO');
INSERT INTO ubigeo VALUES ('131203', '13', '12', '03', 'GUADALUPITO');
INSERT INTO ubigeo VALUES ('140000', '14', '00', '00', 'LAMBAYEQUE');
INSERT INTO ubigeo VALUES ('140100', '14', '01', '00', 'CHICLAYO');
INSERT INTO ubigeo VALUES ('140101', '14', '01', '01', 'CHICLAYO');
INSERT INTO ubigeo VALUES ('140102', '14', '01', '02', 'CHONGOYAPE');
INSERT INTO ubigeo VALUES ('140103', '14', '01', '03', 'ETEN');
INSERT INTO ubigeo VALUES ('140104', '14', '01', '04', 'ETEN PUERTO');
INSERT INTO ubigeo VALUES ('140105', '14', '01', '05', 'JOSE LEONARDO ORTIZ');
INSERT INTO ubigeo VALUES ('140106', '14', '01', '06', 'LA VICTORIA');
INSERT INTO ubigeo VALUES ('140107', '14', '01', '07', 'LAGUNAS');
INSERT INTO ubigeo VALUES ('140108', '14', '01', '08', 'MONSEFU');
INSERT INTO ubigeo VALUES ('140109', '14', '01', '09', 'NUEVA ARICA');
INSERT INTO ubigeo VALUES ('140110', '14', '01', '10', 'OYOTUN');
INSERT INTO ubigeo VALUES ('140111', '14', '01', '11', 'PICSI');
INSERT INTO ubigeo VALUES ('140112', '14', '01', '12', 'PIMENTEL');
INSERT INTO ubigeo VALUES ('140113', '14', '01', '13', 'REQUE');
INSERT INTO ubigeo VALUES ('140114', '14', '01', '14', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('140115', '14', '01', '15', 'SAÑA');
INSERT INTO ubigeo VALUES ('140116', '14', '01', '16', 'CAYALTI');
INSERT INTO ubigeo VALUES ('140117', '14', '01', '17', 'PATAPO');
INSERT INTO ubigeo VALUES ('140118', '14', '01', '18', 'POMALCA');
INSERT INTO ubigeo VALUES ('140119', '14', '01', '19', 'PUCALA');
INSERT INTO ubigeo VALUES ('140120', '14', '01', '20', 'TUMAN');
INSERT INTO ubigeo VALUES ('140200', '14', '02', '00', 'FERREÑAFE');
INSERT INTO ubigeo VALUES ('140201', '14', '02', '01', 'FERREÑAFE');
INSERT INTO ubigeo VALUES ('140202', '14', '02', '02', 'CAÑARIS');
INSERT INTO ubigeo VALUES ('140203', '14', '02', '03', 'INCAHUASI');
INSERT INTO ubigeo VALUES ('140204', '14', '02', '04', 'MANUEL ANTONIO MESONES MURO');
INSERT INTO ubigeo VALUES ('140205', '14', '02', '05', 'PITIPO');
INSERT INTO ubigeo VALUES ('140206', '14', '02', '06', 'PUEBLO NUEVO');
INSERT INTO ubigeo VALUES ('140300', '14', '03', '00', 'LAMBAYEQUE');
INSERT INTO ubigeo VALUES ('140301', '14', '03', '01', 'LAMBAYEQUE');
INSERT INTO ubigeo VALUES ('140302', '14', '03', '02', 'CHOCHOPE');
INSERT INTO ubigeo VALUES ('140303', '14', '03', '03', 'ILLIMO');
INSERT INTO ubigeo VALUES ('140304', '14', '03', '04', 'JAYANCA');
INSERT INTO ubigeo VALUES ('140305', '14', '03', '05', 'MOCHUMI');
INSERT INTO ubigeo VALUES ('140306', '14', '03', '06', 'MORROPE');
INSERT INTO ubigeo VALUES ('140307', '14', '03', '07', 'MOTUPE');
INSERT INTO ubigeo VALUES ('140308', '14', '03', '08', 'OLMOS');
INSERT INTO ubigeo VALUES ('140309', '14', '03', '09', 'PACORA');
INSERT INTO ubigeo VALUES ('140310', '14', '03', '10', 'SALAS');
INSERT INTO ubigeo VALUES ('140311', '14', '03', '11', 'SAN JOSE');
INSERT INTO ubigeo VALUES ('140312', '14', '03', '12', 'TUCUME');
INSERT INTO ubigeo VALUES ('150000', '15', '00', '00', 'LIMA');
INSERT INTO ubigeo VALUES ('150100', '15', '01', '00', 'LIMA');
INSERT INTO ubigeo VALUES ('150101', '15', '01', '01', 'LIMA');
INSERT INTO ubigeo VALUES ('150102', '15', '01', '02', 'ANCON');
INSERT INTO ubigeo VALUES ('150103', '15', '01', '03', 'ATE');
INSERT INTO ubigeo VALUES ('150104', '15', '01', '04', 'BARRANCO');
INSERT INTO ubigeo VALUES ('150105', '15', '01', '05', 'BREÑA');
INSERT INTO ubigeo VALUES ('150106', '15', '01', '06', 'CARABAYLLO');
INSERT INTO ubigeo VALUES ('150107', '15', '01', '07', 'CHACLACAYO');
INSERT INTO ubigeo VALUES ('150108', '15', '01', '08', 'CHORRILLOS');
INSERT INTO ubigeo VALUES ('150109', '15', '01', '09', 'CIENEGUILLA');
INSERT INTO ubigeo VALUES ('150110', '15', '01', '10', 'COMAS');
INSERT INTO ubigeo VALUES ('150111', '15', '01', '11', 'EL AGUSTINO');
INSERT INTO ubigeo VALUES ('150112', '15', '01', '12', 'INDEPENDENCIA');
INSERT INTO ubigeo VALUES ('150113', '15', '01', '13', 'JESUS MARIA');
INSERT INTO ubigeo VALUES ('150114', '15', '01', '14', 'LA MOLINA');
INSERT INTO ubigeo VALUES ('150115', '15', '01', '15', 'LA VICTORIA');
INSERT INTO ubigeo VALUES ('150116', '15', '01', '16', 'LINCE');
INSERT INTO ubigeo VALUES ('150117', '15', '01', '17', 'LOS OLIVOS');
INSERT INTO ubigeo VALUES ('150118', '15', '01', '18', 'LURIGANCHO');
INSERT INTO ubigeo VALUES ('150119', '15', '01', '19', 'LURIN');
INSERT INTO ubigeo VALUES ('150120', '15', '01', '20', 'MAGDALENA DEL MAR');
INSERT INTO ubigeo VALUES ('150121', '15', '01', '21', 'PUEBLO LIBRE');
INSERT INTO ubigeo VALUES ('150122', '15', '01', '22', 'MIRAFLORES');
INSERT INTO ubigeo VALUES ('150123', '15', '01', '23', 'PACHACAMAC');
INSERT INTO ubigeo VALUES ('150124', '15', '01', '24', 'PUCUSANA');
INSERT INTO ubigeo VALUES ('150125', '15', '01', '25', 'PUENTE PIEDRA');
INSERT INTO ubigeo VALUES ('150126', '15', '01', '26', 'PUNTA HERMOSA');
INSERT INTO ubigeo VALUES ('150127', '15', '01', '27', 'PUNTA NEGRA');
INSERT INTO ubigeo VALUES ('150128', '15', '01', '28', 'RIMAC');
INSERT INTO ubigeo VALUES ('150129', '15', '01', '29', 'SAN BARTOLO');
INSERT INTO ubigeo VALUES ('150130', '15', '01', '30', 'SAN BORJA');
INSERT INTO ubigeo VALUES ('150131', '15', '01', '31', 'SAN ISIDRO');
INSERT INTO ubigeo VALUES ('150132', '15', '01', '32', 'SAN JUAN DE LURIGANCHO');
INSERT INTO ubigeo VALUES ('150133', '15', '01', '33', 'SAN JUAN DE MIRAFLORES');
INSERT INTO ubigeo VALUES ('150134', '15', '01', '34', 'SAN LUIS');
INSERT INTO ubigeo VALUES ('150135', '15', '01', '35', 'SAN MARTIN DE PORRES');
INSERT INTO ubigeo VALUES ('150136', '15', '01', '36', 'SAN MIGUEL');
INSERT INTO ubigeo VALUES ('150137', '15', '01', '37', 'SANTA ANITA');
INSERT INTO ubigeo VALUES ('150138', '15', '01', '38', 'SANTA MARIA DEL MAR');
INSERT INTO ubigeo VALUES ('150139', '15', '01', '39', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('150140', '15', '01', '40', 'SANTIAGO DE SURCO');
INSERT INTO ubigeo VALUES ('150141', '15', '01', '41', 'SURQUILLO');
INSERT INTO ubigeo VALUES ('150142', '15', '01', '42', 'VILLA EL SALVADOR');
INSERT INTO ubigeo VALUES ('150143', '15', '01', '43', 'VILLA MARIA DEL TRIUNFO');
INSERT INTO ubigeo VALUES ('150200', '15', '02', '00', 'BARRANCA');
INSERT INTO ubigeo VALUES ('150201', '15', '02', '01', 'BARRANCA');
INSERT INTO ubigeo VALUES ('150202', '15', '02', '02', 'PARAMONGA');
INSERT INTO ubigeo VALUES ('150203', '15', '02', '03', 'PATIVILCA');
INSERT INTO ubigeo VALUES ('150204', '15', '02', '04', 'SUPE');
INSERT INTO ubigeo VALUES ('150205', '15', '02', '05', 'SUPE PUERTO');
INSERT INTO ubigeo VALUES ('150300', '15', '03', '00', 'CAJATAMBO');
INSERT INTO ubigeo VALUES ('150301', '15', '03', '01', 'CAJATAMBO');
INSERT INTO ubigeo VALUES ('150302', '15', '03', '02', 'COPA');
INSERT INTO ubigeo VALUES ('150303', '15', '03', '03', 'GORGOR');
INSERT INTO ubigeo VALUES ('150304', '15', '03', '04', 'HUANCAPON');
INSERT INTO ubigeo VALUES ('150305', '15', '03', '05', 'MANAS');
INSERT INTO ubigeo VALUES ('150400', '15', '04', '00', 'CANTA');
INSERT INTO ubigeo VALUES ('150401', '15', '04', '01', 'CANTA');
INSERT INTO ubigeo VALUES ('150402', '15', '04', '02', 'ARAHUAY');
INSERT INTO ubigeo VALUES ('150403', '15', '04', '03', 'HUAMANTANGA');
INSERT INTO ubigeo VALUES ('150404', '15', '04', '04', 'HUAROS');
INSERT INTO ubigeo VALUES ('150405', '15', '04', '05', 'LACHAQUI');
INSERT INTO ubigeo VALUES ('150406', '15', '04', '06', 'SAN BUENAVENTURA');
INSERT INTO ubigeo VALUES ('150407', '15', '04', '07', 'SANTA ROSA DE QUIVES');
INSERT INTO ubigeo VALUES ('150500', '15', '05', '00', 'CAÑETE');
INSERT INTO ubigeo VALUES ('150501', '15', '05', '01', 'SAN VICENTE DE CAÑETE');
INSERT INTO ubigeo VALUES ('150502', '15', '05', '02', 'ASIA');
INSERT INTO ubigeo VALUES ('150503', '15', '05', '03', 'CALANGO');
INSERT INTO ubigeo VALUES ('150504', '15', '05', '04', 'CERRO AZUL');
INSERT INTO ubigeo VALUES ('150505', '15', '05', '05', 'CHILCA');
INSERT INTO ubigeo VALUES ('150506', '15', '05', '06', 'COAYLLO');
INSERT INTO ubigeo VALUES ('150507', '15', '05', '07', 'IMPERIAL');
INSERT INTO ubigeo VALUES ('150508', '15', '05', '08', 'LUNAHUANA');
INSERT INTO ubigeo VALUES ('150509', '15', '05', '09', 'MALA');
INSERT INTO ubigeo VALUES ('150510', '15', '05', '10', 'NUEVO IMPERIAL');
INSERT INTO ubigeo VALUES ('150511', '15', '05', '11', 'PACARAN');
INSERT INTO ubigeo VALUES ('150512', '15', '05', '12', 'QUILMANA');
INSERT INTO ubigeo VALUES ('150513', '15', '05', '13', 'SAN ANTONIO');
INSERT INTO ubigeo VALUES ('150514', '15', '05', '14', 'SAN LUIS');
INSERT INTO ubigeo VALUES ('150515', '15', '05', '15', 'SANTA CRUZ DE FLORES');
INSERT INTO ubigeo VALUES ('150516', '15', '05', '16', 'ZUÑIGA');
INSERT INTO ubigeo VALUES ('150600', '15', '06', '00', 'HUARAL');
INSERT INTO ubigeo VALUES ('150601', '15', '06', '01', 'HUARAL');
INSERT INTO ubigeo VALUES ('150602', '15', '06', '02', 'ATAVILLOS ALTO');
INSERT INTO ubigeo VALUES ('150603', '15', '06', '03', 'ATAVILLOS BAJO');
INSERT INTO ubigeo VALUES ('150604', '15', '06', '04', 'AUCALLAMA');
INSERT INTO ubigeo VALUES ('150605', '15', '06', '05', 'CHANCAY');
INSERT INTO ubigeo VALUES ('150606', '15', '06', '06', 'IHUARI');
INSERT INTO ubigeo VALUES ('150607', '15', '06', '07', 'LAMPIAN');
INSERT INTO ubigeo VALUES ('150608', '15', '06', '08', 'PACARAOS');
INSERT INTO ubigeo VALUES ('150609', '15', '06', '09', 'SAN MIGUEL DE ACOS');
INSERT INTO ubigeo VALUES ('150610', '15', '06', '10', 'SANTA CRUZ DE ANDAMARCA');
INSERT INTO ubigeo VALUES ('150611', '15', '06', '11', 'SUMBILCA');
INSERT INTO ubigeo VALUES ('150612', '15', '06', '12', 'VEINTISIETE DE NOVIEMBRE');
INSERT INTO ubigeo VALUES ('150700', '15', '07', '00', 'HUAROCHIRI');
INSERT INTO ubigeo VALUES ('150701', '15', '07', '01', 'MATUCANA');
INSERT INTO ubigeo VALUES ('150702', '15', '07', '02', 'ANTIOQUIA');
INSERT INTO ubigeo VALUES ('150703', '15', '07', '03', 'CALLAHUANCA');
INSERT INTO ubigeo VALUES ('150704', '15', '07', '04', 'CARAMPOMA');
INSERT INTO ubigeo VALUES ('150705', '15', '07', '05', 'CHICLA');
INSERT INTO ubigeo VALUES ('150706', '15', '07', '06', 'CUENCA');
INSERT INTO ubigeo VALUES ('150707', '15', '07', '07', 'HUACHUPAMPA');
INSERT INTO ubigeo VALUES ('150708', '15', '07', '08', 'HUANZA');
INSERT INTO ubigeo VALUES ('150709', '15', '07', '09', 'HUAROCHIRI');
INSERT INTO ubigeo VALUES ('150710', '15', '07', '10', 'LAHUAYTAMBO');
INSERT INTO ubigeo VALUES ('150711', '15', '07', '11', 'LANGA');
INSERT INTO ubigeo VALUES ('150712', '15', '07', '12', 'LARAOS');
INSERT INTO ubigeo VALUES ('150713', '15', '07', '13', 'MARIATANA');
INSERT INTO ubigeo VALUES ('150714', '15', '07', '14', 'RICARDO PALMA');
INSERT INTO ubigeo VALUES ('150715', '15', '07', '15', 'SAN ANDRES DE TUPICOCHA');
INSERT INTO ubigeo VALUES ('150716', '15', '07', '16', 'SAN ANTONIO');
INSERT INTO ubigeo VALUES ('150717', '15', '07', '17', 'SAN BARTOLOME');
INSERT INTO ubigeo VALUES ('150718', '15', '07', '18', 'SAN DAMIAN');
INSERT INTO ubigeo VALUES ('150719', '15', '07', '19', 'SAN JUAN DE IRIS');
INSERT INTO ubigeo VALUES ('150720', '15', '07', '20', 'SAN JUAN DE TANTARANCHE');
INSERT INTO ubigeo VALUES ('150721', '15', '07', '21', 'SAN LORENZO DE QUINTI');
INSERT INTO ubigeo VALUES ('150722', '15', '07', '22', 'SAN MATEO');
INSERT INTO ubigeo VALUES ('150723', '15', '07', '23', 'SAN MATEO DE OTAO');
INSERT INTO ubigeo VALUES ('150724', '15', '07', '24', 'SAN PEDRO DE CASTA');
INSERT INTO ubigeo VALUES ('150725', '15', '07', '25', 'SAN PEDRO DE HUANCAYRE');
INSERT INTO ubigeo VALUES ('150726', '15', '07', '26', 'SANGALLAYA');
INSERT INTO ubigeo VALUES ('150727', '15', '07', '27', 'SANTA CRUZ DE COCACHACRA');
INSERT INTO ubigeo VALUES ('150728', '15', '07', '28', 'SANTA EULALIA');
INSERT INTO ubigeo VALUES ('150729', '15', '07', '29', 'SANTIAGO DE ANCHUCAYA');
INSERT INTO ubigeo VALUES ('150730', '15', '07', '30', 'SANTIAGO DE TUNA');
INSERT INTO ubigeo VALUES ('150731', '15', '07', '31', 'SANTO DOMINGO DE LOS OLLEROS');
INSERT INTO ubigeo VALUES ('150732', '15', '07', '32', 'SURCO');
INSERT INTO ubigeo VALUES ('150800', '15', '08', '00', 'HUAURA');
INSERT INTO ubigeo VALUES ('150801', '15', '08', '01', 'HUACHO');
INSERT INTO ubigeo VALUES ('150802', '15', '08', '02', 'AMBAR');
INSERT INTO ubigeo VALUES ('150803', '15', '08', '03', 'CALETA DE CARQUIN');
INSERT INTO ubigeo VALUES ('150804', '15', '08', '04', 'CHECRAS');
INSERT INTO ubigeo VALUES ('150805', '15', '08', '05', 'HUALMAY');
INSERT INTO ubigeo VALUES ('150806', '15', '08', '06', 'HUAURA');
INSERT INTO ubigeo VALUES ('150807', '15', '08', '07', 'LEONCIO PRADO');
INSERT INTO ubigeo VALUES ('150808', '15', '08', '08', 'PACCHO');
INSERT INTO ubigeo VALUES ('150809', '15', '08', '09', 'SANTA LEONOR');
INSERT INTO ubigeo VALUES ('150810', '15', '08', '10', 'SANTA MARIA');
INSERT INTO ubigeo VALUES ('150811', '15', '08', '11', 'SAYAN');
INSERT INTO ubigeo VALUES ('150812', '15', '08', '12', 'VEGUETA');
INSERT INTO ubigeo VALUES ('150900', '15', '09', '00', 'OYON');
INSERT INTO ubigeo VALUES ('150901', '15', '09', '01', 'OYON');
INSERT INTO ubigeo VALUES ('150902', '15', '09', '02', 'ANDAJES');
INSERT INTO ubigeo VALUES ('150903', '15', '09', '03', 'CAUJUL');
INSERT INTO ubigeo VALUES ('150904', '15', '09', '04', 'COCHAMARCA');
INSERT INTO ubigeo VALUES ('150905', '15', '09', '05', 'NAVAN');
INSERT INTO ubigeo VALUES ('150906', '15', '09', '06', 'PACHANGARA');
INSERT INTO ubigeo VALUES ('151000', '15', '10', '00', 'YAUYOS');
INSERT INTO ubigeo VALUES ('151001', '15', '10', '01', 'YAUYOS');
INSERT INTO ubigeo VALUES ('151002', '15', '10', '02', 'ALIS');
INSERT INTO ubigeo VALUES ('151003', '15', '10', '03', 'ALLAUCA');
INSERT INTO ubigeo VALUES ('151004', '15', '10', '04', 'AYAVIRI');
INSERT INTO ubigeo VALUES ('151005', '15', '10', '05', 'AZANGARO');
INSERT INTO ubigeo VALUES ('151006', '15', '10', '06', 'CACRA');
INSERT INTO ubigeo VALUES ('151007', '15', '10', '07', 'CARANIA');
INSERT INTO ubigeo VALUES ('151008', '15', '10', '08', 'CATAHUASI');
INSERT INTO ubigeo VALUES ('151009', '15', '10', '09', 'CHOCOS');
INSERT INTO ubigeo VALUES ('151010', '15', '10', '10', 'COCHAS');
INSERT INTO ubigeo VALUES ('151011', '15', '10', '11', 'COLONIA');
INSERT INTO ubigeo VALUES ('151012', '15', '10', '12', 'HONGOS');
INSERT INTO ubigeo VALUES ('151013', '15', '10', '13', 'HUAMPARA');
INSERT INTO ubigeo VALUES ('151014', '15', '10', '14', 'HUANCAYA');
INSERT INTO ubigeo VALUES ('151015', '15', '10', '15', 'HUANGASCAR');
INSERT INTO ubigeo VALUES ('151016', '15', '10', '16', 'HUANTAN');
INSERT INTO ubigeo VALUES ('151017', '15', '10', '17', 'HUAÑEC');
INSERT INTO ubigeo VALUES ('151018', '15', '10', '18', 'LARAOS');
INSERT INTO ubigeo VALUES ('151019', '15', '10', '19', 'LINCHA');
INSERT INTO ubigeo VALUES ('151020', '15', '10', '20', 'MADEAN');
INSERT INTO ubigeo VALUES ('151021', '15', '10', '21', 'MIRAFLORES');
INSERT INTO ubigeo VALUES ('151022', '15', '10', '22', 'OMAS');
INSERT INTO ubigeo VALUES ('151023', '15', '10', '23', 'PUTINZA');
INSERT INTO ubigeo VALUES ('151024', '15', '10', '24', 'QUINCHES');
INSERT INTO ubigeo VALUES ('151025', '15', '10', '25', 'QUINOCAY');
INSERT INTO ubigeo VALUES ('151026', '15', '10', '26', 'SAN JOAQUIN');
INSERT INTO ubigeo VALUES ('151027', '15', '10', '27', 'SAN PEDRO DE PILAS');
INSERT INTO ubigeo VALUES ('151028', '15', '10', '28', 'TANTA');
INSERT INTO ubigeo VALUES ('151029', '15', '10', '29', 'TAURIPAMPA');
INSERT INTO ubigeo VALUES ('151030', '15', '10', '30', 'TOMAS');
INSERT INTO ubigeo VALUES ('151031', '15', '10', '31', 'TUPE');
INSERT INTO ubigeo VALUES ('151032', '15', '10', '32', 'VIÑAC');
INSERT INTO ubigeo VALUES ('151033', '15', '10', '33', 'VITIS');
INSERT INTO ubigeo VALUES ('160000', '16', '00', '00', 'LORETO');
INSERT INTO ubigeo VALUES ('160100', '16', '01', '00', 'MAYNAS');
INSERT INTO ubigeo VALUES ('160101', '16', '01', '01', 'IQUITOS');
INSERT INTO ubigeo VALUES ('160102', '16', '01', '02', 'ALTO NANAY');
INSERT INTO ubigeo VALUES ('160103', '16', '01', '03', 'FERNANDO LORES');
INSERT INTO ubigeo VALUES ('160104', '16', '01', '04', 'INDIANA');
INSERT INTO ubigeo VALUES ('160105', '16', '01', '05', 'LAS AMAZONAS');
INSERT INTO ubigeo VALUES ('160106', '16', '01', '06', 'MAZAN');
INSERT INTO ubigeo VALUES ('160107', '16', '01', '07', 'NAPO');
INSERT INTO ubigeo VALUES ('160108', '16', '01', '08', 'PUNCHANA');
INSERT INTO ubigeo VALUES ('160109', '16', '01', '09', 'PUTUMAYO');
INSERT INTO ubigeo VALUES ('160110', '16', '01', '10', 'TORRES CAUSANA');
INSERT INTO ubigeo VALUES ('160112', '16', '01', '12', 'BELEN');
INSERT INTO ubigeo VALUES ('160113', '16', '01', '13', 'SAN JUAN BAUTISTA');
INSERT INTO ubigeo VALUES ('160114', '16', '01', '14', 'TENIENTE MANUEL CLAVERO');
INSERT INTO ubigeo VALUES ('160200', '16', '02', '00', 'ALTO AMAZONAS');
INSERT INTO ubigeo VALUES ('160201', '16', '02', '01', 'YURIMAGUAS');
INSERT INTO ubigeo VALUES ('160202', '16', '02', '02', 'BALSAPUERTO');
INSERT INTO ubigeo VALUES ('160205', '16', '02', '05', 'JEBEROS');
INSERT INTO ubigeo VALUES ('160206', '16', '02', '06', 'LAGUNAS');
INSERT INTO ubigeo VALUES ('160210', '16', '02', '10', 'SANTA CRUZ');
INSERT INTO ubigeo VALUES ('160211', '16', '02', '11', 'TENIENTE CESAR LOPEZ ROJAS');
INSERT INTO ubigeo VALUES ('160300', '16', '03', '00', 'LORETO');
INSERT INTO ubigeo VALUES ('160301', '16', '03', '01', 'NAUTA');
INSERT INTO ubigeo VALUES ('160302', '16', '03', '02', 'PARINARI');
INSERT INTO ubigeo VALUES ('160303', '16', '03', '03', 'TIGRE');
INSERT INTO ubigeo VALUES ('160304', '16', '03', '04', 'TROMPETEROS');
INSERT INTO ubigeo VALUES ('160305', '16', '03', '05', 'URARINAS');
INSERT INTO ubigeo VALUES ('160400', '16', '04', '00', 'MARISCAL RAMON CASTILLA');
INSERT INTO ubigeo VALUES ('160401', '16', '04', '01', 'RAMON CASTILLA');
INSERT INTO ubigeo VALUES ('160402', '16', '04', '02', 'PEBAS');
INSERT INTO ubigeo VALUES ('160403', '16', '04', '03', 'YAVARI');
INSERT INTO ubigeo VALUES ('160404', '16', '04', '04', 'SAN PABLO');
INSERT INTO ubigeo VALUES ('160500', '16', '05', '00', 'REQUENA');
INSERT INTO ubigeo VALUES ('160501', '16', '05', '01', 'REQUENA');
INSERT INTO ubigeo VALUES ('160502', '16', '05', '02', 'ALTO TAPICHE');
INSERT INTO ubigeo VALUES ('160503', '16', '05', '03', 'CAPELO');
INSERT INTO ubigeo VALUES ('160504', '16', '05', '04', 'EMILIO SAN MARTIN');
INSERT INTO ubigeo VALUES ('160505', '16', '05', '05', 'MAQUIA');
INSERT INTO ubigeo VALUES ('160506', '16', '05', '06', 'PUINAHUA');
INSERT INTO ubigeo VALUES ('160507', '16', '05', '07', 'SAQUENA');
INSERT INTO ubigeo VALUES ('160508', '16', '05', '08', 'SOPLIN');
INSERT INTO ubigeo VALUES ('160509', '16', '05', '09', 'TAPICHE');
INSERT INTO ubigeo VALUES ('160510', '16', '05', '10', 'JENARO HERRERA');
INSERT INTO ubigeo VALUES ('160511', '16', '05', '11', 'YAQUERANA');
INSERT INTO ubigeo VALUES ('160600', '16', '06', '00', 'UCAYALI');
INSERT INTO ubigeo VALUES ('160601', '16', '06', '01', 'CONTAMANA');
INSERT INTO ubigeo VALUES ('160602', '16', '06', '02', 'INAHUAYA');
INSERT INTO ubigeo VALUES ('160603', '16', '06', '03', 'PADRE MARQUEZ');
INSERT INTO ubigeo VALUES ('160604', '16', '06', '04', 'PAMPA HERMOSA');
INSERT INTO ubigeo VALUES ('160605', '16', '06', '05', 'SARAYACU');
INSERT INTO ubigeo VALUES ('160606', '16', '06', '06', 'VARGAS GUERRA');
INSERT INTO ubigeo VALUES ('160700', '16', '07', '00', 'DATEM DEL MARAÑON');
INSERT INTO ubigeo VALUES ('160701', '16', '07', '01', 'BARRANCA');
INSERT INTO ubigeo VALUES ('160702', '16', '07', '02', 'CAHUAPANAS');
INSERT INTO ubigeo VALUES ('160703', '16', '07', '03', 'MANSERICHE');
INSERT INTO ubigeo VALUES ('160704', '16', '07', '04', 'MORONA');
INSERT INTO ubigeo VALUES ('160705', '16', '07', '05', 'PASTAZA');
INSERT INTO ubigeo VALUES ('160706', '16', '07', '06', 'ANDOAS');
INSERT INTO ubigeo VALUES ('170000', '17', '00', '00', 'MADRE DE DIOS');
INSERT INTO ubigeo VALUES ('170100', '17', '01', '00', 'TAMBOPATA');
INSERT INTO ubigeo VALUES ('170101', '17', '01', '01', 'TAMBOPATA');
INSERT INTO ubigeo VALUES ('170102', '17', '01', '02', 'INAMBARI');
INSERT INTO ubigeo VALUES ('170103', '17', '01', '03', 'LAS PIEDRAS');
INSERT INTO ubigeo VALUES ('170104', '17', '01', '04', 'LABERINTO');
INSERT INTO ubigeo VALUES ('170200', '17', '02', '00', 'MANU');
INSERT INTO ubigeo VALUES ('170201', '17', '02', '01', 'MANU');
INSERT INTO ubigeo VALUES ('170202', '17', '02', '02', 'FITZCARRALD');
INSERT INTO ubigeo VALUES ('170203', '17', '02', '03', 'MADRE DE DIOS');
INSERT INTO ubigeo VALUES ('170204', '17', '02', '04', 'HUEPETUHE');
INSERT INTO ubigeo VALUES ('170300', '17', '03', '00', 'TAHUAMANU');
INSERT INTO ubigeo VALUES ('170301', '17', '03', '01', 'IÑAPARI');
INSERT INTO ubigeo VALUES ('170302', '17', '03', '02', 'IBERIA');
INSERT INTO ubigeo VALUES ('170303', '17', '03', '03', 'TAHUAMANU');
INSERT INTO ubigeo VALUES ('180000', '18', '00', '00', 'MOQUEGUA');
INSERT INTO ubigeo VALUES ('180100', '18', '01', '00', 'MARISCAL NIETO');
INSERT INTO ubigeo VALUES ('180101', '18', '01', '01', 'MOQUEGUA');
INSERT INTO ubigeo VALUES ('180102', '18', '01', '02', 'CARUMAS');
INSERT INTO ubigeo VALUES ('180103', '18', '01', '03', 'CUCHUMBAYA');
INSERT INTO ubigeo VALUES ('180104', '18', '01', '04', 'SAMEGUA');
INSERT INTO ubigeo VALUES ('180105', '18', '01', '05', 'SAN CRISTOBAL');
INSERT INTO ubigeo VALUES ('180106', '18', '01', '06', 'TORATA');
INSERT INTO ubigeo VALUES ('180200', '18', '02', '00', 'GENERAL SANCHEZ CERRO');
INSERT INTO ubigeo VALUES ('180201', '18', '02', '01', 'OMATE');
INSERT INTO ubigeo VALUES ('180202', '18', '02', '02', 'CHOJATA');
INSERT INTO ubigeo VALUES ('180203', '18', '02', '03', 'COALAQUE');
INSERT INTO ubigeo VALUES ('180204', '18', '02', '04', 'ICHUÑA');
INSERT INTO ubigeo VALUES ('180205', '18', '02', '05', 'LA CAPILLA');
INSERT INTO ubigeo VALUES ('180206', '18', '02', '06', 'LLOQUE');
INSERT INTO ubigeo VALUES ('180207', '18', '02', '07', 'MATALAQUE');
INSERT INTO ubigeo VALUES ('180208', '18', '02', '08', 'PUQUINA');
INSERT INTO ubigeo VALUES ('180209', '18', '02', '09', 'QUINISTAQUILLAS');
INSERT INTO ubigeo VALUES ('180210', '18', '02', '10', 'UBINAS');
INSERT INTO ubigeo VALUES ('180211', '18', '02', '11', 'YUNGA');
INSERT INTO ubigeo VALUES ('180300', '18', '03', '00', 'ILO');
INSERT INTO ubigeo VALUES ('180301', '18', '03', '01', 'ILO');
INSERT INTO ubigeo VALUES ('180302', '18', '03', '02', 'EL ALGARROBAL');
INSERT INTO ubigeo VALUES ('180303', '18', '03', '03', 'PACOCHA');
INSERT INTO ubigeo VALUES ('190000', '19', '00', '00', 'PASCO');
INSERT INTO ubigeo VALUES ('190100', '19', '01', '00', 'PASCO');
INSERT INTO ubigeo VALUES ('190101', '19', '01', '01', 'CHAUPIMARCA');
INSERT INTO ubigeo VALUES ('190102', '19', '01', '02', 'HUACHON');
INSERT INTO ubigeo VALUES ('190103', '19', '01', '03', 'HUARIACA');
INSERT INTO ubigeo VALUES ('190104', '19', '01', '04', 'HUAYLLAY');
INSERT INTO ubigeo VALUES ('190105', '19', '01', '05', 'NINACACA');
INSERT INTO ubigeo VALUES ('190106', '19', '01', '06', 'PALLANCHACRA');
INSERT INTO ubigeo VALUES ('190107', '19', '01', '07', 'PAUCARTAMBO');
INSERT INTO ubigeo VALUES ('190108', '19', '01', '08', 'SAN FRANCISCO DE ASIS DE YARUSYACAN');
INSERT INTO ubigeo VALUES ('190109', '19', '01', '09', 'SIMON BOLIVAR');
INSERT INTO ubigeo VALUES ('190110', '19', '01', '10', 'TICLACAYAN');
INSERT INTO ubigeo VALUES ('190111', '19', '01', '11', 'TINYAHUARCO');
INSERT INTO ubigeo VALUES ('190112', '19', '01', '12', 'VICCO');
INSERT INTO ubigeo VALUES ('190113', '19', '01', '13', 'YANACANCHA');
INSERT INTO ubigeo VALUES ('190200', '19', '02', '00', 'DANIEL ALCIDES CARRION');
INSERT INTO ubigeo VALUES ('190201', '19', '02', '01', 'YANAHUANCA');
INSERT INTO ubigeo VALUES ('190202', '19', '02', '02', 'CHACAYAN');
INSERT INTO ubigeo VALUES ('190203', '19', '02', '03', 'GOYLLARISQUIZGA');
INSERT INTO ubigeo VALUES ('190204', '19', '02', '04', 'PAUCAR');
INSERT INTO ubigeo VALUES ('190205', '19', '02', '05', 'SAN PEDRO DE PILLAO');
INSERT INTO ubigeo VALUES ('190206', '19', '02', '06', 'SANTA ANA DE TUSI');
INSERT INTO ubigeo VALUES ('190207', '19', '02', '07', 'TAPUC');
INSERT INTO ubigeo VALUES ('190208', '19', '02', '08', 'VILCABAMBA');
INSERT INTO ubigeo VALUES ('190300', '19', '03', '00', 'OXAPAMPA');
INSERT INTO ubigeo VALUES ('190301', '19', '03', '01', 'OXAPAMPA');
INSERT INTO ubigeo VALUES ('190302', '19', '03', '02', 'CHONTABAMBA');
INSERT INTO ubigeo VALUES ('190303', '19', '03', '03', 'HUANCABAMBA');
INSERT INTO ubigeo VALUES ('190304', '19', '03', '04', 'PALCAZU');
INSERT INTO ubigeo VALUES ('190305', '19', '03', '05', 'POZUZO');
INSERT INTO ubigeo VALUES ('190306', '19', '03', '06', 'PUERTO BERMUDEZ');
INSERT INTO ubigeo VALUES ('190307', '19', '03', '07', 'VILLA RICA');
INSERT INTO ubigeo VALUES ('190308', '19', '03', '08', 'CONSTITUCION');
INSERT INTO ubigeo VALUES ('200000', '20', '00', '00', 'PIURA');
INSERT INTO ubigeo VALUES ('200100', '20', '01', '00', 'PIURA');
INSERT INTO ubigeo VALUES ('200101', '20', '01', '01', 'PIURA');
INSERT INTO ubigeo VALUES ('200104', '20', '01', '04', 'CASTILLA');
INSERT INTO ubigeo VALUES ('200105', '20', '01', '05', 'CATACAOS');
INSERT INTO ubigeo VALUES ('200107', '20', '01', '07', 'CURA MORI');
INSERT INTO ubigeo VALUES ('200108', '20', '01', '08', 'EL TALLAN');
INSERT INTO ubigeo VALUES ('200109', '20', '01', '09', 'LA ARENA');
INSERT INTO ubigeo VALUES ('200110', '20', '01', '10', 'LA UNION');
INSERT INTO ubigeo VALUES ('200111', '20', '01', '11', 'LAS LOMAS');
INSERT INTO ubigeo VALUES ('200114', '20', '01', '14', 'TAMBO GRANDE');
INSERT INTO ubigeo VALUES ('200200', '20', '02', '00', 'AYABACA');
INSERT INTO ubigeo VALUES ('200201', '20', '02', '01', 'AYABACA');
INSERT INTO ubigeo VALUES ('200202', '20', '02', '02', 'FRIAS');
INSERT INTO ubigeo VALUES ('200203', '20', '02', '03', 'JILILI');
INSERT INTO ubigeo VALUES ('200204', '20', '02', '04', 'LAGUNAS');
INSERT INTO ubigeo VALUES ('200205', '20', '02', '05', 'MONTERO');
INSERT INTO ubigeo VALUES ('200206', '20', '02', '06', 'PACAIPAMPA');
INSERT INTO ubigeo VALUES ('200207', '20', '02', '07', 'PAIMAS');
INSERT INTO ubigeo VALUES ('200208', '20', '02', '08', 'SAPILLICA');
INSERT INTO ubigeo VALUES ('200209', '20', '02', '09', 'SICCHEZ');
INSERT INTO ubigeo VALUES ('200210', '20', '02', '10', 'SUYO');
INSERT INTO ubigeo VALUES ('200300', '20', '03', '00', 'HUANCABAMBA');
INSERT INTO ubigeo VALUES ('200301', '20', '03', '01', 'HUANCABAMBA');
INSERT INTO ubigeo VALUES ('200302', '20', '03', '02', 'CANCHAQUE');
INSERT INTO ubigeo VALUES ('200303', '20', '03', '03', 'EL CARMEN DE LA FRONTERA');
INSERT INTO ubigeo VALUES ('200304', '20', '03', '04', 'HUARMACA');
INSERT INTO ubigeo VALUES ('200305', '20', '03', '05', 'LALAQUIZ');
INSERT INTO ubigeo VALUES ('200306', '20', '03', '06', 'SAN MIGUEL DE EL FAIQUE');
INSERT INTO ubigeo VALUES ('200307', '20', '03', '07', 'SONDOR');
INSERT INTO ubigeo VALUES ('200308', '20', '03', '08', 'SONDORILLO');
INSERT INTO ubigeo VALUES ('200400', '20', '04', '00', 'MORROPON');
INSERT INTO ubigeo VALUES ('200401', '20', '04', '01', 'CHULUCANAS');
INSERT INTO ubigeo VALUES ('200402', '20', '04', '02', 'BUENOS AIRES');
INSERT INTO ubigeo VALUES ('200403', '20', '04', '03', 'CHALACO');
INSERT INTO ubigeo VALUES ('200404', '20', '04', '04', 'LA MATANZA');
INSERT INTO ubigeo VALUES ('200405', '20', '04', '05', 'MORROPON');
INSERT INTO ubigeo VALUES ('200406', '20', '04', '06', 'SALITRAL');
INSERT INTO ubigeo VALUES ('200407', '20', '04', '07', 'SAN JUAN DE BIGOTE');
INSERT INTO ubigeo VALUES ('200408', '20', '04', '08', 'SANTA CATALINA DE MOSSA');
INSERT INTO ubigeo VALUES ('200409', '20', '04', '09', 'SANTO DOMINGO');
INSERT INTO ubigeo VALUES ('200410', '20', '04', '10', 'YAMANGO');
INSERT INTO ubigeo VALUES ('200500', '20', '05', '00', 'PAITA');
INSERT INTO ubigeo VALUES ('200501', '20', '05', '01', 'PAITA');
INSERT INTO ubigeo VALUES ('200502', '20', '05', '02', 'AMOTAPE');
INSERT INTO ubigeo VALUES ('200503', '20', '05', '03', 'ARENAL');
INSERT INTO ubigeo VALUES ('200504', '20', '05', '04', 'COLAN');
INSERT INTO ubigeo VALUES ('200505', '20', '05', '05', 'LA HUACA');
INSERT INTO ubigeo VALUES ('200506', '20', '05', '06', 'TAMARINDO');
INSERT INTO ubigeo VALUES ('200507', '20', '05', '07', 'VICHAYAL');
INSERT INTO ubigeo VALUES ('200600', '20', '06', '00', 'SULLANA');
INSERT INTO ubigeo VALUES ('200601', '20', '06', '01', 'SULLANA');
INSERT INTO ubigeo VALUES ('200602', '20', '06', '02', 'BELLAVISTA');
INSERT INTO ubigeo VALUES ('200603', '20', '06', '03', 'IGNACIO ESCUDERO');
INSERT INTO ubigeo VALUES ('200604', '20', '06', '04', 'LANCONES');
INSERT INTO ubigeo VALUES ('200605', '20', '06', '05', 'MARCAVELICA');
INSERT INTO ubigeo VALUES ('200606', '20', '06', '06', 'MIGUEL CHECA');
INSERT INTO ubigeo VALUES ('200607', '20', '06', '07', 'QUERECOTILLO');
INSERT INTO ubigeo VALUES ('200608', '20', '06', '08', 'SALITRAL');
INSERT INTO ubigeo VALUES ('200700', '20', '07', '00', 'TALARA');
INSERT INTO ubigeo VALUES ('200701', '20', '07', '01', 'PARIÑAS');
INSERT INTO ubigeo VALUES ('200702', '20', '07', '02', 'EL ALTO');
INSERT INTO ubigeo VALUES ('200703', '20', '07', '03', 'LA BREA');
INSERT INTO ubigeo VALUES ('200704', '20', '07', '04', 'LOBITOS');
INSERT INTO ubigeo VALUES ('200705', '20', '07', '05', 'LOS ORGANOS');
INSERT INTO ubigeo VALUES ('200706', '20', '07', '06', 'MANCORA');
INSERT INTO ubigeo VALUES ('200800', '20', '08', '00', 'SECHURA');
INSERT INTO ubigeo VALUES ('200801', '20', '08', '01', 'SECHURA');
INSERT INTO ubigeo VALUES ('200802', '20', '08', '02', 'BELLAVISTA DE LA UNION');
INSERT INTO ubigeo VALUES ('200803', '20', '08', '03', 'BERNAL');
INSERT INTO ubigeo VALUES ('200804', '20', '08', '04', 'CRISTO NOS VALGA');
INSERT INTO ubigeo VALUES ('200805', '20', '08', '05', 'VICE');
INSERT INTO ubigeo VALUES ('200806', '20', '08', '06', 'RINCONADA LLICUAR');
INSERT INTO ubigeo VALUES ('210000', '21', '00', '00', 'PUNO');
INSERT INTO ubigeo VALUES ('210100', '21', '01', '00', 'PUNO');
INSERT INTO ubigeo VALUES ('210101', '21', '01', '01', 'PUNO');
INSERT INTO ubigeo VALUES ('210102', '21', '01', '02', 'ACORA');
INSERT INTO ubigeo VALUES ('210103', '21', '01', '03', 'AMANTANI');
INSERT INTO ubigeo VALUES ('210104', '21', '01', '04', 'ATUNCOLLA');
INSERT INTO ubigeo VALUES ('210105', '21', '01', '05', 'CAPACHICA');
INSERT INTO ubigeo VALUES ('210106', '21', '01', '06', 'CHUCUITO');
INSERT INTO ubigeo VALUES ('210107', '21', '01', '07', 'COATA');
INSERT INTO ubigeo VALUES ('210108', '21', '01', '08', 'HUATA');
INSERT INTO ubigeo VALUES ('210109', '21', '01', '09', 'MAÑAZO');
INSERT INTO ubigeo VALUES ('210110', '21', '01', '10', 'PAUCARCOLLA');
INSERT INTO ubigeo VALUES ('210111', '21', '01', '11', 'PICHACANI');
INSERT INTO ubigeo VALUES ('210112', '21', '01', '12', 'PLATERIA');
INSERT INTO ubigeo VALUES ('210113', '21', '01', '13', 'SAN ANTONIO');
INSERT INTO ubigeo VALUES ('210114', '21', '01', '14', 'TIQUILLACA');
INSERT INTO ubigeo VALUES ('210115', '21', '01', '15', 'VILQUE');
INSERT INTO ubigeo VALUES ('210200', '21', '02', '00', 'AZANGARO');
INSERT INTO ubigeo VALUES ('210201', '21', '02', '01', 'AZANGARO');
INSERT INTO ubigeo VALUES ('210202', '21', '02', '02', 'ACHAYA');
INSERT INTO ubigeo VALUES ('210203', '21', '02', '03', 'ARAPA');
INSERT INTO ubigeo VALUES ('210204', '21', '02', '04', 'ASILLO');
INSERT INTO ubigeo VALUES ('210205', '21', '02', '05', 'CAMINACA');
INSERT INTO ubigeo VALUES ('210206', '21', '02', '06', 'CHUPA');
INSERT INTO ubigeo VALUES ('210207', '21', '02', '07', 'JOSE DOMINGO CHOQUEHUANCA');
INSERT INTO ubigeo VALUES ('210208', '21', '02', '08', 'MUÑANI');
INSERT INTO ubigeo VALUES ('210209', '21', '02', '09', 'POTONI');
INSERT INTO ubigeo VALUES ('210210', '21', '02', '10', 'SAMAN');
INSERT INTO ubigeo VALUES ('210211', '21', '02', '11', 'SAN ANTON');
INSERT INTO ubigeo VALUES ('210212', '21', '02', '12', 'SAN JOSE');
INSERT INTO ubigeo VALUES ('210213', '21', '02', '13', 'SAN JUAN DE SALINAS');
INSERT INTO ubigeo VALUES ('210214', '21', '02', '14', 'SANTIAGO DE PUPUJA');
INSERT INTO ubigeo VALUES ('210215', '21', '02', '15', 'TIRAPATA');
INSERT INTO ubigeo VALUES ('210300', '21', '03', '00', 'CARABAYA');
INSERT INTO ubigeo VALUES ('210301', '21', '03', '01', 'MACUSANI');
INSERT INTO ubigeo VALUES ('210302', '21', '03', '02', 'AJOYANI');
INSERT INTO ubigeo VALUES ('210303', '21', '03', '03', 'AYAPATA');
INSERT INTO ubigeo VALUES ('210304', '21', '03', '04', 'COASA');
INSERT INTO ubigeo VALUES ('210305', '21', '03', '05', 'CORANI');
INSERT INTO ubigeo VALUES ('210306', '21', '03', '06', 'CRUCERO');
INSERT INTO ubigeo VALUES ('210307', '21', '03', '07', 'ITUATA');
INSERT INTO ubigeo VALUES ('210308', '21', '03', '08', 'OLLACHEA');
INSERT INTO ubigeo VALUES ('210309', '21', '03', '09', 'SAN GABAN');
INSERT INTO ubigeo VALUES ('210310', '21', '03', '10', 'USICAYOS');
INSERT INTO ubigeo VALUES ('210400', '21', '04', '00', 'CHUCUITO');
INSERT INTO ubigeo VALUES ('210401', '21', '04', '01', 'JULI');
INSERT INTO ubigeo VALUES ('210402', '21', '04', '02', 'DESAGUADERO');
INSERT INTO ubigeo VALUES ('210403', '21', '04', '03', 'HUACULLANI');
INSERT INTO ubigeo VALUES ('210404', '21', '04', '04', 'KELLUYO');
INSERT INTO ubigeo VALUES ('210405', '21', '04', '05', 'PISACOMA');
INSERT INTO ubigeo VALUES ('210406', '21', '04', '06', 'POMATA');
INSERT INTO ubigeo VALUES ('210407', '21', '04', '07', 'ZEPITA');
INSERT INTO ubigeo VALUES ('210500', '21', '05', '00', 'EL COLLAO');
INSERT INTO ubigeo VALUES ('210501', '21', '05', '01', 'ILAVE');
INSERT INTO ubigeo VALUES ('210502', '21', '05', '02', 'CAPAZO');
INSERT INTO ubigeo VALUES ('210503', '21', '05', '03', 'PILCUYO');
INSERT INTO ubigeo VALUES ('210504', '21', '05', '04', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('210505', '21', '05', '05', 'CONDURIRI');
INSERT INTO ubigeo VALUES ('210600', '21', '06', '00', 'HUANCANE');
INSERT INTO ubigeo VALUES ('210601', '21', '06', '01', 'HUANCANE');
INSERT INTO ubigeo VALUES ('210602', '21', '06', '02', 'COJATA');
INSERT INTO ubigeo VALUES ('210603', '21', '06', '03', 'HUATASANI');
INSERT INTO ubigeo VALUES ('210604', '21', '06', '04', 'INCHUPALLA');
INSERT INTO ubigeo VALUES ('210605', '21', '06', '05', 'PUSI');
INSERT INTO ubigeo VALUES ('210606', '21', '06', '06', 'ROSASPATA');
INSERT INTO ubigeo VALUES ('210607', '21', '06', '07', 'TARACO');
INSERT INTO ubigeo VALUES ('210608', '21', '06', '08', 'VILQUE CHICO');
INSERT INTO ubigeo VALUES ('210700', '21', '07', '00', 'LAMPA');
INSERT INTO ubigeo VALUES ('210701', '21', '07', '01', 'LAMPA');
INSERT INTO ubigeo VALUES ('210702', '21', '07', '02', 'CABANILLA');
INSERT INTO ubigeo VALUES ('210703', '21', '07', '03', 'CALAPUJA');
INSERT INTO ubigeo VALUES ('210704', '21', '07', '04', 'NICASIO');
INSERT INTO ubigeo VALUES ('210705', '21', '07', '05', 'OCUVIRI');
INSERT INTO ubigeo VALUES ('210706', '21', '07', '06', 'PALCA');
INSERT INTO ubigeo VALUES ('210707', '21', '07', '07', 'PARATIA');
INSERT INTO ubigeo VALUES ('210708', '21', '07', '08', 'PUCARA');
INSERT INTO ubigeo VALUES ('210709', '21', '07', '09', 'SANTA LUCIA');
INSERT INTO ubigeo VALUES ('210710', '21', '07', '10', 'VILAVILA');
INSERT INTO ubigeo VALUES ('210800', '21', '08', '00', 'MELGAR');
INSERT INTO ubigeo VALUES ('210801', '21', '08', '01', 'AYAVIRI');
INSERT INTO ubigeo VALUES ('210802', '21', '08', '02', 'ANTAUTA');
INSERT INTO ubigeo VALUES ('210803', '21', '08', '03', 'CUPI');
INSERT INTO ubigeo VALUES ('210804', '21', '08', '04', 'LLALLI');
INSERT INTO ubigeo VALUES ('210805', '21', '08', '05', 'MACARI');
INSERT INTO ubigeo VALUES ('210806', '21', '08', '06', 'NUÑOA');
INSERT INTO ubigeo VALUES ('210807', '21', '08', '07', 'ORURILLO');
INSERT INTO ubigeo VALUES ('210808', '21', '08', '08', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('210809', '21', '08', '09', 'UMACHIRI');
INSERT INTO ubigeo VALUES ('210900', '21', '09', '00', 'MOHO');
INSERT INTO ubigeo VALUES ('210901', '21', '09', '01', 'MOHO');
INSERT INTO ubigeo VALUES ('210902', '21', '09', '02', 'CONIMA');
INSERT INTO ubigeo VALUES ('210903', '21', '09', '03', 'HUAYRAPATA');
INSERT INTO ubigeo VALUES ('210904', '21', '09', '04', 'TILALI');
INSERT INTO ubigeo VALUES ('211000', '21', '10', '00', 'SAN ANTONIO DE PUTINA');
INSERT INTO ubigeo VALUES ('211001', '21', '10', '01', 'PUTINA');
INSERT INTO ubigeo VALUES ('211002', '21', '10', '02', 'ANANEA');
INSERT INTO ubigeo VALUES ('211003', '21', '10', '03', 'PEDRO VILCA APAZA');
INSERT INTO ubigeo VALUES ('211004', '21', '10', '04', 'QUILCAPUNCU');
INSERT INTO ubigeo VALUES ('211005', '21', '10', '05', 'SINA');
INSERT INTO ubigeo VALUES ('211100', '21', '11', '00', 'SAN ROMAN');
INSERT INTO ubigeo VALUES ('211101', '21', '11', '01', 'JULIACA');
INSERT INTO ubigeo VALUES ('211102', '21', '11', '02', 'CABANA');
INSERT INTO ubigeo VALUES ('211103', '21', '11', '03', 'CABANILLAS');
INSERT INTO ubigeo VALUES ('211104', '21', '11', '04', 'CARACOTO');
INSERT INTO ubigeo VALUES ('211200', '21', '12', '00', 'SANDIA');
INSERT INTO ubigeo VALUES ('211201', '21', '12', '01', 'SANDIA');
INSERT INTO ubigeo VALUES ('211202', '21', '12', '02', 'CUYOCUYO');
INSERT INTO ubigeo VALUES ('211203', '21', '12', '03', 'LIMBANI');
INSERT INTO ubigeo VALUES ('211204', '21', '12', '04', 'PATAMBUCO');
INSERT INTO ubigeo VALUES ('211205', '21', '12', '05', 'PHARA');
INSERT INTO ubigeo VALUES ('211206', '21', '12', '06', 'QUIACA');
INSERT INTO ubigeo VALUES ('211207', '21', '12', '07', 'SAN JUAN DEL ORO');
INSERT INTO ubigeo VALUES ('211208', '21', '12', '08', 'YANAHUAYA');
INSERT INTO ubigeo VALUES ('211209', '21', '12', '09', 'ALTO INAMBARI');
INSERT INTO ubigeo VALUES ('211210', '21', '12', '10', 'SAN PEDRO DE PUTINA PUNCO');
INSERT INTO ubigeo VALUES ('211300', '21', '13', '00', 'YUNGUYO');
INSERT INTO ubigeo VALUES ('211301', '21', '13', '01', 'YUNGUYO');
INSERT INTO ubigeo VALUES ('211302', '21', '13', '02', 'ANAPIA');
INSERT INTO ubigeo VALUES ('211303', '21', '13', '03', 'COPANI');
INSERT INTO ubigeo VALUES ('211304', '21', '13', '04', 'CUTURAPI');
INSERT INTO ubigeo VALUES ('211305', '21', '13', '05', 'OLLARAYA');
INSERT INTO ubigeo VALUES ('211306', '21', '13', '06', 'TINICACHI');
INSERT INTO ubigeo VALUES ('211307', '21', '13', '07', 'UNICACHI');
INSERT INTO ubigeo VALUES ('220000', '22', '00', '00', 'SAN MARTIN');
INSERT INTO ubigeo VALUES ('220100', '22', '01', '00', 'MOYOBAMBA');
INSERT INTO ubigeo VALUES ('220101', '22', '01', '01', 'MOYOBAMBA');
INSERT INTO ubigeo VALUES ('220102', '22', '01', '02', 'CALZADA');
INSERT INTO ubigeo VALUES ('220103', '22', '01', '03', 'HABANA');
INSERT INTO ubigeo VALUES ('220104', '22', '01', '04', 'JEPELACIO');
INSERT INTO ubigeo VALUES ('220105', '22', '01', '05', 'SORITOR');
INSERT INTO ubigeo VALUES ('220106', '22', '01', '06', 'YANTALO');
INSERT INTO ubigeo VALUES ('220200', '22', '02', '00', 'BELLAVISTA');
INSERT INTO ubigeo VALUES ('220201', '22', '02', '01', 'BELLAVISTA');
INSERT INTO ubigeo VALUES ('220202', '22', '02', '02', 'ALTO BIAVO');
INSERT INTO ubigeo VALUES ('220203', '22', '02', '03', 'BAJO BIAVO');
INSERT INTO ubigeo VALUES ('220204', '22', '02', '04', 'HUALLAGA');
INSERT INTO ubigeo VALUES ('220205', '22', '02', '05', 'SAN PABLO');
INSERT INTO ubigeo VALUES ('220206', '22', '02', '06', 'SAN RAFAEL');
INSERT INTO ubigeo VALUES ('220300', '22', '03', '00', 'EL DORADO');
INSERT INTO ubigeo VALUES ('220301', '22', '03', '01', 'SAN JOSE DE SISA');
INSERT INTO ubigeo VALUES ('220302', '22', '03', '02', 'AGUA BLANCA');
INSERT INTO ubigeo VALUES ('220303', '22', '03', '03', 'SAN MARTIN');
INSERT INTO ubigeo VALUES ('220304', '22', '03', '04', 'SANTA ROSA');
INSERT INTO ubigeo VALUES ('220305', '22', '03', '05', 'SHATOJA');
INSERT INTO ubigeo VALUES ('220400', '22', '04', '00', 'HUALLAGA');
INSERT INTO ubigeo VALUES ('220401', '22', '04', '01', 'SAPOSOA');
INSERT INTO ubigeo VALUES ('220402', '22', '04', '02', 'ALTO SAPOSOA');
INSERT INTO ubigeo VALUES ('220403', '22', '04', '03', 'EL ESLABON');
INSERT INTO ubigeo VALUES ('220404', '22', '04', '04', 'PISCOYACU');
INSERT INTO ubigeo VALUES ('220405', '22', '04', '05', 'SACANCHE');
INSERT INTO ubigeo VALUES ('220406', '22', '04', '06', 'TINGO DE SAPOSOA');
INSERT INTO ubigeo VALUES ('220500', '22', '05', '00', 'LAMAS');
INSERT INTO ubigeo VALUES ('220501', '22', '05', '01', 'LAMAS');
INSERT INTO ubigeo VALUES ('220502', '22', '05', '02', 'ALONSO DE ALVARADO');
INSERT INTO ubigeo VALUES ('220503', '22', '05', '03', 'BARRANQUITA');
INSERT INTO ubigeo VALUES ('220504', '22', '05', '04', 'CAYNARACHI');
INSERT INTO ubigeo VALUES ('220505', '22', '05', '05', 'CUÑUMBUQUI');
INSERT INTO ubigeo VALUES ('220506', '22', '05', '06', 'PINTO RECODO');
INSERT INTO ubigeo VALUES ('220507', '22', '05', '07', 'RUMISAPA');
INSERT INTO ubigeo VALUES ('220508', '22', '05', '08', 'SAN ROQUE DE CUMBAZA');
INSERT INTO ubigeo VALUES ('220509', '22', '05', '09', 'SHANAO');
INSERT INTO ubigeo VALUES ('220510', '22', '05', '10', 'TABALOSOS');
INSERT INTO ubigeo VALUES ('220511', '22', '05', '11', 'ZAPATERO');
INSERT INTO ubigeo VALUES ('220600', '22', '06', '00', 'MARISCAL CACERES');
INSERT INTO ubigeo VALUES ('220601', '22', '06', '01', 'JUANJUI');
INSERT INTO ubigeo VALUES ('220602', '22', '06', '02', 'CAMPANILLA');
INSERT INTO ubigeo VALUES ('220603', '22', '06', '03', 'HUICUNGO');
INSERT INTO ubigeo VALUES ('220604', '22', '06', '04', 'PACHIZA');
INSERT INTO ubigeo VALUES ('220605', '22', '06', '05', 'PAJARILLO');
INSERT INTO ubigeo VALUES ('220700', '22', '07', '00', 'PICOTA');
INSERT INTO ubigeo VALUES ('220701', '22', '07', '01', 'PICOTA');
INSERT INTO ubigeo VALUES ('220702', '22', '07', '02', 'BUENOS AIRES');
INSERT INTO ubigeo VALUES ('220703', '22', '07', '03', 'CASPISAPA');
INSERT INTO ubigeo VALUES ('220704', '22', '07', '04', 'PILLUANA');
INSERT INTO ubigeo VALUES ('220705', '22', '07', '05', 'PUCACACA');
INSERT INTO ubigeo VALUES ('220706', '22', '07', '06', 'SAN CRISTOBAL');
INSERT INTO ubigeo VALUES ('220707', '22', '07', '07', 'SAN HILARION');
INSERT INTO ubigeo VALUES ('220708', '22', '07', '08', 'SHAMBOYACU');
INSERT INTO ubigeo VALUES ('220709', '22', '07', '09', 'TINGO DE PONASA');
INSERT INTO ubigeo VALUES ('220710', '22', '07', '10', 'TRES UNIDOS');
INSERT INTO ubigeo VALUES ('220800', '22', '08', '00', 'RIOJA');
INSERT INTO ubigeo VALUES ('220801', '22', '08', '01', 'RIOJA');
INSERT INTO ubigeo VALUES ('220802', '22', '08', '02', 'AWAJUN');
INSERT INTO ubigeo VALUES ('220803', '22', '08', '03', 'ELIAS SOPLIN VARGAS');
INSERT INTO ubigeo VALUES ('220804', '22', '08', '04', 'NUEVA CAJAMARCA');
INSERT INTO ubigeo VALUES ('220805', '22', '08', '05', 'PARDO MIGUEL');
INSERT INTO ubigeo VALUES ('220806', '22', '08', '06', 'POSIC');
INSERT INTO ubigeo VALUES ('220807', '22', '08', '07', 'SAN FERNANDO');
INSERT INTO ubigeo VALUES ('220808', '22', '08', '08', 'YORONGOS');
INSERT INTO ubigeo VALUES ('220809', '22', '08', '09', 'YURACYACU');
INSERT INTO ubigeo VALUES ('220900', '22', '09', '00', 'SAN MARTIN');
INSERT INTO ubigeo VALUES ('220901', '22', '09', '01', 'TARAPOTO');
INSERT INTO ubigeo VALUES ('220902', '22', '09', '02', 'ALBERTO LEVEAU');
INSERT INTO ubigeo VALUES ('220903', '22', '09', '03', 'CACATACHI');
INSERT INTO ubigeo VALUES ('220904', '22', '09', '04', 'CHAZUTA');
INSERT INTO ubigeo VALUES ('220905', '22', '09', '05', 'CHIPURANA');
INSERT INTO ubigeo VALUES ('220906', '22', '09', '06', 'EL PORVENIR');
INSERT INTO ubigeo VALUES ('220907', '22', '09', '07', 'HUIMBAYOC');
INSERT INTO ubigeo VALUES ('220908', '22', '09', '08', 'JUAN GUERRA');
INSERT INTO ubigeo VALUES ('220909', '22', '09', '09', 'LA BANDA DE SHILCAYO');
INSERT INTO ubigeo VALUES ('220910', '22', '09', '10', 'MORALES');
INSERT INTO ubigeo VALUES ('220911', '22', '09', '11', 'PAPAPLAYA');
INSERT INTO ubigeo VALUES ('220912', '22', '09', '12', 'SAN ANTONIO');
INSERT INTO ubigeo VALUES ('220913', '22', '09', '13', 'SAUCE');
INSERT INTO ubigeo VALUES ('220914', '22', '09', '14', 'SHAPAJA');
INSERT INTO ubigeo VALUES ('221000', '22', '10', '00', 'TOCACHE');
INSERT INTO ubigeo VALUES ('221001', '22', '10', '01', 'TOCACHE');
INSERT INTO ubigeo VALUES ('221002', '22', '10', '02', 'NUEVO PROGRESO');
INSERT INTO ubigeo VALUES ('221003', '22', '10', '03', 'POLVORA');
INSERT INTO ubigeo VALUES ('221004', '22', '10', '04', 'SHUNTE');
INSERT INTO ubigeo VALUES ('221005', '22', '10', '05', 'UCHIZA');
INSERT INTO ubigeo VALUES ('230000', '23', '00', '00', 'TACNA');
INSERT INTO ubigeo VALUES ('230100', '23', '01', '00', 'TACNA');
INSERT INTO ubigeo VALUES ('230101', '23', '01', '01', 'TACNA');
INSERT INTO ubigeo VALUES ('230102', '23', '01', '02', 'ALTO DE LA ALIANZA');
INSERT INTO ubigeo VALUES ('230103', '23', '01', '03', 'CALANA');
INSERT INTO ubigeo VALUES ('230104', '23', '01', '04', 'CIUDAD NUEVA');
INSERT INTO ubigeo VALUES ('230105', '23', '01', '05', 'INCLAN');
INSERT INTO ubigeo VALUES ('230106', '23', '01', '06', 'PACHIA');
INSERT INTO ubigeo VALUES ('230107', '23', '01', '07', 'PALCA');
INSERT INTO ubigeo VALUES ('230108', '23', '01', '08', 'POCOLLAY');
INSERT INTO ubigeo VALUES ('230109', '23', '01', '09', 'SAMA');
INSERT INTO ubigeo VALUES ('230110', '23', '01', '10', 'CORONEL GREGORIO ALBARRACIN LANCHIPA');
INSERT INTO ubigeo VALUES ('230200', '23', '02', '00', 'CANDARAVE');
INSERT INTO ubigeo VALUES ('230201', '23', '02', '01', 'CANDARAVE');
INSERT INTO ubigeo VALUES ('230202', '23', '02', '02', 'CAIRANI');
INSERT INTO ubigeo VALUES ('230203', '23', '02', '03', 'CAMILACA');
INSERT INTO ubigeo VALUES ('230204', '23', '02', '04', 'CURIBAYA');
INSERT INTO ubigeo VALUES ('230205', '23', '02', '05', 'HUANUARA');
INSERT INTO ubigeo VALUES ('230206', '23', '02', '06', 'QUILAHUANI');
INSERT INTO ubigeo VALUES ('230300', '23', '03', '00', 'JORGE BASADRE');
INSERT INTO ubigeo VALUES ('230301', '23', '03', '01', 'LOCUMBA');
INSERT INTO ubigeo VALUES ('230302', '23', '03', '02', 'ILABAYA');
INSERT INTO ubigeo VALUES ('230303', '23', '03', '03', 'ITE');
INSERT INTO ubigeo VALUES ('230400', '23', '04', '00', 'TARATA');
INSERT INTO ubigeo VALUES ('230401', '23', '04', '01', 'TARATA');
INSERT INTO ubigeo VALUES ('230402', '23', '04', '02', 'HEROES ALBARRACIN');
INSERT INTO ubigeo VALUES ('230403', '23', '04', '03', 'ESTIQUE');
INSERT INTO ubigeo VALUES ('230404', '23', '04', '04', 'ESTIQUE-PAMPA');
INSERT INTO ubigeo VALUES ('230405', '23', '04', '05', 'SITAJARA');
INSERT INTO ubigeo VALUES ('230406', '23', '04', '06', 'SUSAPAYA');
INSERT INTO ubigeo VALUES ('230407', '23', '04', '07', 'TARUCACHI');
INSERT INTO ubigeo VALUES ('230408', '23', '04', '08', 'TICACO');
INSERT INTO ubigeo VALUES ('240000', '24', '00', '00', 'TUMBES');
INSERT INTO ubigeo VALUES ('240100', '24', '01', '00', 'TUMBES');
INSERT INTO ubigeo VALUES ('240101', '24', '01', '01', 'TUMBES');
INSERT INTO ubigeo VALUES ('240102', '24', '01', '02', 'CORRALES');
INSERT INTO ubigeo VALUES ('240103', '24', '01', '03', 'LA CRUZ');
INSERT INTO ubigeo VALUES ('240104', '24', '01', '04', 'PAMPAS DE HOSPITAL');
INSERT INTO ubigeo VALUES ('240105', '24', '01', '05', 'SAN JACINTO');
INSERT INTO ubigeo VALUES ('240106', '24', '01', '06', 'SAN JUAN DE LA VIRGEN');
INSERT INTO ubigeo VALUES ('240200', '24', '02', '00', 'CONTRALMIRANTE VILLAR');
INSERT INTO ubigeo VALUES ('240201', '24', '02', '01', 'ZORRITOS');
INSERT INTO ubigeo VALUES ('240202', '24', '02', '02', 'CASITAS');
INSERT INTO ubigeo VALUES ('240203', '24', '02', '03', 'CANOAS DE PUNTA SAL');
INSERT INTO ubigeo VALUES ('240300', '24', '03', '00', 'ZARUMILLA');
INSERT INTO ubigeo VALUES ('240301', '24', '03', '01', 'ZARUMILLA');
INSERT INTO ubigeo VALUES ('240302', '24', '03', '02', 'AGUAS VERDES');
INSERT INTO ubigeo VALUES ('240303', '24', '03', '03', 'MATAPALO');
INSERT INTO ubigeo VALUES ('240304', '24', '03', '04', 'PAPAYAL');
INSERT INTO ubigeo VALUES ('250000', '25', '00', '00', 'UCAYALI');
INSERT INTO ubigeo VALUES ('250100', '25', '01', '00', 'CORONEL PORTILLO');
INSERT INTO ubigeo VALUES ('250101', '25', '01', '01', 'CALLERIA');
INSERT INTO ubigeo VALUES ('250102', '25', '01', '02', 'CAMPOVERDE');
INSERT INTO ubigeo VALUES ('250103', '25', '01', '03', 'IPARIA');
INSERT INTO ubigeo VALUES ('250104', '25', '01', '04', 'MASISEA');
INSERT INTO ubigeo VALUES ('250105', '25', '01', '05', 'YARINACOCHA');
INSERT INTO ubigeo VALUES ('250106', '25', '01', '06', 'NUEVA REQUENA');
INSERT INTO ubigeo VALUES ('250107', '25', '01', '07', 'MANANTAY');
INSERT INTO ubigeo VALUES ('250200', '25', '02', '00', 'ATALAYA');
INSERT INTO ubigeo VALUES ('250201', '25', '02', '01', 'RAYMONDI');
INSERT INTO ubigeo VALUES ('250202', '25', '02', '02', 'SEPAHUA');
INSERT INTO ubigeo VALUES ('250203', '25', '02', '03', 'TAHUANIA');
INSERT INTO ubigeo VALUES ('250204', '25', '02', '04', 'YURUA');
INSERT INTO ubigeo VALUES ('250300', '25', '03', '00', 'PADRE ABAD');
INSERT INTO ubigeo VALUES ('250301', '25', '03', '01', 'PADRE ABAD');
INSERT INTO ubigeo VALUES ('250302', '25', '03', '02', 'IRAZOLA');
INSERT INTO ubigeo VALUES ('250303', '25', '03', '03', 'CURIMANA');
INSERT INTO ubigeo VALUES ('250400', '25', '04', '00', 'PURUS');
INSERT INTO ubigeo VALUES ('250401', '25', '04', '01', 'PURUS');

INSERT INTO "ConfiguracionTipoServicio" VALUES (11, false, false, false, true, true, false, false, true, true, true, true, false, true, true, true, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (16, false, false, false, false, true, false, false, false, true, false, false, false, false, false, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (12, false, false, false, false, true, true, false, false, true, false, false, false, false, false, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (15, true, false, true, true, true, false, false, true, true, true, true, true, true, true, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (14, false, false, true, true, true, true, true, true, true, false, true, true, true, false, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (18, false, false, false, true, true, true, false, true, true, false, true, false, false, false, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (21, false, false, false, true, true, true, true, true, true, false, true, false, false, false, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (20, false, false, false, true, false, false, false, false, true, false, false, false, false, false, false, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);
INSERT INTO "ConfiguracionTipoServicio" VALUES (23, true, true, false, true, true, false, false, true, true, false, false, false, false, false, true, 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 'admin', '2015-09-29 22:37:11.914-05', '192.168.1.36', 1);

INSERT INTO "Tablamaestra" VALUES (6, 12, 'FEE', 'FEE DE EMISION', 6, 'A', 'FEE');
INSERT INTO "Tablamaestra" VALUES (15, 0, 'MAESTRO DE ESTADO SERVICIO', 'MAESTRO DE ESTADOS DE SERVICIO', 15, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 0, 'MAESTRO DE TIPO DE DOCUMENTO', 'MAESTRO DE TIPO DE DOCUMENTO', 1, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (2, 0, 'MAESTRO DE VIAS', 'MAESTRO DE VIAS', 2, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (3, 0, 'MAESTRO DE RUBRO', 'MAESTRO DE RUBRO', 3, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 1, 'DNI', 'DOCUMENO NACIONAL DE IDENTIDAD', 1, 'A', 'DNI');
INSERT INTO "Tablamaestra" VALUES (2, 1, 'CARNÉ DE EXTRANJERIA', 'CARNÉ DE EXTRANJERIA', 2, 'A', 'CE');
INSERT INTO "Tablamaestra" VALUES (3, 1, 'RUC', 'REGISTRO UNICO DEL CONTRIBUYENTE', 3, 'A', 'RUC');
INSERT INTO "Tablamaestra" VALUES (1, 2, 'AVENIDA', 'AVENIDA', 1, 'A', 'AV');
INSERT INTO "Tablamaestra" VALUES (3, 2, 'JIRON', 'JIRON', 3, 'A', 'JR');
INSERT INTO "Tablamaestra" VALUES (4, 2, 'PASAJE', 'PASAJE', 4, 'A', 'PSJ');
INSERT INTO "Tablamaestra" VALUES (1, 3, 'EDUCACION', 'EDUCACION', 1, 'A', 'EDU');
INSERT INTO "Tablamaestra" VALUES (2, 3, 'SALUD', 'SALUD', 2, 'A', 'SALUD');
INSERT INTO "Tablamaestra" VALUES (1, 15, 'PENDIENTE', 'PENDIENTE DE CIERRE', 1, 'A', 'PEN');
INSERT INTO "Tablamaestra" VALUES (2, 15, 'CERRADO', 'CERRADO', 2, 'A', 'CERR');
INSERT INTO "Tablamaestra" VALUES (3, 15, 'ANULADO', 'ANULADO', 3, 'A', 'ANU');
INSERT INTO "Tablamaestra" VALUES (4, 0, 'MAESTRO DE AREAS', 'MAESTRO DE AREAS LO', 0, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (5, 4, 'ALMACEN', 'ALMACEN', 5, 'A', 'ALM');
INSERT INTO "Tablamaestra" VALUES (6, 4, 'CONTABILIDAD', 'CONTABILIDAD', 6, 'A', 'CON');
INSERT INTO "Tablamaestra" VALUES (7, 0, 'MAESTRO DE MENSAJES', 'MAESTRO DE MENSAJES', 7, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (8, 0, 'MAESTRO DE BANCOS', 'MAESTRO DE BANCOS', 8, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 8, 'BANCO FINANCIERO', 'BANCO FINANCIERO DEL PERU', 1, 'A', 'BFP');
INSERT INTO "Tablamaestra" VALUES (2, 8, 'BANCO INTERBANK', 'BANCO INTERNACIONAL DEL PERU', 2, 'A', 'IBK');
INSERT INTO "Tablamaestra" VALUES (3, 8, 'BANCO DE CREDITO', 'BANCO DE CREDITO DEL PERU', 3, 'A', 'BCP');
INSERT INTO "Tablamaestra" VALUES (4, 8, 'BANCO SCOTIABANK', 'BANCO SCOTIABANK', 4, 'A', 'SCO');
INSERT INTO "Tablamaestra" VALUES (5, 8, 'BANCO BBVA CONTINENTAL', 'BANCO BBVA CONTINENTAL', 5, 'A', 'BBVA');
INSERT INTO "Tablamaestra" VALUES (6, 8, 'BANCO CITYBANK', 'BANCO CITYBANK', 6, 'A', 'CITI');
INSERT INTO "Tablamaestra" VALUES (9, 0, 'MAESTRO DE ESTADO CIVIL', 'MAESTRO DE ESTADO CIVIL', 9, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 9, 'SOLTERO', 'SOLTERO', 1, 'A', 'SOL');
INSERT INTO "Tablamaestra" VALUES (2, 9, 'CASADO', 'CASADO', 2, 'A', 'CAS');
INSERT INTO "Tablamaestra" VALUES (4, 9, 'VIUDO', 'VIUDO', 4, 'A', 'VIU');
INSERT INTO "Tablamaestra" VALUES (3, 3, 'TELEFONIA', 'TELEFONIA', 3, 'A', 'TELEF');
INSERT INTO "Tablamaestra" VALUES (4, 3, 'MECANICA', 'MECANICA', 4, 'A', 'MEC');
INSERT INTO "Tablamaestra" VALUES (1, 4, 'PRODUCCION', 'PRODUCCION', 1, 'A', 'PROD');
INSERT INTO "Tablamaestra" VALUES (2, 4, 'VENTAS', 'VENTAS', 2, 'A', 'VEN');
INSERT INTO "Tablamaestra" VALUES (3, 4, 'FINANZAS', 'FINANZAS', 3, 'A', 'FINA');
INSERT INTO "Tablamaestra" VALUES (4, 4, 'COMPRAS', 'COMPRAS', 4, 'A', 'COM');
INSERT INTO "Tablamaestra" VALUES (5, 0, 'MAESTRO DE EMPRESAS OPERADORAS', 'MAESTRO DE EMPRESAS OPERADORAS', 5, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 5, 'CLARO', 'CLARO', 1, 'A', 'CLA');
INSERT INTO "Tablamaestra" VALUES (2, 5, 'MOVISTAR', 'MOVISTAR', 2, 'A', 'MOV');
INSERT INTO "Tablamaestra" VALUES (3, 5, 'NEXTEL', 'NEXTEL', 3, 'A', 'NEX');
INSERT INTO "Tablamaestra" VALUES (6, 0, 'MAESTRO DE PERSONAS', 'MAESTRO DE PERSONAS', 6, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 6, 'CLIENTE', 'CLIENTE', 1, 'A', 'CLI');
INSERT INTO "Tablamaestra" VALUES (2, 6, 'PROVEEDOR', 'PROVEEDOR', 2, 'A', 'PRO');
INSERT INTO "Tablamaestra" VALUES (3, 6, 'CONTACTO', 'CONTACTO DE PROVEEDOR', 3, 'A', 'CPRO');
INSERT INTO "Tablamaestra" VALUES (5, 3, 'FERRETERIA', 'FERRETERIA', 5, 'A', 'FER');
INSERT INTO "Tablamaestra" VALUES (6, 3, 'LIBRERIA', 'LIBRERIA', 6, 'A', 'LIB');
INSERT INTO "Tablamaestra" VALUES (7, 3, 'MAYORISTAS', 'AGENCIAS MAYORITAS', 7, 'A', 'AGMAY');
INSERT INTO "Tablamaestra" VALUES (8, 3, 'ASEGURADORAS', 'ASEGURADORAS', 8, 'A', 'ASEG');
INSERT INTO "Tablamaestra" VALUES (9, 3, 'AGENCIA DE VIAJES', 'AGENCIA DE VIAJES', 9, 'A', 'AGE');
INSERT INTO "Tablamaestra" VALUES (2, 2, 'CALLE', 'CALLE', 0, 'A', 'CA');
INSERT INTO "Tablamaestra" VALUES (3, 9, 'DIVORCIADO', 'DIVORCIADO', 3, 'A', 'DIV');
INSERT INTO "Tablamaestra" VALUES (10, 3, 'BELLEZA', 'PELUQUERIA Y SPA', 10, 'A', 'BEL');
INSERT INTO "Tablamaestra" VALUES (10, 0, 'MAESTRO DE CONTINENTES', 'MAESTRO DE CONTINENTES', 10, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 10, 'AMERICA DEL SUR', 'AMERCIA DEL SUR', 1, 'A', 'AMSUR');
INSERT INTO "Tablamaestra" VALUES (2, 10, 'AMERICA DEL CENTRO', 'AMERICA DEL CENTRO', 2, 'A', 'AMCEN');
INSERT INTO "Tablamaestra" VALUES (3, 10, 'AMERICA DEL NORTE', 'AMERICA DEL NORTE', 3, 'A', 'AMNOR');
INSERT INTO "Tablamaestra" VALUES (4, 10, 'EUROPA', 'EUROPA', 4, 'A', 'EUR');
INSERT INTO "Tablamaestra" VALUES (5, 10, 'ASIA', 'ASIA', 5, 'A', 'ASI');
INSERT INTO "Tablamaestra" VALUES (6, 10, 'AFRICA', 'AFRICA', 6, 'A', 'AFR');
INSERT INTO "Tablamaestra" VALUES (7, 10, 'OCEANIA', 'OCEANIA', 7, 'A', 'OCE');
INSERT INTO "Tablamaestra" VALUES (11, 0, 'MAESTRO TIPO DE DESTINO', 'MAESTRO TIPO DE DESTINO', 11, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 11, 'PLAYA', 'PLAYA', 1, 'A', 'PLA');
INSERT INTO "Tablamaestra" VALUES (2, 11, 'CIUDAD', 'CIUDAD', 2, 'A', 'CIU');
INSERT INTO "Tablamaestra" VALUES (3, 11, 'NIEVE', 'NIEVE', 3, 'A', 'NIEVE');
INSERT INTO "Tablamaestra" VALUES (4, 11, 'AVENTURA', 'AVENTURA', 4, 'A', 'AVEN');
INSERT INTO "Tablamaestra" VALUES (12, 0, 'MAESTRO DE TIPO DE SERVICIOS', 'MAESTRO DE TIPO DE SERVICIOS', 12, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 12, 'BOLETO', 'BOLETO', 1, 'A', 'BOL');
INSERT INTO "Tablamaestra" VALUES (2, 12, 'PAQUETE', 'PAQUETE', 2, 'A', 'PAQ');
INSERT INTO "Tablamaestra" VALUES (3, 12, 'PROGRAMA', 'PROGRAMA', 3, 'A', 'PROG');
INSERT INTO "Tablamaestra" VALUES (4, 12, 'TRASLADO', 'TRASLADO', 4, 'A', 'TRAS');
INSERT INTO "Tablamaestra" VALUES (5, 12, 'HOTEL', 'HOTEL', 5, 'A', 'HOT');
INSERT INTO "Tablamaestra" VALUES (13, 0, 'MAESTRO DE FORMA DE PAGO', 'MAESTRO DE FORMA DE PAGO', 13, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 13, 'EFECTIVO', 'EFECTIVO', 1, 'A', 'EFE');
INSERT INTO "Tablamaestra" VALUES (14, 0, 'MAESTRO DE ESTADOS DE PAGO', 'MAESTRO DE ESTADOS DE PAGO', 14, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 14, 'PENDIENTE', 'PENDIENTE', 1, 'A', 'PEN');
INSERT INTO "Tablamaestra" VALUES (2, 14, 'PAGADO', 'PAGADO', 2, 'A', 'PAG');
INSERT INTO "Tablamaestra" VALUES (3, 14, 'PENDIENTE CON MORA', 'PENDIENTE CON MORA', 3, 'A', 'PEMOR');
INSERT INTO "Tablamaestra" VALUES (1, 16, 'AEROLINEA', 'AEROLINEA', 1, 'A', 'AERO');
INSERT INTO "Tablamaestra" VALUES (2, 16, 'CONSOLIDADOR', 'CONSOLIDADOR', 2, 'A', 'CONS');
INSERT INTO "Tablamaestra" VALUES (3, 16, 'OPERADOR', 'OPERADOR', 3, 'A', 'OPER');
INSERT INTO "Tablamaestra" VALUES (4, 16, 'TRANSPORTISTA', 'EMPRESA DE TRANSPORTES', 4, 'A', 'ETRA');
INSERT INTO "Tablamaestra" VALUES (5, 16, 'TRASLADISTA', 'TRASLADISTA', 5, 'A', 'TRAS');
INSERT INTO "Tablamaestra" VALUES (11, 3, 'HOTEL', 'HOTEL HOSPEDAJE', 11, 'A', 'HOTE');
INSERT INTO "Tablamaestra" VALUES (6, 16, 'HOTEL', 'HOTEL', 6, 'A', 'HOTE');
INSERT INTO "Tablamaestra" VALUES (4, 15, 'OBSERVADO', 'OBSERVADO', 4, 'A', 'OBS');
INSERT INTO "Tablamaestra" VALUES (16, 0, 'MAESTRO TIPO DE PROVEEDOR', 'MAESTRO TIPO DE PROVEEDOR', 0, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (17, 0, 'MAESTRO DE TIPO DE COMPROBANTE', 'MAESTRO DE TIPO DE COMPROBANTE', 17, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (18, 0, 'MAESTRO DE DOCUMENTOS', 'MAESTRO DE DOCUMENTOS', 18, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 18, 'TICKET ELECTRONICO', 'TICKET ELECTRONICO', 1, 'A', 'TIEL');
INSERT INTO "Tablamaestra" VALUES (2, 18, 'DOCUMENTO DE IDENTIDAD', 'DOCUMENTO DE IDENTIDAD', 2, 'A', 'DOCID');
INSERT INTO "Tablamaestra" VALUES (3, 18, 'VOUCHER DE DEPOSITO', 'VOUCHER DE DEPOSITO', 3, 'A', 'VODE');
INSERT INTO "Tablamaestra" VALUES (1, 17, 'FACTURA', 'FACTURA', 0, 'A', 'F');
INSERT INTO "Tablamaestra" VALUES (3, 17, 'DOCUMENTO DE COBRANZA', 'DOCUMENTO DE COBRANZA', 0, 'A', 'DC');
INSERT INTO "Tablamaestra" VALUES (2, 17, 'BOLETA', 'BOLETA', 0, 'A', 'B');
INSERT INTO "Tablamaestra" VALUES (4, 17, 'NOTA DE CREDITO', 'NOTA DE CREDITO', 0, 'A', 'NC');
INSERT INTO "Tablamaestra" VALUES (5, 11, 'SELVA', 'SELVA', 5, 'A', 'SEL');
INSERT INTO "Tablamaestra" VALUES (19, 0, 'MAESTRO DE BANCOS', 'MAESTRO DE BANCOS', 19, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (20, 0, 'MAESTRO MONEDAS', 'MAESTRO MONEDAS', 0, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (21, 0, 'MAESTRO TIPO CUENTA', 'MAESTRO TIPO CUENTA', 21, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 19, 'BANCO DE CREDITO', 'BANCO DE CREDITO', 1, 'A', 'BCP');
INSERT INTO "Tablamaestra" VALUES (2, 19, 'INTERBANK', 'BANCO INTERNACIONAL DEL PERU', 2, 'A', 'IBK');
INSERT INTO "Tablamaestra" VALUES (3, 13, 'TRANSFERENCIA', 'TRANSFERENCIA', 0, 'A', 'TRAN');
INSERT INTO "Tablamaestra" VALUES (1, 21, 'AHORROS', 'CUENTA DE AHORROS', 1, 'A', 'AH');
INSERT INTO "Tablamaestra" VALUES (2, 21, 'CUENTA CORRIENTE', 'CUENTA CORRIENTE', 2, 'A', 'CC');
INSERT INTO "Tablamaestra" VALUES (1, 20, 'NUEVOS SOLES', 'NUEVOS SOLES', 1, 'A', 'S/.');
INSERT INTO "Tablamaestra" VALUES (2, 20, 'DOLARES AMERICANOS', 'DOLARES AMERICANOS', 2, 'A', '$');
INSERT INTO "Tablamaestra" VALUES (22, 0, 'MAESTRO PROVEEDOR DE TARJETA', 'MAESTRO PROVEEDOR DE TARJETA', 22, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 22, 'VISA', 'VISA', 1, 'A', 'VISA');
INSERT INTO "Tablamaestra" VALUES (2, 22, 'MASTERCARD', 'MASTER CARD', 2, 'A', 'MC');
INSERT INTO "Tablamaestra" VALUES (3, 22, 'AMERICAN EXPRESS', 'AMERICAN EXPRESS', 3, 'A', 'AMEX');
INSERT INTO "Tablamaestra" VALUES (4, 22, 'DINERS', 'DINERS CLUB', 4, 'A', 'DINE');
INSERT INTO "Tablamaestra" VALUES (2, 13, 'DEPOSITO EN CUENTA', 'DEPOSITO EN CUENTA', 0, 'A', 'DEPC');
INSERT INTO "Tablamaestra" VALUES (4, 13, 'TARJETA DE CREDITO', 'TARJETA DE CREDITO', 0, 'A', 'TCRE');
INSERT INTO "Tablamaestra" VALUES (12, 3, 'AEROLINEA', 'AEROLINEAS', 12, 'A', 'AERO');
INSERT INTO "Tablamaestra" VALUES (13, 3, 'COMERCIO EXTERIOR', 'IMPORTADOR/ EXPORTADOR', 13, 'A', 'COMEX');
INSERT INTO "Tablamaestra" VALUES (4, 1, 'PASAPORTE', 'PASAPORTE', 4, 'A', 'PASPA');
INSERT INTO "Tablamaestra" VALUES (23, 0, 'MAESTRO DE RELACION', 'MAESTRO DE RELACION', 23, 'A', NULL);
INSERT INTO "Tablamaestra" VALUES (1, 23, 'EL MISMO', 'EL MISMO', 1, 'A', 'MISM');
INSERT INTO "Tablamaestra" VALUES (2, 23, 'ESPOSA', 'ESPOSA', 2, 'A', 'ESPO');
INSERT INTO "Tablamaestra" VALUES (3, 23, 'HIJO', 'HIJO', 3, 'A', 'HIJO');
INSERT INTO "Tablamaestra" VALUES (4, 23, 'HIJA', 'HIJA', 4, 'A', 'HIJA');
INSERT INTO "Tablamaestra" VALUES (5, 23, 'PADRE', 'PADRE', 5, 'A', 'PAD');
INSERT INTO "Tablamaestra" VALUES (6, 23, 'MADRE', 'MADRE', 6, 'A', 'MAD');
INSERT INTO "Tablamaestra" VALUES (7, 23, 'ABUELO', 'ABUELO', 7, 'A', 'ABUO');
INSERT INTO "Tablamaestra" VALUES (8, 23, 'ABUELA', 'ABUELA', 8, 'A', 'ABUA');