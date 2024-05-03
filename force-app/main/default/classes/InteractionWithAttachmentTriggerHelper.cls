public class InteractionWithAttachmentTriggerHelper  {

	public static List<ContentDocumentLink> buscarArchivosAdjuntos(List<ContentDocumentLink> attachments) {

		List<ContentDocumentLink> listArchivos= new List<ContentDocumentLink>();

		for (ContentDocumentLink archivos : attachments) {

			if (archivos.LinkedEntityId.getSObjectType().getDescribe().getName() == 'Interaccion__c') {
				listArchivos.add(archivos);
			}

		}

		return listArchivos;
	
	}
	
	public static List<Interaccion__c> buscarInteracciones(List<ContentDocumentLink> buscarArchivosAdjuntos) {

		Set<Id> listIdArchivos = new set<Id>();

		for (ContentDocumentLink archivoAdjunto : buscarArchivosAdjuntos) {
				
			listIdArchivos.add(archivoAdjunto.LinkedEntityId);

		}

		List<Interaccion__c> interacciones = [
			SELECT Id, Tiene_archivo_adjunto__c, Cantidad_de_archivos_adjuntos__c
			FROM Interaccion__c
			WHERE Id = :listIdArchivos
		];

		return interacciones;
	
	}
	
	public static void insertAttachment(List<ContentDocumentLink> buscarArchivosAdjuntos) {

		List<Interaccion__c> newInteracciones = new List<Interaccion__c>();

		List<Interaccion__c> interacciones = buscarInteracciones(buscarArchivosAdjuntos);

		for (Interaccion__c interaccion : interacciones) {

			if (interaccion.Tiene_archivo_adjunto__c == false) {

				interaccion.Tiene_archivo_adjunto__c = true;
				interaccion.Cantidad_de_archivos_adjuntos__c = 1;
				newInteracciones.add(interaccion);

			} else if (interaccion.Tiene_archivo_adjunto__c == true) {

				interaccion.Cantidad_de_archivos_adjuntos__c = interaccion.Cantidad_de_archivos_adjuntos__c + 1;
				newInteracciones.add(interaccion);

			}
		}

		if (newInteracciones.size() > 0) {
			update newInteracciones;
		}

	}

	public static void deleteAttachment(List<ContentDocumentLink> buscarArchivosAdjuntos) {

		List<Interaccion__c> newInteracciones = new List<Interaccion__c>();

		List<Interaccion__c> interacciones = buscarInteracciones(buscarArchivosAdjuntos);

		for (Interaccion__c interaccion : interacciones) {

			if (interaccion.Tiene_archivo_adjunto__c == true && interaccion.Cantidad_de_archivos_adjuntos__c == 1) {

				interaccion.Tiene_archivo_adjunto__c = false;
				interaccion.Cantidad_de_archivos_adjuntos__c = interaccion.Cantidad_de_archivos_adjuntos__c - 1;
				newInteracciones.add(interaccion);

			} else if (interaccion.Tiene_archivo_adjunto__c == true && interaccion.Cantidad_de_archivos_adjuntos__c > 1) {

				interaccion.Cantidad_de_archivos_adjuntos__c = interaccion.Cantidad_de_archivos_adjuntos__c - 1;
				newInteracciones.add(interaccion);

			}

		}

		if (newInteracciones.size() > 0) {
			update newInteracciones;
		}

	}

}