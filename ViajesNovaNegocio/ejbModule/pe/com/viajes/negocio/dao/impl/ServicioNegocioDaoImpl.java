/**
 * 
 */
package pe.com.viajes.negocio.dao.impl;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

import org.apache.commons.lang3.StringUtils;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.jasper.DetalleServicio;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.reportes.CheckIn;
import pe.com.viajes.bean.util.UtilParse;
import pe.com.viajes.negocio.dao.ServicioNegocioDao;
import pe.com.viajes.negocio.util.UtilConexion;
import pe.com.viajes.negocio.util.UtilJdbc;

/**
 * @author edwreb
 *
 */
public class ServicioNegocioDaoImpl implements ServicioNegocioDao {

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.negocio.dao.ServicioNegocioDao#calcularCuota(pe.com.
	 * logistica.bean.negocio.ServicioAgencia)
	 */
	@Override
	public BigDecimal calcularCuota(ServicioAgencia servicioAgencia)
			throws SQLException {
		BigDecimal resultado = BigDecimal.ZERO;
		Connection conn = null;
		CallableStatement cs = null;
		String sql = "{ ? = call negocio.fn_calcularcuota(?,?,?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.DECIMAL);
			cs.setBigDecimal(i++, servicioAgencia.getMontoTotalServicios());
			cs.setBigDecimal(i++, UtilParse.parseIntABigDecimal(servicioAgencia
					.getNroCuotas()));
			cs.setBigDecimal(i++, servicioAgencia.getTea());
			cs.execute();

			resultado = cs.getBigDecimal(1);
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally {
			try {
				if (cs != null) {
					cs.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (SQLException e) {
				throw new SQLException(e);
			}
		}
		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.ServicioNegocioDao#proveedoresXServicio(pe.com.viajes.bean.base.BaseVO)
	 */
	@Override
	public List<ServicioProveedor> proveedoresXServicio(BaseVO servicio)
			throws SQLException {
		List<ServicioProveedor> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "{ ? = call negocio.fn_proveedorxservicio(?) }";

		try {
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			int i = 1;
			cs.registerOutParameter(i++, Types.OTHER);
			cs.setInt(i++, servicio.getCodigoEntero().intValue());
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<ServicioProveedor>();
			ServicioProveedor servicio2 = null;
			while (rs.next()) {
				servicio2 = new ServicioProveedor();
				servicio2.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				servicio2.setNombreProveedor(UtilJdbc.obtenerCadena(rs,
						"nombres"));
				servicio2.setPorcentajeComision(UtilJdbc.obtenerBigDecimal(rs,
						"porcencomnacional"));
				servicio2.setPorcenComInternacional(UtilJdbc.obtenerBigDecimal(
						rs, "porcencominternacional"));
				resultado.add(servicio2);
			}
		} catch (SQLException e) {
			throw new SQLException(e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (cs != null) {
					cs.close();
				}
				if (conn != null) {
					conn.close();
				}
			} catch (SQLException e) {
				throw new SQLException(e);
			}
		}
		return resultado;
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.ServicioNegocioDao#consultarServicioVentaJR(java.lang.Integer)
	 */
	@Override
	public List<DetalleServicio> consultarServicioVentaJR(Integer idServicio)
			throws SQLException {
		List<DetalleServicio> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		try {
			sql = "{ ? = call negocio.fn_consultarservicioventajr(?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idServicio);
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			DetalleServicio detalle = null;
			resultado = new ArrayList<DetalleServicio>();
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			DecimalFormatSymbols decimalSymbols = null;
			DecimalFormat df = null;
			Date fechaIda = null;
			BigDecimal precio = null;
			BigDecimal total = null;
			while (rs.next()) {
				detalle = new DetalleServicio();
				detalle.setCantidad(UtilJdbc.obtenerCadena(rs, "cantidad"));
				detalle.setDescripcionServicio(UtilJdbc.obtenerCadena(rs,
						"descripcionservicio"));
				fechaIda = UtilJdbc.obtenerFecha(rs, "fechaida");
				detalle.setFechaIda(sdf.format(fechaIda));

				decimalSymbols = new DecimalFormatSymbols(Locale.US);
				String pattern = "###,##0.00";
				String simboloMoneda = UtilJdbc
						.obtenerCadena(rs, "abreviatura");
				pattern = simboloMoneda + " " + pattern;
				df = new DecimalFormat(pattern, decimalSymbols);
				precio = UtilJdbc.obtenerBigDecimal(rs, "preciobase");
				detalle.setPrecioUnitario(df.format(precio.doubleValue()));
				total = UtilJdbc.obtenerBigDecimal(rs, "montototal");
				detalle.setTotal(df.format(total.doubleValue()));
				resultado.add(detalle);
			}

			return resultado;
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException(e);
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (cs != null) {
				cs.close();
			}
			if (conn != null) {
				conn.close();
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.ServicioNegocioDao#consultarCheckInPendientes()
	 */
	@Override
	public List<CheckIn> consultarcheckinpendientes(Date fechaHasta, Integer idVendedor) throws SQLException {
		List<CheckIn> resultado = null;
		Connection conn = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		try {
			sql = "{ ? = call negocio.fn_consultarcheckinpendientes(?, ?) }";
			conn = UtilConexion.obtenerConexion();
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setTimestamp(2, UtilJdbc.convertirUtilDateTimeStamp(fechaHasta));
			if (idVendedor != null && idVendedor.intValue() != 0){
				cs.setInt(3, idVendedor.intValue());
			}
			else{
				cs.setNull(3, Types.INTEGER);
			}
			cs.execute();

			rs = (ResultSet) cs.getObject(1);
			CheckIn checkIn = null;
			resultado = new ArrayList<CheckIn>();
			
			while (rs.next()) {
				checkIn = new CheckIn();
				checkIn.setIdServicio(UtilJdbc.obtenerNumero(rs, "id"));
				checkIn.getCliente().setNombre(UtilJdbc.obtenerCadena(rs, "nombrecliente"));
				checkIn.getOrigen().setNombre(UtilJdbc.obtenerCadena(rs, "descripcionorigen"));
				checkIn.getDestino().setNombre(UtilJdbc.obtenerCadena(rs, "descripciondestino"));
				checkIn.setFechaSalida(UtilJdbc.obtenerFechaTimestamp(rs, "fechasalida"));
				checkIn.setFechaLlegada(UtilJdbc.obtenerFechaTimestamp(rs, "fechallegada"));
				checkIn.getAerolinea().setNombre(UtilJdbc.obtenerCadena(rs, "nombreaerolinea"));
				checkIn.setCodigoReserva(UtilJdbc.obtenerCadena(rs, "codigoreserva"));
				checkIn.setNumeroBoleto(UtilJdbc.obtenerCadena(rs, "numeroboleto"));
				checkIn.setIdServicioDetalle(UtilJdbc.obtenerNumero(rs, "iddetalle"));
				checkIn.setIdTramo(UtilJdbc.obtenerNumero(rs, "idtramo"));
				checkIn.setIdRuta(UtilJdbc.obtenerNumero(rs, "idruta"));
				
				resultado.add(checkIn);
			}

			return resultado;
		} catch (SQLException e) {
			e.printStackTrace();
			throw new SQLException(e);
		} finally {
			if (rs != null) {
				rs.close();
			}
			if (cs != null) {
				cs.close();
			}
			if (conn != null) {
				conn.close();
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.ServicioNegocioDao#ingresarPasajero(pe.com.viajes.bean.negocio.Pasajero)
	 */
	@Override
	public Integer ingresarPasajero(Pasajero pasajero, Connection conn) throws SQLException {
		CallableStatement cs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call negocio.fn_ingresarpasajero(?,?,?,?,?,?,?,?,?,?,?,?,?)}";
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.INTEGER);
			cs.setString(2, pasajero.getNombres());
			cs.setString(3, pasajero.getApellidoPaterno());
			if (StringUtils.isNotBlank(pasajero.getApellidoMaterno())){
				cs.setString(4, pasajero.getApellidoMaterno());
			}
			else{
				cs.setNull(4, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(pasajero.getCorreoElectronico())){
				cs.setString(5, pasajero.getCorreoElectronico());
			}
			else{
				cs.setNull(5, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(pasajero.getTelefono1())){
				cs.setString(6, pasajero.getTelefono1());
			}
			else{
				cs.setNull(6, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(pasajero.getTelefono2())){
				cs.setString(7, pasajero.getTelefono2());
			}
			else{
				cs.setNull(7, Types.VARCHAR);
			}
			if (StringUtils.isNotBlank(pasajero.getNumeroPasajeroFrecuente())){
				cs.setString(8, pasajero.getNumeroPasajeroFrecuente());
			}
			else{
				cs.setNull(8, Types.VARCHAR);
			}
			cs.setInt(9, pasajero.getRelacion().getCodigoEntero().intValue());
			if (pasajero.getAerolinea().getCodigoEntero() != null && pasajero.getAerolinea().getCodigoEntero().intValue() != 0){
				cs.setInt(10, pasajero.getAerolinea().getCodigoEntero().intValue());
			}
			else {
				cs.setNull(10, Types.INTEGER);
			}
			cs.setInt(11, pasajero.getIdServicioDetalle().intValue());
			cs.setInt(12, pasajero.getIdServicio().intValue());
			cs.setString(13, pasajero.getUsuarioCreacion());
			cs.setString(14, pasajero.getIpCreacion());
			cs.execute();
			
			return cs.getInt(1);
		}
		catch (SQLException e){
			throw new SQLException(e);
		}
		finally {
			if (cs != null){
				cs.close();
			}
		}
	}

	/*
	 * (non-Javadoc)
	 * @see pe.com.viajes.negocio.dao.ServicioNegocioDao#consultarPasajeros(pe.com.viajes.bean.negocio.DetalleServicioAgencia)
	 */
	@Override
	public List<Pasajero> consultarPasajeros(
			Integer idServicioDetalle, Connection conn) throws SQLException {
		List<Pasajero> resultado = null;
		CallableStatement cs = null;
		ResultSet rs = null;
		String sql = "";
		
		try{
			sql = "{ ? = call negocio.fn_consultarpasajeros(?)}";
			cs = conn.prepareCall(sql);
			cs.registerOutParameter(1, Types.OTHER);
			cs.setInt(2, idServicioDetalle.intValue());
			cs.execute();
			
			rs = (ResultSet) cs.getObject(1);
			resultado = new ArrayList<Pasajero>();
			Pasajero pasajero = null;
			while (rs.next()){
				pasajero = new Pasajero();
				pasajero.setCodigoEntero(UtilJdbc.obtenerNumero(rs, "id"));
				pasajero.setNombres(UtilJdbc.obtenerCadena(rs, "nombres"));
				pasajero.setApellidoPaterno(UtilJdbc.obtenerCadena(rs, "apellidopaterno"));
				pasajero.setApellidoMaterno(UtilJdbc.obtenerCadena(rs, "apellidopaterno"));
				pasajero.setTelefono1(UtilJdbc.obtenerCadena(rs, "telefono1"));
				pasajero.setTelefono2(UtilJdbc.obtenerCadena(rs, "telefono2"));
				pasajero.setCorreoElectronico(UtilJdbc.obtenerCadena(rs, "correoelectronico"));
				pasajero.setNumeroPasajeroFrecuente(UtilJdbc.obtenerCadena(rs, "nropaxfrecuente"));
				pasajero.getAerolinea().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idaerolinea"));
				pasajero.getAerolinea().setNombre(UtilJdbc.obtenerCadena(rs, "nombreaerolina"));
				pasajero.getRelacion().setCodigoEntero(UtilJdbc.obtenerNumero(rs, "idrelacion"));
				pasajero.getRelacion().setNombre(UtilJdbc.obtenerCadena(rs, "nombrerelacion"));
				
				resultado.add(pasajero);
			}
			
			return resultado;
		}
		catch (SQLException e){
			e.printStackTrace();
			throw new SQLException (e);
		}
		finally{
			if (rs != null){
				rs.close();
			}
			if (cs != null){
				cs.close();
			}
		}
	}
}
