/**
 * 
 */
package pe.com.viajes.web.servicio.impl;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;

import pe.com.viajes.bean.base.BaseVO;
import pe.com.viajes.bean.cargaexcel.ReporteArchivoBusqueda;
import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.Consolidador;
import pe.com.viajes.bean.negocio.CorreoClienteMasivo;
import pe.com.viajes.bean.negocio.CuentaBancaria;
import pe.com.viajes.bean.negocio.CuotaPago;
import pe.com.viajes.bean.negocio.DetalleServicioAgencia;
import pe.com.viajes.bean.negocio.DocumentoAdicional;
import pe.com.viajes.bean.negocio.ImpresionArchivoCargado;
import pe.com.viajes.bean.negocio.MaestroServicio;
import pe.com.viajes.bean.negocio.MovimientoCuenta;
import pe.com.viajes.bean.negocio.PagoServicio;
import pe.com.viajes.bean.negocio.Pasajero;
import pe.com.viajes.bean.negocio.ProgramaNovios;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.bean.negocio.ServicioAgencia;
import pe.com.viajes.bean.negocio.ServicioAgenciaBusqueda;
import pe.com.viajes.bean.negocio.ServicioProveedor;
import pe.com.viajes.bean.negocio.TipoCambio;
import pe.com.viajes.bean.negocio.Usuario;
import pe.com.viajes.bean.reportes.CheckIn;
import pe.com.viajes.negocio.ejb.ConsultaNegocioSessionRemote;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;

/**
 * @author EDWREB
 *
 */
public class ConsultaNegocioServicioImpl implements ConsultaNegocioServicio {

	ConsultaNegocioSessionRemote ejbSession;

	final String ejbBeanName = "ConsultaNegocioSession";

	public ConsultaNegocioServicioImpl(ServletContext context)
			throws NamingException {

		Properties props = new Properties();
		/*
		 * props.setProperty("java.naming.factory.initial",
		 * "org.jnp.interfaces.NamingContextFactory");
		 * props.setProperty("java.naming.factory.url.pkgs",
		 * "org.jboss.naming"); props.setProperty("java.naming.provider.url",
		 * "localhost:1099");
		 */
		props.put(Context.URL_PKG_PREFIXES, "org.jboss.ejb.client.naming");

		Context ctx = new InitialContext(props);
		// String lookup =
		// "ejb:Logistica1EAR/Logistica1Negocio/SeguridadSession!pe.com.viajes.negocio.ejb.SeguridadRemote";
		String lookup = "java:jboss/exported/Logistica1EAR/Logistica1Negocio/NegocioSession!pe.com.viajes.negocio.ejb.ConsultaNegocioSessionRemote";

		final String ejbRemoto = ConsultaNegocioSessionRemote.class.getName();
		lookup = "java:jboss/exported/"
				+ context.getInitParameter("appNegocioNameEar") + "/"
				+ context.getInitParameter("appNegocioName") + "/"
				+ ejbBeanName + "!" + ejbRemoto;

		ejbSession = (ConsultaNegocioSessionRemote) ctx.lookup(lookup);

	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#listarProveedor
	 * (pe.com.viajes.bean.negocio.Proveedor)
	 */
	@Override
	public List<Proveedor> listarProveedor(Proveedor proveedor)
			throws SQLException {
		return ejbSession.listarProveedor(proveedor);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see
	 * pe.com.viajes.web.servicio.ConsultaNegocioServicio#consultarProveedor
	 * (int)
	 */
	@Override
	public Proveedor consultarProveedor(int codigoProveedor)
			throws SQLException, Exception {
		return ejbSession.consultarProveedor(codigoProveedor);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#buscarProveedor
	 * (pe.com.viajes.bean.negocio.Proveedor)
	 */
	@Override
	public List<Proveedor> buscarProveedor(Proveedor proveedor)
			throws SQLException {
		return ejbSession.buscarProveedor(proveedor);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#listarCliente()
	 */
	@Override
	public List<Cliente> listarCliente() throws SQLException {
		return ejbSession.listarCliente();
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#buscarCliente(pe
	 * .com.logistica.bean.negocio.Cliente)
	 */
	@Override
	public List<Cliente> buscarCliente(Cliente cliente) throws SQLException {
		return ejbSession.buscarCliente(cliente);
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see pe.com.viajes.web.servicio.ConsultaNegocioServicio#consultarCliente
	 * (int)
	 */
	@Override
	public Cliente consultarCliente(int idcliente) throws SQLException,
			Exception {
		return ejbSession.consultarCliente(idcliente);
	}

	@Override
	public List<Cliente> listarClientesNovios(String genero)
			throws SQLException, Exception {
		return ejbSession.listarClientesNovios(genero);
	}

	@Override
	public List<Cliente> buscarClientesNovios(Cliente cliente)
			throws SQLException, Exception {
		return ejbSession.consultarClientesNovios(cliente);
	}

	@Override
	public List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception {
		return ejbSession.consultarNovios(programaNovios);
	}

	@Override
	public List<CuotaPago> consultarCronogramaPago(
			ServicioAgencia servicioAgencia) throws SQLException, Exception {
		return ejbSession.consultarCronograma(servicioAgencia);
	}

	@Override
	public ServicioAgencia consultarVentaServicio(int idServicio)
			throws SQLException, Exception {
		return ejbSession.consultarServicioVenta(idServicio);
	}

	@Override
	public List<ServicioAgencia> listarVentaServicio(
			ServicioAgenciaBusqueda servicioAgencia) throws SQLException,
			Exception {
		return ejbSession.listarServicioVenta(servicioAgencia);
	}

	@Override
	public List<Cliente> consultarCliente2(Cliente cliente)
			throws SQLException, Exception {
		return ejbSession.consultarCliente2(cliente);
	}

	@Override
	public List<ServicioProveedor> proveedoresXServicio(int idServicio)
			throws SQLException, Exception {
		BaseVO servicio = new BaseVO(idServicio);

		return ejbSession.proveedoresXServicio(servicio);
	}

	@Override
	public ProgramaNovios consultarProgramaNovios(int idProgramaNovios)
			throws SQLException, Exception {
		return ejbSession.consultarProgramaNovios(idProgramaNovios);
	}

	@Override
	public List<MaestroServicio> listarMaestroServicio() throws SQLException,
			Exception {

		return ejbSession.listarMaestroServicio();
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioAdm()
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioAdm();
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioFee()
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioFee();
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioImpto()
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioImpto();
	}

	@Override
	public MaestroServicio consultarMaestroServicio(int idMaestroServicio)
			throws SQLException, Exception {

		return ejbSession.consultarMaestroServicio(idMaestroServicio);
	}

	@Override
	public List<CorreoClienteMasivo> listarClientesCorreo()
			throws SQLException, Exception {

		return ejbSession.listarClientesCorreo();
	}

	@Override
	public List<Cliente> listarClientesCumples() throws SQLException, Exception {
		return ejbSession.listarClientesCumples();
	}

	@Override
	public List<MaestroServicio> listarMaestroServicioIgv()
			throws SQLException, Exception {

		return ejbSession.listarMaestroServicioIgv();
	}

	@Override
	public List<BaseVO> consultaServiciosDependientes(Integer idServicio)
			throws SQLException, Exception {
		return ejbSession.consultaServiciosDependientes(idServicio);
	}

	@Override
	public List<Consolidador> listarConsolidador() throws SQLException,
			Exception {
		return ejbSession.listarConsolidador();
	}

	@Override
	public Consolidador consultarConsolidador(Consolidador consolidador)
			throws SQLException, Exception {
		return ejbSession.consultarConsolidador(consolidador);
	}

	@Override
	public List<PagoServicio> listarPagosServicio(Integer idServicio)
			throws SQLException, Exception {

		return ejbSession.listarPagosServicio(idServicio);
	}

	@Override
	public List<PagoServicio> listarPagosObligacion(Integer idObligacion)
			throws SQLException, Exception {

		return ejbSession.listarPagosObligacion(idObligacion);
	}

	@Override
	public BigDecimal consultarSaldoServicio(Integer idServicio)
			throws SQLException, Exception {

		return ejbSession.consultarSaldoServicio(idServicio);
	}

	@Override
	public List<DetalleServicioAgencia> consultarDetalleComprobantes(
			Integer idServicio) throws SQLException, Exception {
		return ejbSession.consultarDetalleServicioComprobante(idServicio);
	}

	@Override
	public List<DetalleServicioAgencia> consultarDetServComprobanteObligacion(
			Integer idServicio) throws SQLException, Exception {
		return ejbSession.consultarDetServComprobanteObligacion(idServicio);
	}

	@Override
	public List<Comprobante> listarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception {
		return ejbSession.listarObligacionXPagar(comprobante);
	}

	@Override
	public List<DocumentoAdicional> listarDocumentosAdicionales(
			Integer idServicio) throws SQLException {
		return ejbSession.listarDocumentosAdicionales(idServicio);
	}

	@Override
	public List<Comprobante> consultarComprobantesGenerados(
			ComprobanteBusqueda comprobanteBusqueda)
			throws ErrorConsultaDataException {
		return ejbSession.consultarComprobantesGenerados(comprobanteBusqueda);
	}

	@Override
	public Comprobante consultarComprobanteGenerado(Integer idComprobante)
			throws ErrorConsultaDataException {
		return ejbSession.consultarComprobante(idComprobante);
	}

	@Override
	public List<ReporteArchivoBusqueda> consultarArchivosCargados(
			ReporteArchivoBusqueda reporteArchivoBusqueda)
			throws ErrorConsultaDataException {
		return ejbSession.consultarArchivosCargados(reporteArchivoBusqueda);
	}

	@Override
	public DetalleServicioAgencia consultarDetalleServicioDetalle(
			int idServicio, int idDetServicio) throws SQLException {
		return ejbSession.consultaDetalleServicioDetalle(idServicio,
				idDetServicio);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancarias() throws SQLException {
		return ejbSession.listarCuentasBancarias();
	}

	@Override
	public CuentaBancaria consultarCuentaBancaria(Integer idCuenta)
			throws SQLException {
		return ejbSession.consultaCuentaBancaria(idCuenta);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasCombo()
			throws SQLException {
		return ejbSession.listarCuentasBancariasCombo();
	}

	@Override
	public Comprobante consultarComprobanteObligacion(Integer idObligacion)
			throws SQLException {
		return ejbSession.consultarComprobanteObligacion(idObligacion);
	}

	@Override
	public List<CuentaBancaria> listarCuentasBancariasProveedor(
			Integer idProveedor) throws SQLException {
		return ejbSession.listarCuentasBancariasProveedor(idProveedor);
	}

	@Override
	public List<MovimientoCuenta> listarMovimientosXCuenta(Integer idCuenta)
			throws SQLException {
		return ejbSession.listarMovimientosXCuenta(idCuenta);
	}

	@Override
	public List<TipoCambio> listarTipoCambio(Date fecha) throws SQLException {
		return ejbSession.listarTipoCambio(fecha);
	}
	@Override
	public List<CheckIn> consultarCheckInPendiente(Usuario usuario) throws SQLException {
		return ejbSession.consultarCheckInPendientes(usuario);
	}

	@Override
	public List<ImpresionArchivoCargado> consultaImpresionArchivoCargado(
			Integer idArchivoCargado) throws SQLException {
		return ejbSession.consultaImpresionArchivoCargado(idArchivoCargado);
	}
	
	@Override
	public List<Pasajero> consultarPasajeroHistorico(Pasajero pasajero) throws ErrorConsultaDataException{
		return ejbSession.consultarPasajeroHistorico(pasajero);
	}
	
	@Override
	public List<Comprobante> consultarObligacionesPendientes() throws ErrorConsultaDataException{
		return ejbSession.consultarObligacionesPendientes();
	}
}