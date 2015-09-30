package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.Local;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.InicioSesionException;

@Local
public interface SeguridadLocal {

	boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException;

	List<Usuario> listarUsuarios() throws SQLException;

	List<BaseVO> listarRoles() throws ConnectionException, SQLException;

	Usuario consultarUsuario(int id) throws SQLException;

	boolean actualizarUsuario(Usuario usuario) throws SQLException;

	Usuario inicioSesion(Usuario usuario) throws InicioSesionException,
			SQLException, Exception;

	boolean cambiarClaveUsuario(Usuario usuario) throws SQLException, Exception;

	boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception;

	public List<Usuario> listarVendedores() throws SQLException;

	boolean actualizarCredencialVencida(Usuario usuario) throws SQLException,
			Exception;
}
