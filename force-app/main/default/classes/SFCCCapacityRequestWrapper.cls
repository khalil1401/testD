/**
 * Company:      CloudGaia
 * Description:  Wrapper class for RESTCapacity request.
 * Test Class:   SFCCCapacityHelper_Test
 */
public class SFCCCapacityRequestWrapper {
    public class Products {
        public String sku;
        public Integer quantity;
    }

    public String completeAddress;
    public String customerNationalId;
    public Time cutoverTime;
    public Boolean isClosedNeighborhood;
    public List<String> poligons;
    public List<Products> products;

    public static SFCCCapacityRequestWrapper parse(String json) {
        return (SFCCCapacityRequestWrapper) System.JSON.deserialize(json, SFCCCapacityRequestWrapper.class);
    }
}