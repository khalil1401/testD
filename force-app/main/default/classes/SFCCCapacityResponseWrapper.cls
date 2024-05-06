/**
 * Company:      CloudGaia
 * Description:  Wrapper class for RESTCapacity response.
 * Test Class:   SFCCCapacityHelper_Test
 */
public class SFCCCapacityResponseWrapper {
    public List<Dates> dates;
    public String storeId;
    
    public class Dates {
        public Date suggestedDate;
        public Date loadDate;
        public String polygonId;
        public Map<String, String> times;
    }

    public static SFCCCapacityResponseWrapper parse(String json) {
        return (SFCCCapacityResponseWrapper) System.JSON.deserialize(json, SFCCCapacityResponseWrapper.class);
    }
}