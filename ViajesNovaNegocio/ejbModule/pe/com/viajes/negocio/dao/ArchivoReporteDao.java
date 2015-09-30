/**
 * 
 */
package pe.com.viajes.negocio.dao;

import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;

import pe.com.viajes.bean.cargaexcel.ColumnasExcel;
import pe.com.viajes.bean.cargaexcel.ReporteArchivo;
import pe.com.viajes.bean.cargaexcel.ReporteArchivoBusqueda;

/**
 * @author Edwin
 *
 */
public interface ArchivoReporteDao {

	/**
	 * 
	 * @param reporteArchivo
	 * @param conn
	 * @return
	 * @throws SQLException
	 */
	public Integer registrarArchivoReporteCabecera(
			ReporteArchivo reporteArchivo, Connection conn) throws SQLException;

	/**
	 * 
	 * @param columnasExcel
	 * @param conn
	 * @return
	 * @throws SQLException
	 * @throws Exception
	 */
	public boolean registrarDetalleArchivoReporte(ColumnasExcel columnasExcel,
			Connection conn) throws SQLException, Exception;

	/**
	 * 
	 * @param reporteBusqueda
	 * @return
	 * @throws SQLException
	 * @throws Exception
	 */
	public List<ReporteArchivoBusqueda> consultarArchivosCargados(
			ReporteArchivoBusqueda reporteBusqueda) throws SQLException,
			Exception;

}
