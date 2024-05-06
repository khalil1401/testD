public class BatchSendEmailCC implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext context) {
		
		String query = 'SELECT	Id,';
		query += '				Dan360_CorreoDeCliente__c,';
        query += '				Dan360_NroComprobante__c,';
        query += '				Dan360_Vencimiento__c';
		query += '		FROM	Dan360_DocumentosCuentaCorriente__c';
		query += '		WHERE	Dan360_Saldo__c  > 0';
        query += '		    AND	Dan360_Vencimiento__c  < TODAY';
		return Database.getQueryLocator(query);
	}

	public void execute(Database.BatchableContext context, List<Dan360_DocumentosCuentaCorriente__c> listCuentaCorriente) {
		
        List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();
        String sender = 'clientes@nutricia.com.ar';
        String senderDisplayName = 'Clientes Nutricia';
        String body = '<body bgcolor="#f3f2f0" text="#181818" style="-webkit-text-size-adjust:none;background-color : #FFFFFF; font-family: system-ui, sans-serif; line-height : 100%; font-size : 14px; color : #6E6E6E; padding : 0px; ">'+'<table width="100%" height="100%" border="0" cellpadding="0" cellspacing="0" align="center">'+
            '<tr>'+
            '<td align="center">'+
            '<table cellspacing="0" cellpadding="0" border="0" width="100%" align="center">'+
            '<tr>'+
            '<td>'+
            '<table class="tb_properties border_style" style="border : 0px solid transparent;font-size : 14px; font-family: system-ui, sans-serif; line-height : 100%; color : #6E6E6E; "'+
            'cellspacing="0" cellpadding="0" width="100%">'+
            '<tr>'+
            '<td>'+
            '<table class="email-logo global-width" width="100%" bgcolor="#FFFFFF" style="text-align: center; min-width: 100%;">'+
            '<tr>'+
            '<td width="100%" style="width: 100%; padding-top: 8px; padding-bottom: 1px;">'+
            '<a href="https://uatdanone-danone360.cs196.force.com/" target="_blank"><img src="https://sndigitalassets.s3.sa-east-1.amazonaws.com/OMS/LOGOS/OMS-Logo-Nutricia%282022-07-18%29.png" alt="Nutricia"></a>'+
            '</td>'+
            '</tr>'+
            '</table>'+
            '</td>'+
            '</tr>'+
            '</table>'+
            '</td>'+
            '</tr>'+
            '<tr>'+
            '<td align="center" class="main-content" valign="top">'+
            '<table cellspacing="0" cellpadding="0" border="0" width="100%" class="container123" style="width:640px" align="center">'+
            '<tbody>'+
            '<tr>'+
            '<td align="left" valign="top">'+
            '<table cellspacing="0" cellpadding="0" style="width:100%">'+
            '<tbody>'+
            '<tr>'+
            '<td class="responsive-td" valign="top" style="width: 100%;">'+
            '<div data-type="slot" data-key="3jse35uqtyp" data-label="Drop blocks or content here">'+
            '<table cellspacing="0" cellpadding="0" border="0" width="100%" class="email-content global-width" align="center" style="text-align: center;width: 100%;">'+
            '<tr>'+
            '<td class="email-content_inner" style="padding-top: 20px;padding-bottom: 20px;">'+
            '<table  cellspacing="0" cellpadding="0" border="0" width="600px" bgcolor="#FFFFFF" align="center" class="container123" style="width: auto; font: 14px/28px; letter-spacing: 0.55px; text-align: center;  margin: 0 auto; border: 30px">'+
            '<tr>'+
            '<td style="padding: 10px 10% 1px;">'+
            '<h1 class="email-title" style="'+
            'font-size: 2rem;'+
            'line-height: 1.17;'+
            'font-family: system-ui; '+
            'color: #6E6E6E;'+
            'font-weight: bolder;'+
            'text-align: center;'+
            'text-transform: none;'+
            'position: relative;'+
            'padding-bottom: 5px;'+
            'padding-left: 10px;'+
            'padding-right: 10px;'+
            'margin: 0;'+
            'border-bottom: 2px solid #6E6E6E;'+
            '">'+
            'Saldo vencido'+
            '</h1>'+
            '<span style="">&nbsp;</span>'+
            '</td>'+
            '</tr>'+
            '<tr>'+
            '<td style="padding: 10 10% 25px;">'+                                              
            '<table cellspacing="0" cellpadding="0" border="0" align="center" style="font-size: 14px;line-height: 2em;text-align:center; text-transform: none;">'+
            '<tr>'+
            '<td style="font-family: system-ui; font-size:1.313rem; line-height: 2em; border-bottom: 0px solid #6E6E6E">  '+
            '<p> <b>Estimado cliente: <br> Le informamos que el saldo del documento {0} venció el día {1}. '+
            '<br> Favor de realizar el pago'+
            '<br> Muchas gracias. <br> '+                                                          
            '<p style="font-family: system-ui; font-size:13px; line-height: 2em; border-bottom: 0px solid #6E6E6E">*Este mensaje ha sido generado automáticamente y no debe ser respondido.</p>'+
            '</td>'+
            '</tr>'+
            '</table>'+
            '</div>'+
            '</tbody>'+
            '</body>'; 
        for(Dan360_DocumentosCuentaCorriente__c cc : listCuentaCorriente){
            List<String> bodyValues = new List<String>{cc.Dan360_NroComprobante__c, cc.Dan360_Vencimiento__c.format()};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> sendTo = new List<String>();
            sendTo.add(cc.Dan360_CorreoDeCliente__c);
            mail.setToAddresses(sendTo);
            mail.setReplyTo(sender);
            mail.setSenderDisplayName(senderDisplayName);
            mail.setSubject('Documento '+ cc.Dan360_NroComprobante__c +' con saldo vencido.');
            mail.setHtmlBody(String.format(body, bodyValues));
            mailsToSend.add(mail);
        }

        Messaging.sendEmail(mailsToSend);
	}

	public void finish(Database.BatchableContext context) {
    }
}