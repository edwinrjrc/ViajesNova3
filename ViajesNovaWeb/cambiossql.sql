CREATE TABLE negocio."PasajeroServicio"
(
  id bigint NOT NULL,
  nombres character varying(100) NOT NULL,
  apellidopaterno character varying(50) NOT NULL,
  apellidomaterno character varying(50) NOT NULL,
  correoelectronico character varying(100),
  telefono1 character varying(10),
  telefono2 character varying(10),
  nropaxfrecuente character varying(20),
  idrelacion integer NOT NULL,
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