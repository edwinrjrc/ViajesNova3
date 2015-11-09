-- Function: negocio.fn_consultarpasajeros(integer)

-- DROP FUNCTION negocio.fn_consultarpasajeros(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpasajeroshistorico(p_idtipodocumento integer, p_numerodocumento character varying)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT ps.id, idtipodocumento, numerodocumento, nombres, apellidopaterno, apellidomaterno, correoelectronico, 
       telefono1, telefono2, nropaxfrecuente, idaerolinea, codigoreserva, numeroboleto, fechavctopasaporte, fechanacimiento,
       idrelacion, idserviciodetalle, idservicio
  FROM negocio."PasajeroServicio" ps
 WHERE idtipodocumento = p_idtipodocumento
   AND numerodocumento = p_numerodocumento;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

 -- Function: negocio.fn_consultarcomprobantesgenerados(integer, integer, integer, integer, character varying, date, date)

-- DROP FUNCTION negocio.fn_consultarcomprobantesgenerados(integer, integer, integer, integer, character varying, date, date);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcomprobantesgenerados(p_idcomprobante integer, p_idservicio integer, p_idadquiriente integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_fechadesde date, p_fechahasta date)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin
open micursor for
SELECT cg.id, cg.idservicio, cg.idtipocomprobante, tm.nombre, cg.numerocomprobante, cg.idtitular, p.nombres, p.apellidopaterno, p.apellidomaterno,
       cg.fechacomprobante, cg.idmoneda, tmmo.nombre as nombremoneda, tmmo.abreviatura, cg.totaligv, cg.totalcomprobante, cg.tienedetraccion, 
       cg.tieneretencion, cg.usuariocreacion, cg.fechacreacion, cg.ipcreacion, cg.usuariomodificacion, 
       cg.fechamodificacion, cg.ipmodificacion
  FROM negocio."ComprobanteGenerado" cg
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = cg.idmoneda
 INNER JOIN soporte."Tablamaestra" tm ON cg.idtipocomprobante = tm.id AND tm.idmaestro = fn_maestrotipocomprobante()
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;