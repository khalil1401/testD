@isTest
public with sharing class MatPriceUtilityJsonTest {
    static testMethod void testParse() {
		String json = '{'+
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
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"172267\",'+
		'            \"price\": 1047.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150467\",'+
		'            \"price\": 465.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150468\",'+
		'            \"price\": 442.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"165188\",'+
		'            \"price\": 2117.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"106922\",'+
		'            \"price\": 77.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"41256\",'+
		'            \"price\": 393.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166538\",'+
		'            \"price\": 440.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"111511\",'+
		'            \"price\": 2924.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"169863\",'+
		'            \"price\": 2317.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150462\",'+
		'            \"price\": 165.51,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"165190\",'+
		'            \"price\": 1770.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150456\",'+
		'            \"price\": 1470.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"78376\",'+
		'            \"price\": 1300.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"174235\",'+
		'            \"price\": 350.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"168741\",'+
		'            \"price\": 438.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"160677\",'+
		'            \"price\": 511.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"168566\",'+
		'            \"price\": 1343.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166593\",'+
		'            \"price\": 11115.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"57880\",'+
		'            \"price\": 3278.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"142904\",'+
		'            \"price\": 227.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166577\",'+
		'            \"price\": 4998.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166575\",'+
		'            \"price\": 5528.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"57856\",'+
		'            \"price\": 4464.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"146396\",'+
		'            \"price\": 7528.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"106957\",'+
		'            \"price\": 84.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"71479\",'+
		'            \"price\": 3312.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150371\",'+
		'            \"price\": 2449.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150464\",'+
		'            \"price\": 112.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"128688\",'+
		'            \"price\": 72.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"40962\",'+
		'            \"price\": 1.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166570\",'+
		'            \"price\": 10575.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"142907\",'+
		'            \"price\": 227.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"106956\",'+
		'            \"price\": 1188.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"78431\",'+
		'            \"price\": 2601.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"121290\",'+
		'            \"price\": 312.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"89681\",'+
		'            \"price\": 3028.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166572\",'+
		'            \"price\": 10080.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166574\",'+
		'            \"price\": 9495.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166576\",'+
		'            \"price\": 7560.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"168068\",'+
		'            \"price\": 1631.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150457\",'+
		'            \"price\": 1382.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166582\",'+
		'            \"price\": 6525.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150466\",'+
		'            \"price\": 105.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"70660\",'+
		'            \"price\": 3440.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150455\",'+
		'            \"price\": 1673.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"94895\",'+
		'            \"price\": 6246.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"56908\",'+
		'            \"price\": 7528.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"68695\",'+
		'            \"price\": 3364.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"144108\",'+
		'            \"price\": 4033.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"71490\",'+
		'            \"price\": 3637.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"129889\",'+
		'            \"price\": 155.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"168567\",'+
		'            \"price\": 1275.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"106954\",'+
		'            \"price\": 1044.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"129884\",'+
		'            \"price\": 155.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166580\",'+
		'            \"price\": 6930.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"78380\",'+
		'            \"price\": 1300.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166569\",'+
		'            \"price\": 7040.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"168433\",'+
		'            \"price\": 3243.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"41142\",'+
		'            \"price\": 393.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"165189\",'+
		'            \"price\": 2007.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"120505\",'+
		'            \"price\": 7787.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166573\",'+
		'            \"price\": 5880.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166579\",'+
		'            \"price\": 4752.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"165191\",'+
		'            \"price\": 1664.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"142905\",'+
		'            \"price\": 227.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"57875\",'+
		'            \"price\": 1731.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166581\",'+
		'            \"price\": 4178.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"130144\",'+
		'            \"price\": 6154.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150463\",'+
		'            \"price\": 117.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166583\",'+
		'            \"price\": 3926.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"128689\",'+
		'            \"price\": 1343.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"150454\",'+
		'            \"price\": 1760.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"164445\",'+
		'            \"price\": 1131.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"106955\",'+
		'            \"price\": 81.0,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"129888\",'+
		'            \"price\": 155.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"123525\",'+
		'            \"price\": 981.5,'+
		'            \"discount\": 0.0'+
		'        },'+
		'        {'+
		'            \"materialId\": \"166571\",'+
		'            \"price\": 6692.0,'+
		'            \"discount\": 0.0'+
		'        }'+
		'    ]'+
		'}';
		MatPriceUtilityJson r = MatPriceUtilityJson.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		MatPriceUtilityJson.Prices objPrices = new MatPriceUtilityJson.Prices(System.JSON.createParser(json));
		System.assert(objPrices != null);
		System.assert(objPrices.materialId == null);
		System.assert(objPrices.price == null);
		System.assert(objPrices.discount == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		MatPriceUtilityJson objMatPriceUtilityJson = new MatPriceUtilityJson(System.JSON.createParser(json));
		System.assert(objMatPriceUtilityJson != null);
		System.assert(objMatPriceUtilityJson.date_Z == null);
		System.assert(objMatPriceUtilityJson.organizationId == null);
		System.assert(objMatPriceUtilityJson.channelId == null);
		System.assert(objMatPriceUtilityJson.divisionId == null);
		System.assert(objMatPriceUtilityJson.customer == null);
		System.assert(objMatPriceUtilityJson.prices == null);
	}
}