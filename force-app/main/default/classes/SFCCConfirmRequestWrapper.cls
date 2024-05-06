/**
 * Company:      CloudGaia
 * Description:  Wrapper class for RESTConfirm request.
 * Test Class:   SFCCConfirmHelper_Test
 */
public class SFCCConfirmRequestWrapper {
    public class Products {
        public String sku;
        public Integer quantity;
    }

    public String completeAddress {get;set;}
    public String customerNationalId {get;set;}
    public String orderId {get;set;}
    public String polygon {get;set;}
    public List<Products> products {get;set;}
    public String selectedDate {get;set;}
    public String selectedTime {get;set;}

    public static SFCCConfirmRequestWrapper parse(String json) {
        return (SFCCConfirmRequestWrapper) System.JSON.deserialize(json, SFCCConfirmRequestWrapper.class);
    }
}