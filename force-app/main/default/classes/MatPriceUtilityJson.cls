public with sharing class MatPriceUtilityJson {
    
    public class Prices {
		public String materialId {get;set;} 
		public Double price {get;set;} 
		public Double discount {get;set;} 

		public Prices(JSONParser parser) {
			while (parser.nextToken() != System.JSONToken.END_OBJECT) {
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
						if (text == 'materialId') {
							materialId = parser.getText();
						} else if (text == 'price') {
							price = parser.getDoubleValue();
						} else if (text == 'discount') {
							discount = parser.getDoubleValue();
						} else {
							System.debug(LoggingLevel.WARN, 'Prices consuming unrecognized property: '+text);
							consumeObject(parser);
						}
					}
				}
			}
		}
	}
	
	public String date_Z {get;set;} // in json: date
	public String organizationId {get;set;} 
	public String channelId {get;set;} 
	public String divisionId {get;set;} 
	public String customer {get;set;} 
	public List<Prices> prices {get;set;} 

	public MatPriceUtilityJson(JSONParser parser) {
		while (parser.nextToken() != System.JSONToken.END_OBJECT) {
			if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
				String text = parser.getText();
				if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
					if (text == 'date') {
						date_Z = parser.getText();
					} else if (text == 'organizationId') {
						organizationId = parser.getText();
					} else if (text == 'channelId') {
						channelId = parser.getText();
					} else if (text == 'divisionId') {
						divisionId = parser.getText();
					} else if (text == 'customer') {
						customer = parser.getText();
					} else if (text == 'prices') {
						prices = arrayOfPrices(parser);
					} else {
						System.debug(LoggingLevel.WARN, 'MatPriceUtilityJson consuming unrecognized property: '+text);
						consumeObject(parser);
					}
				}
			}
		}
	}
	
	
	public static MatPriceUtilityJson parse(String json) {
		System.JSONParser parser = System.JSON.createParser(json);
		return new MatPriceUtilityJson(parser);
	}
	
	public static void consumeObject(System.JSONParser parser) {
		Integer depth = 0;
		do {
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT || 
				curr == System.JSONToken.START_ARRAY) {
				depth++;
			} else if (curr == System.JSONToken.END_OBJECT ||
				curr == System.JSONToken.END_ARRAY) {
				depth--;
			}
		} while (depth > 0 && parser.nextToken() != null);
	}
	
    private static List<Prices> arrayOfPrices(System.JSONParser p) {
        List<Prices> res = new List<Prices>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Prices(p));
        }
        return res;
    }
}