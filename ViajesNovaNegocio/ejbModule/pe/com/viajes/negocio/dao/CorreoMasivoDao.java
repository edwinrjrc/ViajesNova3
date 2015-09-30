/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.negocio.CorreoClienteMasivo;

/**
 * @author Edwin
 *
 */
public interface CorreoMasivoDao {

	public List<CorreoClienteMasivo> listarClientesCorreo() throws SQLException;

}
