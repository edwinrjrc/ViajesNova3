/**
 * 
 */
package pe.com.viajes.web.faces;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.naming.NamingException;
import javax.servlet.ServletContext;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletResponse;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFCellStyle;
import org.apache.poi.hssf.usermodel.HSSFFont;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.ss.util.CellRangeAddress;

import pe.com.viajes.bean.negocio.Cliente;
import pe.com.viajes.bean.negocio.Comprobante;
import pe.com.viajes.bean.negocio.ComprobanteBusqueda;
import pe.com.viajes.bean.negocio.ImpresionArchivoCargado;
import pe.com.viajes.bean.negocio.Proveedor;
import pe.com.viajes.negocio.exception.ErrorConsultaDataException;
import pe.com.viajes.web.servicio.ConsultaNegocioServicio;
import pe.com.viajes.web.servicio.impl.ConsultaNegocioServicioImpl;
import pe.com.viajes.web.util.UtilConvertirNumeroLetras;
import pe.com.viajes.web.util.UtilWeb;

/**
 * @author EDWREB
 *
 */
@ManagedBean(name = "comprobanteMBean")
@SessionScoped()
public class ComprobanteMBean extends BaseMBean {

	private final static Logger logger = Logger
			.getLogger(ComprobanteMBean.class);

	/**
	 * 
	 */
	private static final long serialVersionUID = 3796481899238208609L;

	private ComprobanteBusqueda comprobanteBusqueda;
	private Comprobante comprobanteDetalle;

	private Proveedor proveedor;

	private List<Comprobante> listaComprobantes;
	private List<Proveedor> listadoProveedores;

	//private NegocioServicio negocioServicio;
	private ConsultaNegocioServicio consultaNegocioServicio;

	/**
	 * 
	 */
	public ComprobanteMBean() {
		try {
			ServletContext servletContext = (ServletContext) FacesContext
					.getCurrentInstance().getExternalContext().getContext();
			//negocioServicio = new NegocioServicioImpl(servletContext);
			consultaNegocioServicio = new ConsultaNegocioServicioImpl(
					servletContext);
		} catch (NamingException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscar() {
		try {
			this.setListaComprobantes(this.consultaNegocioServicio
					.consultarComprobantesGenerados(getComprobanteBusqueda()));
		} catch (ErrorConsultaDataException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void buscarProveedor() {

	}

	public void seleccionarProveedor() {
		for (Proveedor proveedor : this.listadoProveedores) {
			if (proveedor.getCodigoEntero().equals(
					proveedor.getCodigoSeleccionado())) {
				this.getComprobanteBusqueda().setProveedor(proveedor);
				break;
			}
		}
	}

	public void consultarComprobante(Integer idComprobante) {
		try {
			this.setComprobanteDetalle(null);
			this.setComprobanteDetalle(this.consultaNegocioServicio
					.consultarComprobanteGenerado(idComprobante));
		} catch (ErrorConsultaDataException e) {
			e.printStackTrace();
		}
	}
	
	public void generarComprobante(){
		System.out.println("Genera Comprobante");
		try {
			HSSFWorkbook archivoExcel = new HSSFWorkbook();
			
			HSSFFont fuenteDefecto = archivoExcel.createFont();
			fuenteDefecto.setFontName("Calibri");
			fuenteDefecto.setFontHeightInPoints((short) 10);

			String nombreHoja = "Comprobante";
			HSSFSheet hoja1 = archivoExcel.createSheet(nombreHoja);

			/**
			 * Creacion de estilos
			 */
			HSSFCellStyle estiloCalibri = archivoExcel.createCellStyle();
			HSSFFont fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 10);
			estiloCalibri.setFont(fuente);

			HSSFCellStyle estiloCalibriNegrita = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 10);
			fuente.setBold(true);
			estiloCalibriNegrita.setFont(fuente);

			HSSFCellStyle sCalibriNegrita12 = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 10);
			fuente.setBold(true);
			sCalibriNegrita12.setFont(fuente);

			HSSFCellStyle estiloCalibriCentro = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 10);
			estiloCalibriCentro.setFont(fuente);
			estiloCalibriCentro.setAlignment(HSSFCellStyle.ALIGN_CENTER);

			HSSFCellStyle estiloCalibriDerecha = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 10);
			estiloCalibriDerecha.setFont(fuente);
			estiloCalibriDerecha.setAlignment(HSSFCellStyle.ALIGN_RIGHT);
			
			HSSFCellStyle estiloCalibriIzquierda = archivoExcel.createCellStyle();
			fuente = archivoExcel.createFont();
			fuente.setFontName("Calibri");
			fuente.setFontHeightInPoints((short) 10);
			estiloCalibriIzquierda.setFont(fuente);
			estiloCalibriIzquierda.setAlignment(HSSFCellStyle.ALIGN_LEFT);

			/**
			 * Fin de estilos
			 */
			
			
			HSSFRow fila = null;
			HSSFCell celda = null;
			for (int i = 0; i < 30; i++) {
				fila = hoja1.createRow(i);
				celda = fila.createCell(0);
				if (i == 0) {
					for (int j = 0; j < 10; j++) {
						celda = fila.createCell(j);
						celda.setCellStyle(estiloCalibri);
					}
				}

				celda.setCellStyle(estiloCalibri);
			}

			hoja1.setColumnWidth(0, 11 * 256);
			hoja1.setColumnWidth(1, 12 * 256);
			hoja1.setColumnWidth(2, 13 * 256);
			hoja1.setColumnWidth(3, 2940);
			hoja1.setColumnWidth(4, 2940);
			hoja1.setColumnWidth(5, 2940);
			hoja1.setColumnWidth(6, 2940);
			hoja1.setColumnWidth(7, 2940);
			hoja1.setColumnWidth(8, 2940);
			hoja1.setColumnWidth(9, 2940);
			hoja1.setColumnWidth(10, 2940);
			hoja1.setColumnWidth(11, 2940);

			fila = hoja1.getRow(1);
			fila.setHeightInPoints((float) 20.25);
			fila = hoja1.getRow(4);
			fila.setHeightInPoints((float) 20.25);
			fila = hoja1.getRow(5);
			celda.setCellStyle(estiloCalibri);
			
			CellRangeAddress region = new CellRangeAddress(6, 6, 0, 1);
			hoja1.addMergedRegion(region);
			CellRangeAddress region2 = new CellRangeAddress(6, 6, 2, 5);
			hoja1.addMergedRegion(region2);
			CellRangeAddress region3 = new CellRangeAddress(7, 7, 2, 6);
			hoja1.addMergedRegion(region3);

			fila = hoja1.getRow(6);
			fila.setHeightInPoints((float) 25.5);
			celda = fila.getCell(0);
			celda.setCellStyle(estiloCalibriIzquierda);
			String fechaHoy = "     "+UtilWeb.diaFechaHoy();
			fechaHoy = fechaHoy + "   " + UtilWeb.mesHoyNumero();
			fechaHoy = fechaHoy + "     " + UtilWeb.anioFechaHoyYY();
			celda.setCellValue(fechaHoy);
			
			celda = fila.createCell(2);
			celda.setCellStyle(estiloCalibriIzquierda);
			Cliente cliente = this.consultaNegocioServicio.consultarCliente(this.getComprobanteDetalle().getTitular().getCodigoEntero());
			celda.setCellValue(cliente.getNombreCompleto());
			
			fila = hoja1.getRow(7);
			celda = fila.createCell(2);
			celda.setCellValue(cliente.getDocumentoIdentidad().getNumeroDocumento());
			celda.setCellStyle(estiloCalibriIzquierda);

			fila = hoja1.createRow(9);
			fila.setHeightInPoints((float) 19.5);
			celda = fila.createCell(0);
			
			fila = hoja1.getRow(13);
			celda = fila.createCell(1);
			CellRangeAddress region4 = new CellRangeAddress(13, 13, 1, 6);
			hoja1.addMergedRegion(region4);
			celda.setCellValue("Por la comisión en la venta de tkt aéreo a favor de:");
			celda.setCellStyle(estiloCalibri);

			/*List<ImpresionArchivoCargado> listado = this.consultaNegocioServicio.consultaImpresionArchivoCargado(reporteCargado.getCodigoEntero());
			if (listado != null){
				int i=14;
				for (ImpresionArchivoCargado impresionArchivoCargado : listado) {
					fila = hoja1.getRow(i);
					celda = fila.createCell(1);
					CellRangeAddress region5 = new CellRangeAddress(i, i, 1, 6);
					hoja1.addMergedRegion(region5);
					String v = "Pax: "+impresionArchivoCargado.getPaternoCliente()+"/"+impresionArchivoCargado.getNombresCliente()+" - Tkt: "+impresionArchivoCargado.getNumeroBoleto();
					celda.setCellValue(v);
					celda.setCellStyle(estiloCalibri);
				}
			}*/
			

			fila = hoja1.getRow(20);
			fila.setHeightInPoints((float) 10.50);

			fila = hoja1.getRow(22);
			fila.setHeightInPoints((float) 3.0);

			fila = hoja1.getRow(23);
			CellRangeAddress region11 = new CellRangeAddress(23, 23, 1, 6);
			hoja1.addMergedRegion(region11);
			fila.setHeightInPoints((float) 22.50);
			celda = fila.createCell(1);
			//celda.setCellValue(UtilConvertirNumeroLetras.convertNumberToLetter(reporteCargado.getMontoTotal().doubleValue()));
			celda.setCellStyle(estiloCalibri);

			fila = hoja1.getRow(24);
			fila.setHeightInPoints((float) 31.5);
			celda = fila.getCell(0);
			celda.setCellValue(UtilWeb.diaFechaHoy());
			celda.setCellStyle(estiloCalibriDerecha);
			celda = fila.createCell(1);
			celda.setCellValue(UtilWeb.mesHoy());
			celda.setCellStyle(estiloCalibri);
			celda = fila.createCell(2);
			celda.setCellStyle(estiloCalibriDerecha);
			celda.setCellValue(UtilWeb.anioFechaHoy());

			celda = fila.createCell(5);
			celda.setCellStyle(sCalibriNegrita12);
			//celda.setCellValue(reporteCargado.getMoneda().getAbreviatura()+" "+reporteCargado.getMontoSubtotal());
			
			celda = fila.createCell(6);
			celda.setCellStyle(sCalibriNegrita12);
			//celda.setCellValue(reporteCargado.getMoneda().getAbreviatura()+" "+reporteCargado.getMontoIGV());
			
			celda = fila.createCell(7);
			//celda.setCellValue(reporteCargado.getMoneda().getAbreviatura()+" "+reporteCargado.getMontoTotal());
			celda.setCellStyle(sCalibriNegrita12);

			HttpServletResponse response = obtenerResponse();
			response.setContentType("application/vnd.ms-excel");
			response.setHeader("Content-disposition", "attachment;filename="
					+ "reporte.xls");
			response.setHeader("Content-Transfer-Encoding", "binary");

			FacesContext facesContext = obtenerContexto();

			ServletOutputStream respuesta = response.getOutputStream();
			// respuesta.write(xls.getBytes());
			archivoExcel.write(respuesta);
			archivoExcel.close();

			respuesta.close();
			respuesta.flush();

			facesContext.responseComplete();
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}

	/**
	 * ========================================================================
	 * ===============================================================
	 */

	/**
	 * @return the comprobanteBusqueda
	 */
	public ComprobanteBusqueda getComprobanteBusqueda() {
		if (comprobanteBusqueda == null) {
			comprobanteBusqueda = new ComprobanteBusqueda();

			Calendar cal = Calendar.getInstance();
			comprobanteBusqueda.setFechaHasta(cal.getTime());
			cal.add(Calendar.MONTH, -1);
			comprobanteBusqueda.setFechaDesde(cal.getTime());
		}
		return comprobanteBusqueda;
	}

	/**
	 * @param comprobanteBusqueda
	 *            the comprobanteBusqueda to set
	 */
	public void setComprobanteBusqueda(ComprobanteBusqueda comprobanteBusqueda) {
		this.comprobanteBusqueda = comprobanteBusqueda;
	}

	/**
	 * @return the listaComprobantes
	 */
	public List<Comprobante> getListaComprobantes() {
		if (listaComprobantes == null) {
			listaComprobantes = new ArrayList<Comprobante>();
		}
		return listaComprobantes;
	}

	/**
	 * @param listaComprobantes
	 *            the listaComprobantes to set
	 */
	public void setListaComprobantes(List<Comprobante> listaComprobantes) {
		this.listaComprobantes = listaComprobantes;
	}

	/**
	 * @return the proveedor
	 */
	public Proveedor getProveedor() {
		if (proveedor == null) {
			proveedor = new Proveedor();
		}
		return proveedor;
	}

	/**
	 * @param proveedor
	 *            the proveedor to set
	 */
	public void setProveedor(Proveedor proveedor) {
		this.proveedor = proveedor;
	}

	/**
	 * @return the listadoProveedores
	 */
	public List<Proveedor> getListadoProveedores() {
		if (listadoProveedores == null) {
			listadoProveedores = new ArrayList<Proveedor>();
		}
		return listadoProveedores;
	}

	/**
	 * @param listadoProveedores
	 *            the listadoProveedores to set
	 */
	public void setListadoProveedores(List<Proveedor> listadoProveedores) {
		this.listadoProveedores = listadoProveedores;
	}

	/**
	 * @return the comprobanteDetalle
	 */
	public Comprobante getComprobanteDetalle() {
		if (comprobanteDetalle == null) {
			comprobanteDetalle = new Comprobante();
		}
		return comprobanteDetalle;
	}

	/**
	 * @param comprobanteDetalle
	 *            the comprobanteDetalle to set
	 */
	public void setComprobanteDetalle(Comprobante comprobanteDetalle) {
		this.comprobanteDetalle = comprobanteDetalle;
	}

}
