/**
 * 
 */
package pe.com.viajes.bean.reportes;

import java.util.Date;

import pe.com.viajes.bean.base.Base;
import pe.com.viajes.bean.base.BaseVO;

/**
 * @author EDWREB
 *
 */
public class CheckIn extends Base {

	private static final long serialVersionUID = 6963463376557251274L;
	
	private Integer idServicio;
	private BaseVO cliente;
	private BaseVO origen;
	private BaseVO destino;
	private Date fechaSalida;
	private Date fechaLlegada;
	private BaseVO aerolinea;
	private String codigoReserva;
	private String numeroBoleto;
	
	
	/**
	 * @return the idServicio
	 */
	public Integer getIdServicio() {
		return idServicio;
	}
	/**
	 * @param idServicio the idServicio to set
	 */
	public void setIdServicio(Integer idServicio) {
		this.idServicio = idServicio;
	}
	/**
	 * @return the cliente
	 */
	public BaseVO getCliente() {
		if (cliente == null){
			cliente = new BaseVO();
		}
		return cliente;
	}
	/**
	 * @param cliente the cliente to set
	 */
	public void setCliente(BaseVO cliente) {
		this.cliente = cliente;
	}
	/**
	 * @return the origen
	 */
	public BaseVO getOrigen() {
		if (origen == null){
			origen = new BaseVO();
		}
		return origen;
	}
	/**
	 * @param origen the origen to set
	 */
	public void setOrigen(BaseVO origen) {
		this.origen = origen;
	}
	/**
	 * @return the destino
	 */
	public BaseVO getDestino() {
		if (destino == null){
			destino = new BaseVO();
		}
		return destino;
	}
	/**
	 * @param destino the destino to set
	 */
	public void setDestino(BaseVO destino) {
		this.destino = destino;
	}
	/**
	 * @return the fechaSalida
	 */
	public Date getFechaSalida() {
		return fechaSalida;
	}
	/**
	 * @param fechaSalida the fechaSalida to set
	 */
	public void setFechaSalida(Date fechaSalida) {
		this.fechaSalida = fechaSalida;
	}
	/**
	 * @return the fechaLlegada
	 */
	public Date getFechaLlegada() {
		return fechaLlegada;
	}
	/**
	 * @param fechaLlegada the fechaLlegada to set
	 */
	public void setFechaLlegada(Date fechaLlegada) {
		this.fechaLlegada = fechaLlegada;
	}
	/**
	 * @return the aerolinea
	 */
	public BaseVO getAerolinea() {
		if (aerolinea == null){
			aerolinea = new BaseVO();
		}
		return aerolinea;
	}
	/**
	 * @param aerolinea the aerolinea to set
	 */
	public void setAerolinea(BaseVO aerolinea) {
		this.aerolinea = aerolinea;
	}
	/**
	 * @return the codigoReserva
	 */
	public String getCodigoReserva() {
		return codigoReserva;
	}
	/**
	 * @param codigoReserva the codigoReserva to set
	 */
	public void setCodigoReserva(String codigoReserva) {
		this.codigoReserva = codigoReserva;
	}
	/**
	 * @return the numeroBoleto
	 */
	public String getNumeroBoleto() {
		return numeroBoleto;
	}
	/**
	 * @param numeroBoleto the numeroBoleto to set
	 */
	public void setNumeroBoleto(String numeroBoleto) {
		this.numeroBoleto = numeroBoleto;
	}
	
}
