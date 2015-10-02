
-- Function: negocio.fn_consultarpersona(integer, integer)

-- DROP FUNCTION negocio.fn_consultarpersona(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_consultarnombrepersona(p_id integer, p_idtipopersona integer)
  RETURNS character varying AS
$BODY$
declare v_nombre character varying(50);

begin

SELECT trim(COALESCE(pro.nombres,' ')||' '||COALESCE(pro.apellidopaterno,' ')||' '||COALESCE(pro.apellidomaterno,' '))
  INTO v_nombre
  FROM negocio."Persona" pro
 WHERE pro.idtipopersona = COALESCE(p_idtipopersona,pro.idtipopersona)
   AND pro.id            = p_id;


return v_nombre;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION negocio.fn_consultarcheckinpendientes(p_fechahasta timestamp)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin
open micursor for
select sc.id, 
       negocio.fn_consultarnombrepersona(sc.idcliente1,1) as nombrecliente,
       t.descripcionorigen, t.descripciondestino, t.fechasalida, t.fechallegada, 
       negocio.fn_consultarnombrepersona(t.idaerolinea,null) as nombreaerolinea,
       sd.codigoreserva, sd.numeroboleto
  from negocio."Tramo" t
 inner join negocio."RutaServicio" r      on r.idtramo = t.id
 inner join negocio."ServicioDetalle" sd  on sd.idruta = r.id
 inner join negocio."ServicioCabecera" sc on sc.id     = sd.idservicio
 where t.fechasalida between current_timestamp and p_fechahasta;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
  
-- Function: negocio.fn_consultarcompbtobligcnservdethijo(integer, integer)

-- DROP FUNCTION negocio.fn_consultarcompbtobligcnservdethijo(integer, integer);

CREATE OR REPLACE FUNCTION negocio.fn_generaimparchivocargado(p_idarchivocargado integer)
  RETURNS refcursor AS
$BODY$
declare micursor refcursor;

begin
open micursor for
select p.nombres, p.apellidopaterno, sd.numeroboleto
  from negocio."ArchivoCargado" ac 
 inner join negocio."DetalleArchivoCargado" dac on ac.id = dac.idarchivo and dac.seleccionado = true
 inner join negocio."ServicioDetalle" sd on dac.campo2 = sd.codigoreserva
 inner join negocio."ServicioCabecera" sc on sd.idservicio = sc.id
 inner join negocio."Persona" p on sc.idcliente1 = p.id and p.idestadoregistro = 1
 where ac.id = p_idarchivocargado;

return micursor;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
