public class GenericParser {
    /*
    public static sObject ParseSObject(String jsonString, Type typeOf) {
        JSONParser parser = JSON.createParser(jsonString); 
        
        sObject record = (sObject)typeOf.newInstance();
        
        Map<String, Schema.SObjectField> fields = record.getsObjectType().getDescribe().fields.getMap();
        
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.FIELD_NAME) {
                
                if (fields.containsKey(parser.getText())) {
                    
                    String label = parser.getText(); 
                    
                    parser.nextValue();
                    
                    Schema.SOAPType fieldType = fields.get(label).getDescribe().getSOAPType(); 
                    
                    // Note that the enums type is not needed, just the value (TIME instead of Schema.SOAPType.TIME)
                    switch on fieldType {
                        when TIME {
                            record.put(label, ParseTime(parser.getText()));
                        } when BOOLEAN {
                            record.put(label, parser.getBooleanValue());
                        } when DOUBLE {
                            record.put(label, parser.getDoubleValue());
                        } when DATE {
                            record.put(label, parser.getDateValue());
                        } when DATETIME {
                            record.put(label, parser.getDateTimeValue());
                        } when INTEGER {
                            record.put(label, parser.getIntegerValue());
                        } when else {
                            record.put(label, parser.getText());
                        }
                    }
                }
            }
        }
        
        return record; 
    }
    
    public static Time ParseTime(String timeString) {
        // 14:26:41.276Z or "14:26:41.276Z"
        List<String> values = timeString.replace('Z', '').replace('"', '').split(':'); 
        
        // (14, 26, 41.276)         
        Integer hours = Integer.valueOf(values[0]); 
        Integer minutes = Integer.valueOf(values[1]);
        
        // 41.276 -> (41, 276) 
        //Integer seconds = Integer.valueOf(values[2].split('\\.')[0]);
        //Integer milliseconds = Integer.valueOf(values[2].split('\\.')[1]);
        Integer seconds = 0;
        Integer milliseconds = 0;
        
        return Time.newInstance(hours, minutes, seconds, milliseconds);
    }
	*/
}