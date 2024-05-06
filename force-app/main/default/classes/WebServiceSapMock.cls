public with sharing class WebServiceSapMock {
    public static String getAltaSuccess() {
        return 
            '{' +
                '"code": 200,' +
                '"description": ""' +
            '}';
    }

    public static String getAltaError() {
        return 
            '{' +
                '"code": 500,' +
                '"description": ""' +
            '}';
    }
}