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
