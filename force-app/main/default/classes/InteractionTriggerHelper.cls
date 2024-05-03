public class InteractionTriggerHelper  {
    public static void validateVisitasMedicasInteracciones(List<Interaccion__c> visitasMedicas){
        for(Interaccion__c visita : visitasMedicas){
            if(visita.Fecha__c == null){
                visita.Fecha__c.addError('Seleccione una fecha');
            }
            else if(fechaDeCreacionEsUnFeriado(visita) || fechaDeCreacionEsFinDeSemana(visita)){
                visita.Fecha__c.addError('No puede generar una Visita Médica en un día feriado o fin de semana');
            }
        }
    }
    
    public static Boolean fechaDeCreacionEsUnFeriado(Interaccion__c visita){
        for(Feriado__c feriado : [SELECT Fecha__c FROM Feriado__c]){
            if(feriado.Fecha__c == visita.Fecha__c){
                return true;
            }
        }
        return false;
    }
    
    public static void validacionParaCargaDeInteracciones(List<Interaccion__c> visitas){
        Set<Id> ciclosId = new Set<Id>();
        for(Interaccion__c interaccion : visitas){
            ciclosId.add(interaccion.ciclo__c);            
        }
        Map<id, Ciclo__c> mapCiclo = new Map<id, Ciclo__c>();
        
        List<Ciclo__c> ciclosList = [
            SELECT id,Fecha_de_inicio__c 
            FROM Ciclo__c 
            WHERE id IN :ciclosId
        ];
        
        for(Ciclo__c ciclo : ciclosList){
            mapCiclo.put(ciclo.id, ciclo);
        }
        
        List<Interaccion__c> visitasEnCiclo = [
            SELECT id,ciclo__c ,Profesional_de_la_salud__c, Ciclo__r.ContactId__r.Account.name 
            FROM Interaccion__c
            where Ciclo__c IN : ciclosList
            AND Ciclo__r.ContactId__r.Account.name ='APM Adultos'
        ];
        
        if(visitasEnCiclo.size()>0){
            List<String> profesionales = new List<String>();
            for(Interaccion__c visita : visitasEnCiclo){
                profesionales.add(visita.Profesional_de_la_salud__c);
            }
            
            for(Interaccion__c visita : visitas){
                
                boolean mesActual = visita.Fecha__c.month() ==mapCiclo.get(visita.Ciclo__c).fecha_de_inicio__c.month();
                boolean currentYear = visita.Fecha__c.year() == mapCiclo.get(visita.Ciclo__c).fecha_de_inicio__c.year();
                if(profesionales.contains(visita.Profesional_de_la_salud__c) && mesActual && currentYear){
                    visita.Profesional_de_la_salud__c.addError(Label.Error_en_interaccion);
                }
            }
        }
    }
    
    
    public static Boolean fechaDeCreacionEsFinDeSemana(Interaccion__c interaccion){
        Datetime today = Datetime.newInstance(interaccion.Fecha__c, Time.newInstance(0,0,0,0));
        string dayName = today.format('EEEE');
        if(dayName == 'Saturday' || dayName == 'Sunday'){
            return true;
        }
        return false;
    }
}