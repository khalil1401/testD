public with sharing class StockXCicloTriggerHelper {

    public static void asignarStockAlAPM (List<Stock_x_Ciclo__c> stocksXCiclo) {
        Set<Id> contactId = new Set<Id>();
        List<User> users = new List<User>();
        Map<Id,Id> userIdXcontactId = new Map<Id,Id>();

        for (Stock_x_Ciclo__c stock : stocksXCiclo) {
            contactId.add(stock.APM__c);
        }

        users = [SELECT Id, ContactId FROM User WHERE ContactId IN :contactId];
        for (User usuario : users) {
            for (Stock_x_Ciclo__c stock : stocksXCiclo) {
                if (usuario.ContactId == stock.APM__c) {
                    stock.OwnerId = usuario.Id;
                }
            }
        }
    }
    
    public static void createStockXMM (List<Stock_x_Ciclo__c> stocksXCiclo) {
        System.debug('stocksXCiclo');
        System.debug(stocksXCiclo);
        List<Stock_x_Ciclo__c> stocksAnterioresAlAnterior = new List<Stock_x_Ciclo__c>();
        List<Stock_x_MM__c> stocksXMMDelCicloAnterior = new List<Stock_x_MM__c>();
        List<Stock_x_MM__c> stockXMMToInsert = new List<Stock_x_MM__c>();
        Map<Id, List<Stock_x_MM__c>> stockXMMXCiclo = new Map<Id, List<Stock_x_MM__c>>();
        Map<Id, Id> apmXstock = new Map<Id, Id>();
        List<VisMed_Ciclo__c> cicloAnterior = new List<VisMed_Ciclo__c>();

        Decimal anioDelCicloAnterior;
        Decimal mesDelCicloAnterior;

        
        for (Stock_x_Ciclo__c stock : stocksXCiclo) {
            anioDelCicloAnterior = stock.Anio__c;
            mesDelCicloAnterior = stock.Mes__c - 1;
            apmXstock.put(stock.APM__c, stock.Id);
        }
        if (mesDelCicloAnterior == 0) {
            anioDelCicloAnterior --;
            mesDelCicloAnterior = 12;
        }

        cicloAnterior = [SELECT Id, Name, Anio__c, Numero_de_mes__c FROM VisMed_Ciclo__c WHERE Anio__c = :anioDelCicloAnterior AND Numero_de_mes__c = :mesDelCicloAnterior]; // Consigo el ciclo anterior.
        if (!cicloAnterior.isEmpty()) {
            stocksAnterioresAlAnterior = [SELECT Id, Name, APM__c FROM Stock_x_Ciclo__c WHERE APM__c IN :apmXstock.keySet() AND Ciclo__c = :cicloAnterior[0].Id]; // Traigo una lista de todos los StockXCiclo.
            stocksXMMDelCicloAnterior = [SELECT Id, Name,Stock_x_Ciclo__r.APM__r.Id, Recibido__c, Remanente__c, Total__c, Stock_x_Ciclo__c, APM__c, Muestra_Medica__c FROM Stock_x_MM__c WHERE Stock_x_Ciclo__c IN :stocksAnterioresAlAnterior AND Total__c > 0]; // Consigo todos los stocXMM que quedan con remanente.
            System.debug('stocksXMMDelCicloAnterior');
            System.debug(stocksXMMDelCicloAnterior);
            for (Stock_x_MM__c stockXMM : stocksXMMDelCicloAnterior) {
                Stock_x_MM__c newStockXMM = new Stock_x_MM__c(
                    Remanente__c = stockXMM.Total__c,
                    Muestra_Medica__c = stockXMM.Muestra_Medica__c,
                    Stock_x_Ciclo__c = apmXstock.get(stockXMM.Stock_x_Ciclo__r.APM__r.Id)
                );
                stockXMMToInsert.add(newStockXMM);
            }
            System.debug('stockXMMToInsert');
            System.debug(stockXMMToInsert);
            insert stockXMMToInsert;
        } 
    }

}