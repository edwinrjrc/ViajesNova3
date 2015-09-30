/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.negocio.exception.ConnectionException;

/**
 * @author Edwin
 *
 */
public interface CatalogoDao {

	public List<BaseVO> listarRoles() throws ConnectionException, SQLException;

	public List<BaseVO> listarCatalogoMaestro(int maestro)
			throws ConnectionException, SQLException;

	public List<BaseVO> listaDepartamento() throws ConnectionException,
			SQLException;

	public List<BaseVO> listaProvincia(String idDepartamento)
			throws ConnectionException, SQLException;

	public List<BaseVO> listaDistrito(String idDepartamento, String idProvincia)
			throws ConnectionException, SQLException;
}
