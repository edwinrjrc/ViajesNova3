CREATE OR REPLACE FUNCTION fn_maestrotipodestino()
  RETURNS integer AS
$BODY$

begin

return 11;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_maestrocontinente()
  RETURNS integer AS
$BODY$

begin

return 10;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestromoneda()
  RETURNS integer AS
$BODY$

begin

return 18;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_tipopersonacliente()
  RETURNS integer AS
$BODY$

begin

return 1;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_maestrotipodocumento()
  RETURNS integer AS
$BODY$

begin

return 1;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_maestrotipocomprobante()
  RETURNS integer AS
$BODY$

begin

return 16;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_tipopersonacontacto()
  RETURNS integer AS
$BODY$

begin

return 3;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_tipopersonaproveedor()
  RETURNS integer AS
$BODY$

begin

return 2;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_maestrotiporelacion()
  RETURNS integer AS
$BODY$

begin

return 21;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestrotipovia()
  RETURNS integer AS
$BODY$

begin

return 2;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestroestadocivil()
  RETURNS integer AS
$BODY$

begin

return 9;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestroformapago()
  RETURNS integer AS
$BODY$

begin

return 12;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_maestroestadopago()
  RETURNS integer AS
$BODY$

begin

return 13;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestroestadoservicio()
  RETURNS integer AS
$BODY$

begin

return 14;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestrotipomoneda()
  RETURNS integer AS
$BODY$

begin

return 18;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION fn_maestrotipocuenta()
  RETURNS integer AS
$BODY$

begin

return 19;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestrobanco()
  RETURNS integer AS
$BODY$

begin

return 8;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;



CREATE OR REPLACE FUNCTION fn_maestrodocumentoadjunto()
  RETURNS integer AS
$BODY$

begin

return 17;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


CREATE OR REPLACE FUNCTION fn_maestrotipotransaccion()
  RETURNS integer AS
$BODY$

begin

return 12;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


-- Function: soporte.fn_buscardestinos1(character varying)

-- DROP FUNCTION soporte.fn_buscardestinos1(character varying);

CREATE OR REPLACE FUNCTION soporte.fn_buscardestinos1(p_nombre character varying)
  RETURNS refcursor AS
$BODY$
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
   AND cont.idmaestro       = fn_maestrocontinente
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND tipdes.idmaestro     = fn_maestrotipodestino()
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
   AND des.descripcion      like '%'||p_nombre||'%';

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Function: soporte.fn_listardestinos()

-- DROP FUNCTION soporte.fn_listardestinos();

CREATE OR REPLACE FUNCTION soporte.fn_listardestinos()
  RETURNS refcursor AS
$BODY$
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
   AND cont.idmaestro       = fn_maestrocontinente()
   AND cont.estado          = 'A'
   AND cont.id              = des.idcontinente
   AND pai.idestadoregistro = 1
   AND pai.id               = des.idpais
   AND tipdes.idmaestro     = fn_maestrotipodestino()
   AND tipdes.estado        = 'A'
   AND tipdes.id            = des.idtipodestino
 ORDER BY des.descripcion ASC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION soporte.fn_listardestinos()
  OWNER TO postgres;

-- Function: negocio.fn_consultararchivoscargados(integer, date, date, integer, character varying)

-- DROP FUNCTION negocio.fn_consultararchivoscargados(integer, date, date, integer, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_consultararchivoscargados(p_idarchivo integer, p_fechadesde date, p_fechahasta date, p_idproveedor integer, p_nombrereporte character varying)
  RETURNS refcursor AS
$BODY$
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
   AND tmmo.idmaestro                   = fn_maestromoneda()
   AND ac.idmoneda                      = tmmo.id
   AND ac.id                            = COALESCE(p_idarchivo, ac.id)
   AND date(ac.fechacreacion)           BETWEEN p_fechadesde AND p_fechahasta
   AND ac.idproveedor                   = COALESCE(p_idproveedor, ac.idproveedor)
   AND REPLACE(ac.nombrereporte,' ','') LIKE '%'||COALESCE(p_nombrereporte,REPLACE(ac.nombrereporte,' ',''))||'%';

 return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultararchivoscargados(integer, date, date, integer, character varying)
  OWNER TO postgres;

-- Function: negocio.fn_consultarclientescumple()

-- DROP FUNCTION negocio.fn_consultarclientescumple();

CREATE OR REPLACE FUNCTION negocio.fn_consultarclientescumple()
  RETURNS refcursor AS
$BODY$
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
   and p.idtipopersona                 = fn_tipopersonacliente()
   and to_char(p.fecnacimiento,'ddMM') = to_char(current_date,'ddMM');

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarclientescumple()
  OWNER TO postgres;

-- Function: negocio.fn_consultarclientesnovios(character varying)

-- DROP FUNCTION negocio.fn_consultarclientesnovios(character varying);

CREATE OR REPLACE FUNCTION negocio.fn_consultarclientesnovios(p_genero character varying)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idpersona, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno
   FROM negocio."Persona" pro, 
        soporte."Tablamaestra" tdoc
  WHERE pro.idestadoregistro  = 1 
    AND pro.idtipopersona     = fn_tipopersonacliente()
    AND tdoc.idmaestro        = fn_maestrotipodocumento()
    AND pro.idtipodocumento   = tdoc.id
    AND pro.idgenero          = p_genero;


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarclientesnovios(character varying)
  OWNER TO postgres;

-- Function: negocio.fn_consultarclientesnovios(character varying, integer, character varying, character varying)

-- DROP FUNCTION negocio.fn_consultarclientesnovios(character varying, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_consultarclientesnovios(p_genero character varying, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT pro.id AS idpersona, tdoc.id AS idtipodocumento, 
       tdoc.nombre AS nombretipodocumento, pro.numerodocumento, pro.nombres, 
       pro.apellidopaterno, pro.apellidomaterno
   FROM negocio."Persona" pro, 
        soporte."Tablamaestra" tdoc
  WHERE pro.idestadoregistro  = 1 
    AND pro.idtipopersona     = fn_tipopersonacliente()
    AND tdoc.idmaestro        = fn_maestrotipodocumento()
    AND pro.idtipodocumento   = tdoc.id
    AND pro.idgenero          = p_genero
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND pro.numerodocumento   = COALESCE(p_numerodocumento,pro.numerodocumento)
    AND CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)))||'%';


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarclientesnovios(character varying, integer, character varying, character varying)
  OWNER TO postgres;


-- Function: negocio.fn_consultarcompbtobligcnservdethijo(integer, integer)

-- DROP FUNCTION negocio.fn_consultarcompbtobligcnservdethijo(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcompbtobligcnservdethijo(p_idservicio integer, p_iddetservicio integer)
  RETURNS refcursor AS
$BODY$
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
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
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
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacion,
       (select tm.abreviatura
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacionAbrev,
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarcompbtobligcnservdethijo(integer, integer)
  OWNER TO postgres;

-- Function: negocio.fn_consultarcomprobantesgenerados(integer, integer, integer, integer, character varying, date, date)

-- DROP FUNCTION negocio.fn_consultarcomprobantesgenerados(integer, integer, integer, integer, character varying, date, date);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcomprobantesgenerados(p_idcomprobante integer, p_idservicio integer, p_idadquiriente integer, p_idtipocomprobante integer, p_numerocomprobante character varying, p_fechadesde date, p_fechahasta date)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin
open micursor for
SELECT cg.id, cg.idservicio, cg.idtipocomprobante, tm.nombre, cg.numerocomprobante, cg.idtitular, p.nombres, p.apellidopaterno, p.apellidomaterno,
       cg.fechacomprobante, cg.totaligv, cg.totalcomprobante, cg.tienedetraccion, 
       cg.tieneretencion, cg.usuariocreacion, cg.fechacreacion, cg.ipcreacion, cg.usuariomodificacion, 
       cg.fechamodificacion, cg.ipmodificacion
  FROM negocio."ComprobanteGenerado" cg
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
ALTER FUNCTION negocio.fn_consultarcomprobantesgenerados(integer, integer, integer, integer, character varying, date, date)
  OWNER TO postgres;

-- Function: negocio.fn_consultarcomprobantesobligacionservdet(integer)

-- DROP FUNCTION negocio.fn_consultarcomprobantesobligacionservdet(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcomprobantesobligacionservdet(p_idservicio integer)
  RETURNS refcursor AS
$BODY$
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
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
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
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacion,
	(select tm.abreviatura
	  from negocio."ComprobanteObligacion" comobl,
	       negocio."ObligacionesXPagar" obli,
	       soporte."Tablamaestra" tm
	 where comobl.iddetalleservicio = serdet.id
	   and comobl.idobligacion      = obli.id
	   and obli.idtipocomprobante   = tm.id
	   and tm.estado                = 'A'
	   and tm.idmaestro             = fn_maestrotipocomprobante()) as tipoObligacionAbrev,
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarcomprobantesobligacionservdet(integer)
  OWNER TO postgres;

-- Function: negocio.fn_consultarcomprobantesserviciodetalle(integer)

-- DROP FUNCTION negocio.fn_consultarcomprobantesserviciodetalle(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcomprobantesserviciodetalle(p_idservicio integer)
  RETURNS refcursor AS
$BODY$
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
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarcomprobantesserviciodetalle(integer)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultarcompserviciodethijo(integer, integer)

-- DROP FUNCTION negocio.fn_consultarcompserviciodethijo(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcompserviciodethijo(p_idservicio integer, p_iddetserv integer)
  RETURNS refcursor AS
$BODY$
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
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteNombre,
       (select tm.abreviatura
          from negocio."DetalleComprobanteGenerado" dc,
               negocio."ComprobanteGenerado" cg,
               soporte."Tablamaestra" tm
         where dc.idserviciodetalle = serdet.id
           and dc.idcomprobante     = cg.id
           and tm.id                = cg.idtipocomprobante
           and tm.idmaestro         = fn_maestrotipocomprobante()) as tipoComprobanteAbrev,
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarcompserviciodethijo(integer, integer)
  OWNER TO postgres;

-- Function: negocio.fn_consultarcontactoxpersona(integer)

-- DROP FUNCTION negocio.fn_consultarcontactoxpersona(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarcontactoxpersona(p_idpersona integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
select per.id, per.idtipopersona, per.nombres, per.apellidopaterno, per.apellidomaterno, 
       per.idgenero, per.idestadocivil, per.idtipodocumento, per.numerodocumento
  from negocio."PersonaContactoProveedor" pcon,
       negocio."Persona" per
 where pcon.idestadoregistro = 1
   and per.idestadoregistro  = 1
   and per.idtipopersona     = fn_tipopersonacontacto()
   and pcon.idcontacto       = per.id
   and pcon.idproveedor      = p_idpersona;


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarcontactoxpersona(integer)
  OWNER TO postgres;

-- Function: negocio.fn_consultarnovios(integer, character varying, integer, integer)

-- DROP FUNCTION negocio.fn_consultarnovios(integer, character varying, integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarnovios(p_id integer, p_codnovios character varying, p_idnovia integer, p_idnovio integer)
  RETURNS refcursor AS
$BODY$
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
   AND novia.idtipopersona    = fn_tipopersonacliente()
   AND novia.id               = snov.idnovia
   AND snov.idnovia           = COALESCE(p_idnovia,snov.idnovia)
   AND novio.idestadoregistro = 1
   AND novio.idtipopersona    = fn_tipopersonacliente()
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarnovios(integer, character varying, integer, integer)
  OWNER TO postgres;


-- Function: negocio.fn_consultarobligacion(integer)

-- DROP FUNCTION negocio.fn_consultarobligacion(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarobligacion(p_idobligacion integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT oxp.id, idtipocomprobante, tmtd.nombre, numerocomprobante, idproveedor as idtitular, tit.nombres, tit.apellidopaterno, tit.apellidomaterno, fechacomprobante, 
       fechapago, detallecomprobante, totaligv, totalcomprobante, saldocomprobante, tienedetraccion, 
       tieneretencion
  FROM negocio."ObligacionesXPagar" oxp
 INNER JOIN soporte."Tablamaestra" tmtd ON tmtd.idmaestro = fn_maestrotipocomprobante() AND tmtd.id = oxp.idtipocomprobante
 INNER JOIN negocio."Persona" tit ON tit.id = oxp.idproveedor AND tit.idestadoregistro = 1
 WHERE oxp.id = p_idobligacion;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
-- Function: negocio.fn_consultarobligacionxpagar(integer, character varying, integer)

-- DROP FUNCTION negocio.fn_consultarobligacionxpagar(integer, character varying, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarobligacionxpagar(p_idtipocomprobante integer, p_numerocomprobante character varying, p_idproveedor integer)
  RETURNS refcursor AS
$BODY$
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
   and tm.idmaestro          = fn_maestrotipocomprobante()
   and pro.idestadoregistro  = 1
   and pro.idtipopersona     = fn_tipopersonaproveedor()
   and pro.id                = oxp.idproveedor
   and oxp.idtipocomprobante = COALESCE(p_idtipocomprobante,oxp.idtipocomprobante)
   and oxp.numerocomprobante = COALESCE(p_numerocomprobante,oxp.numerocomprobante)
   and oxp.idproveedor       = COALESCE(p_idproveedor,oxp.idproveedor);

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarobligacionxpagar(integer, character varying, integer)
  OWNER TO postgres;


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
 INNER JOIN soporte."Tablamaestra" tmre ON tmre.idmaestro = fn_maestrotiporelacion()  AND tmre.id = ps.idrelacion
 INNER JOIN soporte."Tablamaestra" tmdi ON tmdi.idmaestro = fn_maestrotipodocumento() AND tmdi.id = ps.idtipodocumento
 WHERE idserviciodetalle = p_idserviciodetalle;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarpasajeros(integer)
  OWNER TO postgres;


-- Function: negocio.fn_consultarpersonas(integer, integer, character varying, character varying)

-- DROP FUNCTION negocio.fn_consultarpersonas(integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpersonas(p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying)
  RETURNS refcursor AS
$BODY$
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
  INNER JOIN soporte."Tablamaestra" tdoc     ON tdoc.idmaestro        = fn_maestrotipodocumento() AND pro.idtipodocumento = tdoc.id
   LEFT JOIN negocio."PersonaDireccion" pdir ON pdir.idestadoregistro = 1 AND pro.id              = pdir.idpersona
   LEFT JOIN negocio."Direccion" dir         ON dir.idestadoregistro  = 1 AND pdir.iddireccion    = dir.id AND dir.principal = 'S'
   LEFT JOIN soporte."Tablamaestra" tvia     ON tvia.idmaestro        = fn_maestrotipovia() AND dir.idvia           = tvia.id
  WHERE pro.idestadoregistro  = 1 
    AND pro.idtipopersona     = COALESCE(p_idtipopersona,pro.idtipopersona)
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND pro.numerodocumento   = COALESCE(p_numerodocumento,pro.numerodocumento)
    AND CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(pro.nombres,' ',''),trim(pro.apellidopaterno),trim(pro.apellidomaterno)))||'%';

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarpersonas(integer, integer, character varying, character varying)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultarpersonas2(integer, integer, character varying, character varying)

-- DROP FUNCTION negocio.fn_consultarpersonas2(integer, integer, character varying, character varying);

CREATE OR REPLACE FUNCTION negocio.fn_consultarpersonas2(p_idtipopersona integer, p_idtipodocumento integer, p_numerodocumento character varying, p_nombres character varying)
  RETURNS refcursor AS
$BODY$
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
   LEFT JOIN soporte."Tablamaestra" estciv ON estciv.idmaestro = fn_maestroestadocivil() AND estciv.id = per.idestadocivil
  WHERE per.idestadoregistro  = 1 
    AND per.idtipopersona     = fn_tipopersonacliente()
    AND tdoc.idmaestro        = fn_maestrotipodocumento() 
    AND per.idtipodocumento   = tdoc.id
    AND tdoc.id               = COALESCE(p_idtipodocumento,tdoc.id)
    AND per.numerodocumento   = COALESCE(p_numerodocumento,per.numerodocumento)
    AND CONCAT(replace(per.nombres,' ',''),trim(per.apellidopaterno),trim(per.apellidomaterno)) like '%'||COALESCE(p_nombres,CONCAT(replace(per.nombres,' ',''),trim(per.apellidopaterno),trim(per.apellidomaterno)))||'%';


return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarpersonas2(integer, integer, character varying, character varying)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultarservicioventa(integer, character varying, character varying, integer)

-- DROP FUNCTION negocio.fn_consultarservicioventa(integer, character varying, character varying, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventa(p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer)
  RETURNS refcursor AS
$BODY$
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
 inner join soporte."Tablamaestra" maemp on maemp.estado = 'A' and maemp.idmaestro = fn_maestroformapago() and maemp.id = sercab.idformapago
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = fn_maestroestadopago() and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and cli1.idtipodocumento    = COALESCE(p_tipodocumento,cli1.idtipodocumento)
   and cli1.numerodocumento    = COALESCE(p_numerodocumento,cli1.numerodocumento)
   and UPPER(CONCAT(replace(cli1.nombres,' ',''),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno))) like UPPER('%'||COALESCE(p_nombres,CONCAT(trim(replace(cli1.nombres,' ','')),trim(cli1.apellidopaterno),trim(cli1.apellidomaterno)))||'%')
   and sercab.idvendedor       = COALESCE(p_idvendedor,sercab.idvendedor);
	
return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarservicioventa(integer, character varying, character varying, integer)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultarservicioventa(integer)

-- DROP FUNCTION negocio.fn_consultarservicioventa(integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventa(p_idservicio integer)
  RETURNS refcursor AS
$BODY$
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
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = fn_maestroestadopago() and maeep.id = sercab.idestadopago
 inner join seguridad.usuario usu on usu.id = sercab.idvendedor
  left join negocio.vw_clientesnova cli2 on sercab.idcliente2 = cli2.id
 where sercab.idestadoregistro = 1
   and (select count(1) from negocio."ServicioDetalle" det where det.idservicio = sercab.id) > 0
   and sercab.id               = p_idservicio;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarservicioventa(integer)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultarservicioventa(integer, character varying, character varying, integer, integer, date, date)

-- DROP FUNCTION negocio.fn_consultarservicioventa(integer, character varying, character varying, integer, integer, date, date);

CREATE OR REPLACE FUNCTION negocio.fn_consultarservicioventa(p_tipodocumento integer, p_numerodocumento character varying, p_nombres character varying, p_idvendedor integer, p_idservicio integer, p_fechadesde date, p_fechahasta date)
  RETURNS refcursor AS
$BODY$
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
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = fn_maestroestadopago() and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
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
 inner join soporte."Tablamaestra" maeep on maeep.estado = 'A' and maeep.idmaestro = fn_maestroestadopago() and maeep.id = sercab.idestadopago
 inner join soporte."Tablamaestra" maest on maest.estado = 'A' and maest.idmaestro = fn_maestroestadoservicio() and maest.id = sercab.idestadoservicio
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultarservicioventa(integer, character varying, character varying, integer, integer, date, date)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultartipocambio(integer, integer)

-- DROP FUNCTION negocio.fn_consultartipocambio(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultartipocambio(p_idmonedaorigen integer, p_idmonedadestino integer)
  RETURNS refcursor AS
$BODY$

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
                                           where idmaestro = fn_maestrotipomoneda()
                                             and id        = p_idmonedaorigen);
        v_mensaje = v_mensaje || ' a ' || (select nombre
                                           from soporte."Tablamaestra" 
                                          where idmaestro = fn_maestrotipomoneda()
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
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = idmonedaorigen
 INNER JOIN soporte."Tablamaestra" tmmd ON tmmd.idmaestro = fn_maestrotipomoneda() AND tmmd.id = idmonedadestino
 WHERE tc.id = v_idtipocambio;

 return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultartipocambio(integer, integer)
  OWNER TO postgres;

  
-- Function: negocio.fn_consultartipocambiomonto(integer, integer)

-- DROP FUNCTION negocio.fn_consultartipocambiomonto(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultartipocambiomonto(p_idmonedaorigen integer, p_idmonedadestino integer)
  RETURNS numeric AS
$BODY$

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
                                           where idmaestro = fn_maestrotipomoneda()
                                             and id        = p_idmonedaorigen);
        v_mensaje = v_mensaje + ' a ' + (select nombre
                                           from soporte."Tablamaestra" 
                                          where idmaestro = fn_maestrotipomoneda()
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_consultartipocambiomonto(integer, integer)
  OWNER TO postgres;

  
-- Function: negocio.fn_listarcuentasbancarias()

-- DROP FUNCTION negocio.fn_listarcuentasbancarias();

CREATE OR REPLACE FUNCTION negocio.fn_listarcuentasbancarias()
  RETURNS refcursor AS
$BODY$

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
   AND tmtc.idmaestro   = fn_maestrotipocuenta()
   AND cb.idtipocuenta  = tmtc.id
   AND tmba.idmaestro   = fn_maestrobanco()
   AND cb.idbanco       = tmba.id
   AND tmmo.idmaestro   = fn_maestrotipomoneda()
   AND cb.idmoneda      = tmmo.id;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_listarcuentasbancarias()
  OWNER TO postgres;

-- Function: negocio.fn_listardocumentosadicionales(integer)

-- DROP FUNCTION negocio.fn_listardocumentosadicionales(integer);

CREATE OR REPLACE FUNCTION negocio.fn_listardocumentosadicionales(p_idservicio integer)
  RETURNS refcursor AS
$BODY$

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
   and tm.idmaestro        = fn_maestrodocumentoadjunto();

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
  
-- Function: negocio.fn_listarmovimientosxcuenta(integer)

-- DROP FUNCTION negocio.fn_listarmovimientosxcuenta(integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarmovimientosxcuenta(p_idcuenta integer)
  RETURNS refcursor AS
$BODY$

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
 INNER JOIN soporte."Tablamaestra" tmtt ON tmtt.idmaestro      = fn_maestrotipotransaccion() AND tmtt.id     = idtransaccion
 WHERE mc.idcuenta = p_idcuenta;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_listarmovimientosxcuenta(integer)
  OWNER TO postgres;


-- Function: negocio.fn_listarpagos(integer)

-- DROP FUNCTION negocio.fn_listarpagos(integer);

CREATE OR REPLACE FUNCTION negocio.fn_listarpagos(p_idservicio integer)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT idpago, idservicio, ps.idformapago, tmfp.nombre as nombreformapago, fechapago, montopagado, sustentopago, nombrearchivo, extensionarchivo, tipocontenido, espagodetraccion, espagoretencion, usuariocreacion, 
       fechacreacion, ipcreacion, usuariomodificacion, fechamodificacion, 
       ipmodificacion
  FROM negocio."PagosServicio" ps
 INNER JOIN soporte."Tablamaestra" tmfp ON ps.idformapago = tmfp.id AND tmfp.idmaestro = fn_maestroformapago()
 WHERE idestadoregistro = 1
   AND idservicio       = p_idservicio
 ORDER BY idpago DESC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_listarpagos(integer)
  OWNER TO postgres;


-- Function: negocio.fn_listartipocambio(date)

-- DROP FUNCTION negocio.fn_listartipocambio(date);

CREATE OR REPLACE FUNCTION negocio.fn_listartipocambio(p_fecha date)
  RETURNS refcursor AS
$BODY$

declare micursor refcursor;

begin

open micursor for
SELECT tc.id, fechatipocambio, 
       idmonedaorigen, tmmo.nombre as nombreMonOrigen, 
       idmonedadestino, tmmd.nombre as nombreMonDestino, 
       montocambio
  FROM negocio."TipoCambio" tc
 INNER JOIN soporte."Tablamaestra" tmmo ON tmmo.idmaestro = fn_maestrotipomoneda() AND tmmo.id = idmonedaorigen
 INNER JOIN soporte."Tablamaestra" tmmd ON tmmd.idmaestro = fn_maestrotipomoneda() AND tmmd.id = idmonedadestino
 WHERE fechatipocambio = COALESCE(p_fecha,fechatipocambio)
 ORDER BY tc.id DESC;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_listartipocambio(date)
  OWNER TO postgres;

  
-- Function: negocio.fn_proveedorxservicio(integer)

-- DROP FUNCTION negocio.fn_proveedorxservicio(integer);

CREATE OR REPLACE FUNCTION negocio.fn_proveedorxservicio(p_idservicio integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin

open micursor for
SELECT per.id, per.nombres, proser.porcencomnacional, proser.porcencominternacional
  FROM negocio."Persona" per,
       negocio."ProveedorTipoServicio" proser
 WHERE per.idestadoregistro    = 1 
   AND proser.idestadoregistro = 1 
   AND per.idtipopersona       = fn_tipopersonaproveedor()
   AND per.id                  = proser.idproveedor
   AND proser.idtiposervicio   = p_idservicio;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION negocio.fn_proveedorxservicio(integer)
  OWNER TO postgres;

  
