/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.recursoshumanos.UsuarioAsistencia;

/**
 * @author Edwin
 *
 */
public interface AuditoriaDao {

	/**
	 * Metodo que registrar el evento de sesion del sistema
	 * 
	 * @param usuario
	 * @param tipoEvento
	 * @return
	 * @throws SQLException
	 */
	public boolean registrarEventoSesion(Usuario usuario, Integer tipoEvento)
			throws SQLException;

	/**
	 * 
	 * @param fecha
	 * @return
	 * @throws SQLException
	 */
	public List<UsuarioAsistencia> listarHoraEntradaXDia(Date fecha)
			throws SQLException;
}
