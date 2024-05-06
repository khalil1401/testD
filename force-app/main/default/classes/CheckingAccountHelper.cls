public with sharing class CheckingAccountHelper {
	public class Criteria {
		public String FieldName;
		public String Operator;
		public String FieldValue;

		public Criteria(String f_name, String f_value) {
			this.FieldName = f_name;
			this.FieldValue = f_value;
			this.Operator = '=';
		}

		public String getSOQLCriteria() {
			if (fieldName.indexOf('Dan360_FechaDocumento__c') > -1) {
				return fieldName + ' '  + Operator + ' ' + FieldValue + '';
			}else {
				return fieldName + ' '  + Operator + ' \'' + FieldValue + '\'';
			}
		}

		public Boolean IsFieldValueGiven() {
			return FieldValue != null && FieldValue != '';
		}
	}

	public static Map<String, Map<String, Object>> getDocumentsData(Map<String, String> criteria) {
		Map<String, Map<String, Object>> documents = new Map<String, Map<String, Object>>();
		List<Criteria> all_criterias = new List<Criteria>();
		Decimal accumulatedBalance = 0;

		String soqlQuery = 'SELECT  Id,';
		soqlQuery += '			Name,';
		soqlQuery += '			Dan360_TipoDeDocumento__c,';
		soqlQuery += '			Dan360_NroComprobante__c,';
		soqlQuery += '			Dan360_CodigoCliente__c,';
		soqlQuery += '			Dan360_Cliente__r.Name,';
		soqlQuery += '			Dan360_FechaDocumento__c,';
		soqlQuery += '			Dan360_Vencimiento__c,';
		soqlQuery += '			Dan360_Remito__r.Dan360_Remito__c,';
		soqlQuery += '			Dan360_DiasDeVencido__c,';
		soqlQuery += '			Dan360_ImporteDocumento__c,';
		soqlQuery += '			Dan360_Saldo__c,';
		soqlQuery += '			Dan360_Semaforo__c,';
		soqlQuery += '			Dan360_Sucursal__r.Name,';
		soqlQuery += '			Dan360_Sucursal__r.BillingStreet';
		soqlQuery += '	FROM    Dan360_DocumentosCuentaCorriente__c';
		soqlQuery += '	WHERE ';//'  Dan360_Saldo__c > 0';

		for (String key : criteria.keySet()) {
			all_criterias.add(new Criteria(key, criteria.get(key)));
		}

		soqlQuery += generateWhereQuery(all_criterias);
		soqlQuery += '	ORDER BY';
		soqlQuery += '		Dan360_FechaDocumento__c,';
		soqlQuery += '		Dan360_NroComprobante__c';

		System.debug('Database.query(soqlQuery)');
		System.debug(soqlQuery);
		System.debug(Database.query(soqlQuery));

		for (Dan360_DocumentosCuentaCorriente__c invoice : Database.query(soqlQuery)) {
			accumulatedBalance += invoice.Dan360_Saldo__c == null ? 0 : invoice.Dan360_Saldo__c;

			Map<String, Object> document = new Map<String, Object>();
			document.put('Id', invoice.Id);
			document.put('ProofNumberLink', invoice.Dan360_NroComprobante__c != null ? invoice.Dan360_NroComprobante__c : '');
			document.put('ProofNumber', invoice.Dan360_NroComprobante__c != null ? invoice.Dan360_NroComprobante__c : '');
			document.put('Name', invoice.Name);
			document.put('Dan360_TipoDeDocumento__c', invoice.Dan360_TipoDeDocumento__c != null ? invoice.Dan360_TipoDeDocumento__c : '');
			document.put('Dan360_NroComprobante__c', invoice.Dan360_NroComprobante__c != null ? invoice.Dan360_NroComprobante__c : '');
			document.put('Dan360_CodigoCliente__c', invoice.Dan360_CodigoCliente__c != null ? invoice.Dan360_CodigoCliente__c : '');
			document.put('Dan360_Cliente__r', invoice.Dan360_Cliente__r.Name);
			document.put('Dan360_FechaDocumento__c', invoice.Dan360_FechaDocumento__c);
			document.put('Dan360_Vencimiento__c', invoice.Dan360_Vencimiento__c);
			document.put('Dan360_Remito__c', invoice.Dan360_Remito__r.Dan360_Remito__c);
			document.put('Dan360_DiasDeVencido__c', invoice.Dan360_DiasDeVencido__c != null ? invoice.Dan360_DiasDeVencido__c : 0);
			document.put('Dan360_ImporteDocumento__c', invoice.Dan360_ImporteDocumento__c != null ? invoice.Dan360_ImporteDocumento__c : 0);
			document.put('Dan360_Saldo__c', invoice.Dan360_Saldo__c);
			document.put('Dan360_Semaforo__c', invoice.Dan360_Semaforo__c != null ? invoice.Dan360_Semaforo__c : '');
			document.put('SubsidiaryName', invoice.Dan360_Sucursal__r.Name != null ? invoice.Dan360_Sucursal__r.Name : '');
			document.put('SubsidiaryBillingStreet', invoice.Dan360_Sucursal__r.BillingStreet != null ? invoice.Dan360_Sucursal__r.BillingStreet : '');
			document.put('Dan360_Acumulado__c', accumulatedBalance);

			documents.put(invoice.Id, document);
		}
		System.debug(documents);
		return documents;
	}

	private static String generateWhereQuery(List<Criteria> criterias) {
		List<String> and_conditions = new List<String>();
		String conditions;
		System.debug(criterias);
		for(Criteria single_criteria : criterias) {
			if (single_criteria.IsFieldValueGiven() && and_conditions.isEmpty()) {
				and_conditions.add(single_criteria.getSOQLCriteria());
				//and_conditions.add(' AND ' + single_criteria.getSOQLCriteria());
			} else if (single_criteria.IsFieldValueGiven()) {
				and_conditions.add(single_criteria.getSOQLCriteria());
			}
		}

		conditions = String.join(and_conditions, ' AND ');

		return conditions;
	}

	public static List<Dan360_DocumentosCuentaCorriente__c> armarCuentaCorriente(List<Dan360_TablaIntermediaCuentaCorriente__c> datosTablaintermedia){
		List<Dan360_DocumentosCuentaCorriente__c> cuentaCorrienteLista = new List<Dan360_DocumentosCuentaCorriente__c>();
		List<Dan360_Remito__c> listaIdRemito = new List<Dan360_Remito__c>();
		Map<String, List<Dan360_TablaIntermediaCuentaCorriente__c>> mapClientListTable = new Map<String, List<Dan360_TablaIntermediaCuentaCorriente__c>>();
		Map<String, String> mapClientIdSF = new Map<String, String>();
		Map<String, Map<String, Map<String, String>>> mapFacturaIdSF = new Map<String, Map<String, Map<String, String>>>();
		Map<String,String> mapNroComprobante = new Map<String, String>();
		Map<String,String> mapSucursalIdSF = new Map<String, String>();

		for (Dan360_TablaIntermediaCuentaCorriente__c datos : datosTablaintermedia) {
			if(!mapClientListTable.containsKey(datos.Dan360_CodigoCliente__c)){
				mapClientListTable.put(datos.Dan360_CodigoCliente__c, new List<Dan360_TablaIntermediaCuentaCorriente__c>());
			}

			mapClientListTable.get(datos.Dan360_CodigoCliente__c).add(datos);
		}

		Map<String, String> mapAccountSapAccountId = new Map<String, String>();
		for(Account anAccount : [SELECT Id, Id_SAP__c
								FROM Account
								WHERE Id_SAP__c IN :mapClientListTable.keySet()]){
			if(!mapClientIdSF.containsKey(anAccount.Id_SAP__c)){
				mapClientIdSF.put(anAccount.Id_SAP__c, anAccount.Id);
			}
			if(!mapAccountSapAccountId.containsKey(anAccount.Id_SAP__c)){
				mapAccountSapAccountId.put(anAccount.Id_SAP__c,anAccount.Id);
			}
		}
		System.debug('mapAccountSapAccountId');
		System.debug(mapAccountSapAccountId);
		Map<String, String> mapAccoutnIdContactId = new Map<String, String>();
		for(Contact contacto : [SELECT Id, AccountId FROM Contact WHERE AccountId IN: mapAccountSapAccountId.values()]){
			if(!mapAccoutnIdContactId.containsKey(contacto.AccountId)){
				mapAccoutnIdContactId.put(contacto.AccountId, contacto.Id);
			}
		}
		System.debug('mapAccoutnIdContactId');
		System.debug(mapAccoutnIdContactId);
		Map<String, String> mapContactIdEmail = new Map<String, String>();
		for(User usuario : [SELECT Id, Email, ContactId FROM User WHERE ContactId IN :mapAccoutnIdContactId.values()]){
			if(!mapContactIdEmail.containsKey(usuario.ContactId)){
				mapContactIdEmail.put(usuario.ContactId, usuario.Email);
			}
		}
		System.debug('mapContactIdEmail');
		System.debug(mapContactIdEmail);
		Map<String, String> mapAccountSapEmail = new Map<String, String>();
		for(String accSap : mapAccountSapAccountId.keySet()){
			String acctId = mapAccountSapAccountId.get(accSap);
			if(mapAccoutnIdContactId.containsKey(acctId)){
				String contactId = mapAccoutnIdContactId.get(acctId);
				if(mapContactIdEmail.containsKey(contactId)){
					if(!mapAccountSapEmail.containsKey(accSap)){
						mapAccountSapEmail.put(accSap, mapContactIdEmail.get(contactId));
					}
				}
			}
		}
		System.debug('mapAccountSapEmail');
		System.debug(mapAccountSapEmail);
		for(Dan360_Factura__c factura : [SELECT Id,Dan360_Id_Externo__c,
												Dan360_Cliente__c, Dan360_Remito__c,
												Dan360_NroComprobante__c,
												Dan360_Sucursal__c
										FROM Dan360_Factura__c
										WHERE Dan360_Cliente__c  IN :mapClientIdSF.values()]){
			if (!mapFacturaIdSF.containsKey(factura.Dan360_Cliente__c)) {
				mapFacturaIdSF.put(factura.Dan360_Cliente__c, new Map<String, Map<String, String>>());
			}

			if (!mapFacturaIdSF.get(factura.Dan360_Cliente__c).containsKey(factura.Dan360_Id_Externo__c)) {
				mapFacturaIdSF.get(factura.Dan360_Cliente__c).put(factura.Dan360_Id_Externo__c, new Map<String, String>());
			}

			if (!mapFacturaIdSF.get(factura.Dan360_Cliente__c).get(factura.Dan360_Id_Externo__c).containsKey(factura.Id)) {
				mapFacturaIdSF.get(factura.Dan360_Cliente__c).get(factura.Dan360_Id_Externo__c).put(factura.Id, factura.Dan360_Remito__c);
			}

			if (!mapNroComprobante.containsKey(factura.Id)) {
				mapNroComprobante.put(factura.Id, factura.Dan360_NroComprobante__c);
			}

			if (!mapSucursalIdSF.containsKey(factura.Id)) {
				mapSucursalIdSF.put(factura.Id, factura.Dan360_Sucursal__c);
			}
		}
		
		Tipo_de_documentos__c docTypes = Tipo_de_documentos__c.getOrgDefaults();

		for (String cliente : mapClientListTable.keySet()) {
			String idSF = mapClientIdSF.get(cliente);
			String email = '';
			if(mapAccountSapEmail.containsKey(cliente)) {
				email = mapAccountSapEmail.get(cliente);
			}
			
			for (Dan360_TablaIntermediaCuentaCorriente__c tabla : mapClientListTable.get(cliente)) {
				String idRegistroCC = tabla.Dan360_IdRegistro__c + '-' + tabla.Dan360_Remito__c;
				/* switch on tabla.Dan360_TipoDocumento__c {
					when 'AB', 'DZ', 'DO', 'DX' {
						idRegistroCC = null;
					}	
					when else {		 
						idRegistroCC = tabla.Dan360_IdRegistro__c;
					}
				} */

				String fechaDocumento = armarFechas(tabla.Dan360_FechaDocumento__c);
				String fechaVencimiento = armarFechas(tabla.Dan360_Vencimiento__c);
				String sfFactura;
				String sfRemito;
				String idSucursal;
				
                if(mapFacturaIdSF.containsKey(idSF)){
                    if(String.isNotBlank(tabla.Dan360_IdRegistro__c) && (mapFacturaIdSF.get(idSF).containsKey(tabla.Dan360_IdRegistro__c))){
						Map<String,String> mapIdFacturaIdRemito = mapFacturaIdSF.get(idSF).get(tabla.Dan360_IdRegistro__c);
						for (String idFactura : mapIdFacturaIdRemito.keySet()) {
							sfFactura = idFactura;
							sfRemito = mapIdFacturaIdRemito.get(idFactura);
						}
						idSucursal = mapSucursalIdSF.get(sfFactura);
					} 
                }
				String businessUnit = String.isEmpty(tabla.Dan360_CodigoEmpresaGrupo__c) ? '' : tabla.Dan360_CodigoEmpresaGrupo__c == '5770'? '5771' : '5800';
				String nroComprobante = String.isEmpty(mapNroComprobante.get(sfFactura)) ? tabla.Dan360_Remito__c : mapNroComprobante.get(sfFactura); 
                String numeroFactura = tabla.Dan360_Remito__c == null ? '' : tabla.Dan360_Remito__c.substring(4,5);
				List<String> fac = new List<String>{numeroFactura};
                String tipoDocuWithLetter;
                try{
                	String tipoDocu = (String)docTypes.get(tabla.Dan360_TipoDocumento__c+'__c');
                    tipoDocuWithLetter = String.format(tipoDocu, fac);
                } catch (Exception e) {
                    tipoDocuWithLetter = tabla.Dan360_TipoDocumento__c;
				}
				try {
					Dan360_DocumentosCuentaCorriente__c cuentaCorriente = new Dan360_DocumentosCuentaCorriente__c(
						Name = tabla.Name,
						ID_Registro__c = idRegistroCC,
						Dan360_TipoDeDocumento__c = tipoDocuWithLetter,
						Dan360_Cliente__c = idSF,
						Dan360_FechaDocumento__c = Date.valueOf(fechaDocumento),
						Dan360_Vencimiento__c =  Date.valueOf(fechaVencimiento),
						Dan360_Remito__c = sfRemito,
						Dan360_ImporteDocumento__c = Decimal.valueOf(tabla.Dan360_ImporteDocumento__c)/100,
						Dan360_Saldo__c = Decimal.valueOf(tabla.Dan360_Saldo__c)/100,
						Dan360_NroComprobante__c = nroComprobante,
						Dan360_Factura__c = sfFactura,
						Dan360_Sucursal__c = idSucursal,
						Moneda__c = tabla.Dan360_Moneda__c,
						Unidad_de_Negocio__c = businessUnit,
						Dan360_CorreoDeCliente__c = email
					);
					System.debug(cuentaCorriente);
					cuentaCorrienteLista.add(cuentaCorriente);
				} catch (Exception e) {
					System.debug(e);
				}
			}
		}
		return cuentaCorrienteLista;
	}

	public static String armarFechas(String fecha){
		String anio = fecha.substring(0,4);
		String mes = fecha.substring(4,6);
		String dia = fecha.substring(6,8);
		String nuevaFecha = anio +'-'+ mes +'-'+ dia;

		return nuevaFecha;
	}
}