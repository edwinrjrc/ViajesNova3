-- Table: negocio."PasajeroServicio"

-- DROP TABLE negocio."PasajeroServicio";

CREATE TABLE negocio."PasajeroServicio"
(
  id bigint NOT NULL,
  idtipodocumento integer,
  numerodocumento character varying(11),
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
  idestadoregistro integer NOT NULL DEFAULT 1,
  CONSTRAINT pk_pasajeroservicio PRIMARY KEY (id),
  CONSTRAINT fk_paxserviciocabecera FOREIGN KEY (idservicio)
      REFERENCES negocio."ServicioCabecera" (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION
)
WITH (
  OIDS=FALSE
);


-- Function: negocio.fn_ingresarpasajero(character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, character varying)

-- DROP FUNCTION negocio.fn_ingresarpasajero(character varying, character varying, character varying, character varying, character varying, character varying, character varying, integer, integer, integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_ingresarpasajero(p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_apellidopaterno character varying, 
p_apellidomaterno character varying, p_correoelectronico character varying, p_telefono1 character varying, p_telefono2 character varying, p_nropaxfrecuente character varying, 
p_idrelacion integer, p_idaerolinea integer, p_idserviciodetalle integer, p_idservicio integer, p_usuariocreacion character varying, p_ipcreacion character varying)
  RETURNS integer AS
$BODY$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_pax');
select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."PasajeroServicio"(
            id, idtipodocumento, numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
            telefono1, telefono2, nropaxfrecuente, idrelacion, idaerolinea, idserviciodetalle, 
            idservicio, usuariocreacion, fechacreacion, ipcreacion, usuariomodificacion, 
            fechamodificacion, ipmodificacion)
    VALUES (maxid, p_idtipodocumento, p_numerodocumento, p_nombres, p_apellidopaterno, p_apellidomaterno, p_correoelectronico, 
            p_telefono1, p_telefono2, p_nropaxfrecuente, p_idrelacion, p_idaerolinea, p_idserviciodetalle, 
            p_idservicio, p_usuariocreacion, fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion);

return maxid;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

  
-- Function: negocio.fn_consultarpasajeros(integer)

-- DROP FUNCTION negocio.fn_consultarpasajeros(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpasajeros(p_idserviciodetalle integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, idtipodocumento, numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea, 
       negocio.fn_consultarnombrepersona(idaerolinea) as nombreaerolina, 
       idrelacion, tmre.nombre as nombrerelacion,
       idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 INNER JOIN soporte."Tablamaestra" tmre ON tmre.idmaestro = 23 AND tmre.id = ps.idrelacion
 WHERE idserviciodetalle = p_idserviciodetalle;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: negocio.fn_consultarpasajeros(integer)

-- DROP FUNCTION negocio.fn_consultarpasajeros(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpasajeros(p_idserviciodetalle integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, idtipodocumento, tmdi.nombre as nombretipodocumento, 
       numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea, 
       negocio.fn_consultarnombrepersona(idaerolinea) as nombreaerolina, 
       idrelacion, tmre.nombre as nombrerelacion,
       idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 INNER JOIN soporte."Tablamaestra" tmre ON tmre.idmaestro = 23 AND tmre.id = ps.idrelacion
 INNER JOIN soporte."Tablamaestra" tmdi ON tmdi.idmaestro =  1 AND tmdi.id = ps.idtipodocumento
 WHERE idserviciodetalle = p_idserviciodetalle;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
