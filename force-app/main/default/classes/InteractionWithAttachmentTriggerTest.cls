@isTest
public class InteractionWithAttachmentTriggerTest  {

	@IsTest public static void ShouldMarkTheBoxHasAttachedFileInTrueIfYouHaveAtLeastOneAttachedFile() {

		List<ContentDocument> documents = [
			SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument
		];  		

		ContentDocumentLink linkArchivoAdjunto = Build.aLinkArchivosAdjuntos()
			.withContentDocumentId(documents[0])
			.withLinkedEntityId(interaccion)
			.withShareType('V')
			.build();

		Test.startTest();
		insert linkArchivoAdjunto;
		Test.stopTest();
		
		List<Interaccion__c> interaccionBD = [
			SELECT Id, Name, Tiene_archivo_adjunto__c, Cantidad_de_archivos_adjuntos__c
			FROM Interaccion__c
		];

		List<ContentDocumentLink> archivoAdjuntoBD = [
			SELECT Id
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :interaccionBD[0].Id 
		];

		System.assertEquals(1, archivoAdjuntoBD.size());
		System.assertEquals(true, interaccionBD[0].Tiene_archivo_adjunto__c);
		System.assertEquals(1, interaccionBD[0].Cantidad_de_archivos_adjuntos__c);

	}

	@IsTest public static void ShouldMarkTheBoxHaveAttachedFilesInFalseIfYouDeleteAFileAndAtLeastAtOneFileAttach() {

		List<ContentDocument> documents = [
			SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument
		];  		

		ContentDocumentLink linkArchivoAdjunto = Build.aLinkArchivosAdjuntos()
			.withContentDocumentId(documents[0])
			.withLinkedEntityId(interaccion)
			.withShareType('V')
			.build();
		insert linkArchivoAdjunto;

		Test.startTest();
		delete linkArchivoAdjunto;
		Test.stopTest();
		
		List<Interaccion__c> interaccionBD = [
			SELECT Id, Name, Tiene_archivo_adjunto__c
			FROM Interaccion__c
		];

		List<ContentDocumentLink> archivoAdjuntoBD = [
			SELECT Id
			FROM ContentDocumentLink
			WHERE LinkedEntityId = :interaccionBD[0].Id 
		];

		System.assertEquals(0, archivoAdjuntoBD.size());
		System.assertEquals(false, interaccionBD[0].Tiene_archivo_adjunto__c);
	}

	static Ciclo__c ciclo;
	static Interaccion__c interaccion;
	static ContentVersion archivoAdjunto;

	static {
	
		ciclo = Build.aCiclo()
			.withName('New Ciclo')
			.build();
		insert ciclo;
		
		interaccion = Build.aInteraccion()
			.withCiclo(ciclo)
			.build();
		interaccion.Fecha__c = Date.newInstance(System.today().year(),System.today().month(),System.today().day());
		insert interaccion;

		archivoAdjunto = Build.anArchivoAdjunto()
			.withTitle('Xappia')
			.withPathOnClient('Xappia.jpg')
			.withVersionData(Blob.valueOf('Test Content'))
			.withIsMajorVersion(true)
			.build();
		insert archivoAdjunto;
	}

}