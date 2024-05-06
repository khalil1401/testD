@IsTest
public class  GetErrorSOScheduleTest {

    @testSetup
    static void setup() {

        DateTime now = System.today();
        DateTime oneHourAgo = now.addHours(-1);

        Account cuenta = new Account (
            name = 'Account pruebas 1'
        );
        Insert cuenta;

        Product2 producto = new Product2(
            IsActive = true,
            Name = 'Producto de Pruebas'
        );
        INSERT producto;

        Pricebook2 pricebook = new Pricebook2(
            Name = 'PriceBook Pruebas'
        );
        Insert pricebook;

        PricebookEntry pbentry = new PricebookEntry(
            PriceBook2Id = pricebook.Id,
            Product2Id = producto.Id,
            UnitPrice = 1000.00
        );
        Insert pbentry;

        Order orden = new Order(
            AccountId = cuenta.Id,
            Status = 'Borrador',
            EffectiveDate = System.today(),
            Pricebook2Id = pricebook.Id
        );
        Insert orden;

        OrderItem item = new OrderItem(
            OrderId = orden.Id,
            Product2Id = producto.Id,
            UnitPrice = 1000.00,
            PricebookEntryId = pbentry.Id,
            Quantity = 1
        );
        Insert item;


        // orden.Status = 'Confirmado';
        // Update orden;
    }

    // Ordenes Confirmadas
    @IsTest
    public static void GetErrorSOScheduleTest() {

        Boolean existenOrdenesConfirmadas = false;

        Test.StartTest();
            BatchGetOrderSyncErrors batchItem = new BatchGetOrderSyncErrors();
            Id batchId = Database.executeBatch(batchItem);

        Test.stopTest();
        List<Order> ordenesConStatusConfirmado = [SELECT Id, OrderNumber, LastModifiedDate, CreatedBy.Name,LastModifiedBy.Name
        FROM Order  
        WHERE  Status  = 'Confirmado'  
        AND Status_SAP__c = NULL ];

        if(ordenesConStatusConfirmado.size() > 0) {
            existenOrdenesConfirmadas = true;
        }

        System.assertEquals(existenOrdenesConfirmadas, true);
    }

    // Ordenes No Confirmadas
}