/**
 * Modela la abstraccion de una respuesta de un webservice. Se tiene que extender de esta clase para poder procesar la respuesta.
 */
public abstract class WSResult {

	public Exception resultException { get; set; }
	public Boolean hasError { get; set; }
	public String message { get; set; }
	public HttpRequest request { get; set; }
	public HttpResponse response { get; set; }

	public abstract void processResponse(HttpResponse response);

	public abstract void processErrorResponse(HttpResponse response);

}