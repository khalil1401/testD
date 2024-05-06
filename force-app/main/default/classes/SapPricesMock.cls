public with sharing class SapPricesMock {
    public static string getSucess() {
        return 
        '{'+
		'    \"date\": \"2022-05-01\",'+
		'    \"organizationId\": \"5771\",'+
		'    \"channelId\": \"02\",'+
		'    \"divisionId\": \"00\",'+
		'    \"customer\": \"550071632\",'+
		'    \"prices\": ['+
		'        {'+
		'            \"materialId\": \"106959\",'+
		'            \"price\": 1249.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166578\",'+
		'            \"price\": 7290.0,'+
		'            \"discount\": 30.0'+
		'        }'+
		'    ]'+
		'}';
    }
}