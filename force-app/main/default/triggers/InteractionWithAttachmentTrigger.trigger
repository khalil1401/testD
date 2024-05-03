trigger InteractionWithAttachmentTrigger on ContentDocumentLink (after insert, after delete, after undelete) {

	if (Trigger.isInsert && Trigger.isAfter) {

		List<ContentDocumentLink> listArchivosInsertados = InteractionWithAttachmentTriggerHelper.buscarArchivosAdjuntos(Trigger.new);

		if (!listArchivosInsertados.isEmpty()) {
			InteractionWithAttachmentTriggerHelper.insertAttachment(listArchivosInsertados);
		}
		
	}

	if (Trigger.isDelete && Trigger.isAfter) {

		List<ContentDocumentLink> listArchivosEliminados = InteractionWithAttachmentTriggerHelper.buscarArchivosAdjuntos(Trigger.old);

		if (!listArchivosEliminados.isEmpty()) {
			InteractionWithAttachmentTriggerHelper.deleteAttachment(listArchivosEliminados);
		}

	}

}