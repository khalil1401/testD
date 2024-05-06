/**
 * Company:      CloudGaia
 * Description:  Wrapper class for RESTConfirm response.
 * Test Class:   SFCCConfirmHelper_Test
 */
public class SFCCConfirmResponseWrapper {
    public Boolean success;
    public String errorCode;
    public String zipCode;
    public String activityId;
    public String deliveryRoute;
    public String townId;
    public String sfId;

    public static SFCCConfirmResponseWrapper parse(String json) {
        return (SFCCConfirmResponseWrapper) System.JSON.deserialize(json, SFCCConfirmResponseWrapper.class);
    }
}