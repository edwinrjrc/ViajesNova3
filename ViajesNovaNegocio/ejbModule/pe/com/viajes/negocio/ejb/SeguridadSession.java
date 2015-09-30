package pe.com.viajes.negocio.ejb;

import java.sql.SQLException;
import java.util.List;

import javax.ejb.EJB;
import javax.ejb.Stateless;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.negocio.dao.CatalogoDao;
import pe.com.viajes.negocio.dao.UsuarioDao;
import pe.com.viajes.negocio.dao.impl.CatalogoDaoImpl;
import pe.com.viajes.negocio.dao.impl.UsuarioDaoImpl;
import pe.com.viajes.negocio.exception.ConnectionException;
import pe.com.viajes.negocio.exception.ErrorEncriptacionException;
import pe.com.viajes.negocio.exception.InicioSesionException;

/**
 * Session Bean implementation class Seguridad
 */
@Stateless(name = "SeguridadSession")
public class SeguridadSession implements SeguridadRemote, SeguridadLocal {

	UsuarioDao usuarioDao = null;
	CatalogoDao catalogoDao = null;

	@EJB
	AuditoriaSessionLocal auditoriaSessionLocal;

	@Override
	public boolean registrarUsuario(Usuario usuario) throws SQLException,
			ErrorEncriptacionException {
		usuarioDao = new UsuarioDaoImpl();
		return usuarioDao.registrarUsuario(usuario);
	}

	@Override
	public List<Usuario> listarUsuarios() throws SQLException {
		usuarioDao = new UsuarioDaoImpl();
		return usuarioDao.listarUsuarios();
	}

	@Override
	public List<BaseVO> listarRoles() throws ConnectionException, SQLException {
		catalogoDao = new CatalogoDaoImpl();
		return catalogoDao.listarRoles();
	}

	@Override
	public Usuario consultarUsuario(int id) throws SQLException {
		usuarioDao = new UsuarioDaoImpl();
		return usuarioDao.consultarUsuario(id);
	}

	@Override
	public boolean actualizarUsuario(Usuario usuario) throws SQLException {
		usuarioDao = new UsuarioDaoImpl();
		return usuarioDao.actualizarUsuario(usuario);
	}

	@Override
	public Usuario inicioSesion(Usuario usuario) throws InicioSesionException,
			SQLException, Exception {
		usuarioDao = new UsuarioDaoImpl();
		usuario = usuarioDao.inicioSesion2(usuario);

		if (!usuario.isEncontrado()) {
			throw new InicioSesionException(
					"El usuario y la contraseña son incorrectas");
		}

		try {
			auditoriaSessionLocal.registrarEventoInicioSession(usuario);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return usuario;
	}

	@Override
	public boolean cambiarClaveUsuario(Usuario usuario) throws SQLException,
			Exception {
		usuarioDao = new UsuarioDaoImpl();

		Usuario usuario2 = usuarioDao.inicioSesion2(usuario);
		usuario2.setCredencialNueva(usuario.getCredencialNueva());
		if (!usuario2.isEncontrado()) {
			throw new SQLException("Informacion de usuario incorrecta");
		}

		return usuarioDao.actualizarClaveUsuario(usuario2);
	}

	@Override
	public boolean actualizarClaveUsuario(Usuario usuario) throws SQLException,
			Exception {
		usuarioDao = new UsuarioDaoImpl();

		return usuarioDao.actualizarClaveUsuario(usuario);
	}

	@Override
	public List<Usuario> listarVendedores() throws SQLException {
		usuarioDao = new UsuarioDaoImpl();
		return usuarioDao.listarVendedores();
	}

	@Override
	public boolean actualizarCredencialVencida(Usuario usuario)
			throws SQLException, Exception {
		usuarioDao = new UsuarioDaoImpl();

		Usuario usuarioLocal = usuarioDao.inicioSesion2(usuario);

		if (usuarioLocal.isEncontrado()) {

		}

		return usuarioDao.actualizarCredencialVencida(usuario);
	}
}
