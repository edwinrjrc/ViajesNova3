package pe.com.viajes.negocio.ejb;

import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import javax.ejb.Remote;

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
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.negocio.exception.ValidacionException;

@Remote
public interface ConsultaNegocioSessionRemote {

	List<Proveedor> listarProveedor(Proveedor proveedor) throws SQLException;

	Proveedor consultarProveedor(int codigoProveedor) throws SQLException,
			Exception;

	List<Proveedor> buscarProveedor(Proveedor proveedor) throws SQLException;

	List<Cliente> listarCliente() throws SQLException;

	List<Cliente> buscarCliente(Cliente cliente) throws SQLException;

	Cliente consultarCliente(int idcliente) throws SQLException, Exception;

	List<Cliente> listarClientesNovios(String genero) throws SQLException,
			Exception;

	List<Cliente> consultarClientesNovios(Cliente cliente) throws SQLException,
			Exception;

	List<ProgramaNovios> consultarNovios(ProgramaNovios programaNovios)
			throws SQLException, Exception;

	List<CuotaPago> consultarCronograma(ServicioAgencia servicioAgencia)
			throws SQLException, Exception;

	ServicioAgencia consultarServicioVenta(int idServicio) throws SQLException,
			Exception;

	List<ServicioAgencia> listarServicioVenta(
			ServicioAgenciaBusqueda servicioAgencia) throws SQLException,
			Exception;

	List<Cliente> consultarCliente2(Cliente cliente) throws SQLException,
			Exception;

	List<ServicioProveedor> proveedoresXServicio(BaseVO servicio)
			throws SQLException, Exception;

	ProgramaNovios consultarProgramaNovios(int idProgramaNovios)
			throws ValidacionException, SQLException, Exception;

	List<MaestroServicio> listarMaestroServicio() throws SQLException,
			Exception;

	List<MaestroServicio> listarMaestroServicioAdm() throws SQLException,
			Exception;

	List<MaestroServicio> listarMaestroServicioFee() throws SQLException,
			Exception;

	List<MaestroServicio> listarMaestroServicioIgv() throws SQLException,
			Exception;

	List<MaestroServicio> listarMaestroServicioImpto() throws SQLException,
			Exception;

	MaestroServicio consultarMaestroServicio(int idMaestroServicio)
			throws SQLException, Exception;

	List<CorreoClienteMasivo> listarClientesCorreo() throws SQLException,
			Exception;

	List<BaseVO> consultaServiciosDependientes(Integer idServicio)
			throws SQLException, Exception;

	List<Consolidador> listarConsolidador() throws SQLException, Exception;

	Consolidador consultarConsolidador(Consolidador consolidador)
			throws SQLException, Exception;

	List<PagoServicio> listarPagosServicio(Integer idServicio)
			throws SQLException, Exception;

	List<PagoServicio> listarPagosObligacion(Integer idObligacion)
			throws SQLException, Exception;

	BigDecimal consultarSaldoServicio(Integer idServicio) throws SQLException,
			Exception;

	List<DetalleServicioAgencia> consultarDetalleServicioComprobante(
			Integer idServicio) throws SQLException, Exception;

	List<DetalleServicioAgencia> consultarDetServComprobanteObligacion(
			Integer idServicio) throws ErrorConsultaDataException,
			SQLException, Exception;

	List<Comprobante> listarObligacionXPagar(Comprobante comprobante)
			throws SQLException, Exception;

	List<DocumentoAdicional> listarDocumentosAdicionales(Integer idServicio)
			throws SQLException;

	List<Comprobante> consultarComprobantesGenerados(
			ComprobanteBusqueda comprobanteBusqueda)
			throws ErrorConsultaDataException;

	Comprobante consultarComprobante(Integer idComprobante)
			throws ErrorConsultaDataException;

	List<ReporteArchivoBusqueda> consultarArchivosCargados(
			ReporteArchivoBusqueda reporteArchivoBusqueda)
			throws ErrorConsultaDataException;

	DetalleServicioAgencia consultaDetalleServicioDetalle(int idServicio,
			int idDetServicio) throws SQLException;

	List<CuentaBancaria> listarCuentasBancarias() throws SQLException;

	CuentaBancaria consultaCuentaBancaria(Integer idCuenta) throws SQLException;

	List<CuentaBancaria> listarCuentasBancariasCombo() throws SQLException;

	Comprobante consultarComprobanteObligacion(Integer idObligacion)
			throws SQLException;

	List<CuentaBancaria> listarCuentasBancariasProveedor(Integer idProveedor)
			throws SQLException;

	List<MovimientoCuenta> listarMovimientosXCuenta(Integer idCuenta)
			throws SQLException;

	List<TipoCambio> listarTipoCambio(Date fecha) throws SQLException;

	List<Cliente> listarClientesCumples() throws SQLException, Exception;

	List<CheckIn> consultarCheckInPendientes(Usuario usuario) throws SQLException;

	List<ImpresionArchivoCargado> consultaImpresionArchivoCargado(
			Integer idArchivoCargado) throws SQLException;

	List<Pasajero> consultarPasajeroHistorico(Pasajero pasajero)
			throws ErrorConsultaDataException;
}
