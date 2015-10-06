-- Table: negocio."ArchivoCargado"

-- DROP TABLE negocio."ArchivoCargado";

CREATE TABLE negocio."ArchivoCargado"
(
  id integer NOT NULL,
  nombrearchivo character varying(100) NOT NULL,
  nombrereporte character varying(100) NOT NULL,
  idproveedor integer NOT NULL,
  numerofilas integer NOT NULL,
  numerocolumnas integer NOT NULL,
  idmoneda integer NOT NULL,
  montosubtotal decimal(12,4) not null,
  montoIGV decimal(12,4) not null,
  montototal decimal(12,4) not null,
  usuariocreacion character varying(20) NOT NULL,
  fechacreacion timestamp with time zone NOT NULL,
  ipcreacion character(15) NOT NULL,
  usuariomodificacion character varying(15) NOT NULL,
  fechamodificacion timestamp with time zone NOT NULL,
  ipmodificacion character(15) NOT NULL,
  idestadoregistro integer NOT NULL DEFAULT 1,
  CONSTRAINT pk_archivocargado PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);


-- Table: negocio."DetalleArchivoCargado"

-- DROP TABLE negocio."DetalleArchivoCargado";

CREATE TABLE negocio."DetalleArchivoCargado"
(
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
  seleccionado boolean NOT NULL DEFAULT false,
  idtipocomprobante integer,
  numerocomprobante character varying(20),
  usuariocreacion character varying(20) NOT NULL,
  fechacreacion timestamp with time zone NOT NULL,
  ipcreacion character(15) NOT NULL,
  usuariomodificacion character varying(15) NOT NULL,
  fechamodificacion timestamp with time zone NOT NULL,
  ipmodificacion character(15) NOT NULL,
  idestadoregistro integer NOT NULL DEFAULT 1,
  CONSTRAINT pk_detallearchivocargado PRIMARY KEY (id),
  CONSTRAINT fk_archivodetallearchivo FOREIGN KEY (idarchivo)
      REFERENCES negocio."ArchivoCargado" (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE
)
WITH (
  OIDS=FALSE
);

-- Function: negocio.fn_ingresararchivocargado(character varying, character varying, integer, integer, integer, numeric, numeric, numeric, character varying, character varying)

-- DROP FUNCTION negocio.fn_ingresararchivocargado(character varying, character varying, integer, integer, integer, numeric, numeric, numeric, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_ingresararchivocargado(p_nombrearchivo character varying, p_nombrereporte character varying, p_idproveedor integer, 
p_numerofilas integer, p_numerocolumnas integer, p_idmoneda integer, p_montosubtotal numeric, p_montoigv numeric, p_montototal numeric, 
p_usuariocreacion character varying, p_ipcreacion character varying)
  RETURNS integer AS
$BODY$

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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;