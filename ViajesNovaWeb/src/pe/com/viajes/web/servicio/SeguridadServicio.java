/**
 * 
 */
package pe.com.viajes.web.servicio;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.InicioSesionException;

/**
 * @author Edwin
 *
 */
public interface SeguridadServicio {

	public boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	public List<Usuario> listarUsuarios() throws SQLException;

	public List<BaseVO> listarRoles() throws ConnectionException, SQLException;

	public Usuario consultarUsuario(int id) throws SQLException;

	boolean actualizarUsuario(Usuario usuario) throws SQLException;

	Usuario inicioSesion(Usuario usuario) throws InicioSesionException,
			SQLException, Exception;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException, Exception;

	boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception;

	List<Usuario> listarVendedores() throws SQLException;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			Exception;
}
