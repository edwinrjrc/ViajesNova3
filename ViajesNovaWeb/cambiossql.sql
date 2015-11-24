alter table negocio."ObligacionesXPagar"
 add column idmoneda integer;
 
 -- Function: negocio.fn_ingresarobligacionxpagar(integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, character varying, character varying)

DROP FUNCTION negocio.fn_ingresarobligacionxpagar(integer, character varying, integer, date, date, character varying, numeric, numeric, boolean, boolean, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_ingresarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer, 
p_fechacomprobante date, p_fechapago date, p_detallecomprobante character varying, p_totaligv numeric, p_totalcomprobante numeric, 
p_tienedetraccion boolean, p_tieneretencion boolean, p_usuariocreacion character varying, p_ipcreacion character varying, p_idmoneda integer)
  RETURNS boolean AS
$BODY$

declare maxid integer;
declare fechahoy timestamp with time zone;

begin

maxid = nextval('negocio.seq_obligacionxpagar');

select current_timestamp AT TIME ZONE 'PET' into fechahoy;

INSERT INTO negocio."ObligacionesXPagar"(
            id, idtipocomprobante, numerocomprobante, idproveedor, fechacomprobante, 
            fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, tieneretencion, usuariocreacion, 
            fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
            ipmodificacion, idmoneda)
    VALUES (maxid, p_idtipocomprobante, p_numerocomprobante, p_idproveedor, p_fechacomprobante, 
            p_fechapago, p_detallecomprobante, p_totaligv, p_totalcomprobante, p_totalcomprobante, p_tienedetraccion, p_tieneretencion, p_usuariocreacion, 
            fechahoy, p_ipcreacion, p_usuariocreacion, fechahoy, p_ipcreacion, p_idmoneda);

return true;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
