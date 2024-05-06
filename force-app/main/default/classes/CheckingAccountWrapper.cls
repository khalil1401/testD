public with sharing class CheckingAccountWrapper {
	@AuraEnabled
	public String Id; // Id
	@AuraEnabled
	public String Name; // Name
	@AuraEnabled
	public String DocumentType; // Dan360_TipoDeDocumento__c
	@AuraEnabled
	public String ProofNumber; // Dan360_NroComprobante__c
	@AuraEnabled
	public String ClientCode; // Dan360_CodigoCliente__c
	@AuraEnabled
	public String Client; // Dan360_Cliente__c
	@AuraEnabled
	public Date DocumentDate; // Dan360_FechaDocumento__c
	@AuraEnabled
	public Date DueDate; // Dan360_Vencimiento__c
	@AuraEnabled
	public String DeliveryNote; // Dan360_Remito__c
	@AuraEnabled
	public Decimal DaysPastDue; // Dan360_DiasDeVencido__c
	@AuraEnabled
	public String DocumentAmount; // Dan360_ImporteDocumento__c
	@AuraEnabled
	public Decimal Remainder; // Dan360_Saldo__c
	@AuraEnabled
	public String TrafficLight; // Dan360_Semaforo__c
	@AuraEnabled
	public Decimal AccumulatedBalance; // Dan360_Acumulado__c

	public CheckingAccountWrapper(
		Id id,
		String name,
		String documentType,
		String proofNumber,
		String clientCode,
		String client,
		Date documentDate,
		Date dueDate,
		String deliveryNote,
		Decimal daysPastDue,
		String documentAmount,
		Decimal remainder,
		String trafficLight,
		Decimal accumulatedBalance
	) {
		this.Id = id;
		this.Name = name;
		this.DocumentType = documentType;
		this.ProofNumber = proofNumber;
		this.ClientCode = clientCode;
		this.Client = client;
		this.DocumentDate = documentDate;
		this.DueDate = dueDate;
		this.DeliveryNote = deliveryNote;
		this.DaysPastDue = daysPastDue;
		this.DocumentAmount = documentAmount;
		this.Remainder = remainder;
		this.TrafficLight = trafficLight;
		this.AccumulatedBalance = accumulatedBalance;
	}
}