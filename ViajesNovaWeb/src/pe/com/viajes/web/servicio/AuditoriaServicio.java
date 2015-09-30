/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;

/**
 * @author EDWREB
 *
 */
public interface AuditoriaServicio {

	/**
	 * 
	 * @param fecha
	 * @return
	 * @throws ErrorConsultaDataException
	 */
	public List<UsuarioAsistencia> consultarHorarioAsistenciaXDia(Date fecha)
			throws ErrorConsultaDataException;
}
