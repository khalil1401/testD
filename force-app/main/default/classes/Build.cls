/**
 * @description       : Plantilla para crear objetos.
 * @author            : Leonardo Jimenez
 * @group             :
 * @last modified on  : 22-08-2022
 * @last modified by  : Diego Valle
 **/
@isTest
public with sharing class Build {
	/*------------------------------------------------------------------------
		AccountBuilderStart
	------------------------------------------------------------------------*/
	public class AccountBuilder {
		// private Account obj = new Account(Name = 'Test ' + Math.random() * 100);
		private Account obj = new Account();

		public AccountBuilder withPriceBook(String value) {
			obj.Dan360_ListaPrecios__c = value;
			return this;
		}

		public AccountBuilder withPrincipalAccount(String value) {
			obj.ParentId = value;
			return this;
		}

		public AccountBuilder withIdSap(String value) {
			obj.Id_SAP__c = value;
			return this;
		}

		public AccountBuilder withGLN(Decimal value){
			obj.Dan360_StoreEAN__c = value;
			return this;
		}

		public AccountBuilder withPricebook(Id value) {
			obj.Dan360_ListaPrecios__c = value;
			return this;
		}

		public AccountBuilder withCanalComercial(String value) {
			obj.Dan360_CanalComercial__c = value;
			return this;
		}

		public AccountBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public AccountBuilder withLastName(String value) {
			obj.Name = value;
			return this;
		}

		public AccountBuilder withRecordType(String value) {
			obj.RecordType.Name = value;
			return this;
		}

		public AccountBuilder withRecordTypeId(Id value) {
			obj.RecordTypeId = value;
			return this;
		}

		public AccountBuilder withSalesDistric(String value) {
			obj.Dan360_SalesDistric1__c = value;
			return this;
		}

		public AccountBuilder withDistributionChannel(String value) {
			obj.Dan360_DistributionChannel__c = value;
			return this;
		}

		public Account build() {
			return obj;
		}
	}

	public static AccountBuilder anAccount() {
		return new AccountBuilder();
	}

	/*------------------------------------------------------------------------
		AccountBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		ContactBuilderStart
	------------------------------------------------------------------------*/
	public class ContactBuilder {
		Contact contact = new Contact(LastName = 'Apellido ' + Math.random() * 100);

		public ContactBuilder withFirstName(String value) {
			contact.FirstName = value;
			return this;
		}

		public ContactBuilder withLastName(String value) {
			contact.LastName = value;
			return this;
		}

		public ContactBuilder withEmail(String value) {
			contact.Email = value;
			return this;
		}

		public ContactBuilder withAccount(account value) {
			contact.AccountId = value.id;
			return this;
		}

		public ContactBuilder withRecordType(String value) {
			contact.RecordTypeId = value;
			return this;
		}

		public Contact build() {
			return contact;
		}
	}

	public static ContactBuilder aContact() {
		return new ContactBuilder();
	}

	public static ContactBuilder aContactVisitadorMedico() {
		ContactBuilder val = new ContactBuilder();
		val.contact.RecordTypeId = XappiaHelper.getRecordType('Contact', 'Visitador_Medico').Id;
		return val;
	}

	/*------------------------------------------------------------------------
		ContactBuilderEnd
	------------------------------------------------------------------------*/
	/*------------------------------------------------------------------------
		UserBuilderStart
	------------------------------------------------------------------------*/
	public class UserBuilder {
		private User obj = new User();

		public UserBuilder withContactId(Contact value) {
			obj.ContactId = value.Id;
			return this;
		}

		public UserBuilder withUsername(String value) {
			obj.Username = value;
			return this;
		}

		public UserBuilder withLastName(String value) {
			obj.LastName = value;
			return this;
		}

		public UserBuilder withEmail(String value) {
			obj.Email = value;
			return this;
		}

		public UserBuilder withAlias(String value) {
			obj.Alias = value;
			return this;
		}

		public UserBuilder withTimeZoneSidKey(String value) {
			obj.TimeZoneSidKey = value;
			return this;
		}

		public UserBuilder withLocaleSidKey(String value) {
			obj.LocaleSidKey = value;
			return this;
		}

		public UserBuilder withCommunityNickname(String value) {
			obj.CommunityNickname = value;
			return this;
		}

		public UserBuilder withUserRoleId(UserRole value) {
			obj.UserRoleId = value.Id;
			return this;
	   }

		public UserBuilder withEmailEncodingKey(String value) {
			obj.EmailEncodingKey = value;
			return this;
		}

		public UserBuilder withProfileId(String value) {
			obj.ProfileId = value;
			return this;
		}

		public UserBuilder withLanguageLocaleKey(String value) {
			obj.LanguageLocaleKey = value;
			return this;
		}

		public User build() {
			return obj;
		}

	}

	public static UserBuilder aUser() { return new UserBuilder(); }

	/*------------------------------------------------------------------------
		UserBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		OrderBuilderStart
	------------------------------------------------------------------------*/
	public class OrderBuilder {
		Order obj = new Order();

		public OrderBuilder withAccount(Account value) {
			obj.AccountId = value.id;
			return this;
		}

		public OrderBuilder withIdExterno(String value) {
			obj.Dan360_Id_Externo__c = value;
			return this;
		}

		public OrderBuilder withCustomerSalesArea(Dan360_CustomerSalesArea__c value) {
			obj.Dan360_CustomerSalesArea__c = value.Id;
			return this;
		}

		public OrderBuilder withStatus(String value) {
			obj.Status = value;
			return this;
		}

		public OrderBuilder withStatusCode(String value) {
			obj.StatusCode = value;
			return this;
		}

		public OrderBuilder withEffectiveDate(Date value) {
			obj.EffectiveDate = value;
			return this;
		}

		public OrderBuilder withEndDate(Date value) {
			obj.EndDate = value;
			return this;
		}

		public OrderBuilder withFechaInicioCarrito(Datetime value) {
			obj.Dan360_FechaInicioCarrito__c = value;
			return this;
		}

		public OrderBuilder withFechaCierreCarrito(Datetime value) {
			obj.Dan360_FechaCierreCarrito__c = value;
			return this;
		}

		public OrderBuilder withBusinessUnit(String value) {
			obj.Dan360_UnidadNegocio__c = value;
			return this;
		}

		public OrderBuilder withPricebook(String value) {
			obj.Pricebook2Id = value;
			return this;
		}

		public OrderBuilder withPurchaseOrder(String value) {
			obj.Orden_de_compra__c = value;
			return this;
		}

		public OrderBuilder withProductsTemplate(Dan360_PlantillaDeProductos__c value) {
			obj.Dan360_PlantillaProductos__c = value.Id;
			return this;
		}

		public OrderBuilder withSemaforo(String value) {
			obj.Dan360_SemaforoPicklist__c = value;
			return this;
		}

		public OrderBuilder withRecordType(String value) {
			obj.RecordTypeId = value;
			return this;
		}

		public OrderBuilder withDescription(String value) {
			obj.Description = value;
			return this;
		}

		public Order build() {
			return obj;
		}
	}

	public static OrderBuilder anOrder() {
		return new OrderBuilder();
	}

	/*------------------------------------------------------------------------
		OrderBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		OrderItemBuilderStart
	------------------------------------------------------------------------*/
	public class OrderItemBuilder {
		OrderItem obj = new OrderItem();

		public OrderItemBuilder withOrder(Order value) {
			obj.OrderId = value.Id;
			return this;
		}

		public OrderItemBuilder withProduct2Id(Product2 value) {
			obj.Product2Id = value.Id;
			return this;
		}

		public OrderItemBuilder withProduct2Id(Id value) {
			obj.Product2Id = value;
			return this;
		}

		public OrderItemBuilder withListPrice(Decimal value) {
			obj.Dan360_ListPrice__c = value;
			return this;
		}

		public OrderItemBuilder withUnitPrice(Decimal value) {
			obj.UnitPrice = value;
			return this;
		}

		public OrderItemBuilder withQuantity(Decimal value) {
			obj.Quantity = value;
			return this;
		}

		public OrderItemBuilder withPricebookEntryId(PricebookEntry value) {
			obj.PricebookEntryId = value.Id;
			return this;
		}

		public OrderItemBuilder withDiscount(Decimal value) {
			obj.Dan360_Descuento__c = value;
			return this;
		}

		public OrderItemBuilder withUnidadMedida(String value) {
			obj.Dan360_UnidadMedida__c = value;
			return this;
		}

		public OrderItem build() {
			return obj;
		}
	}

	public static OrderItemBuilder anOrderItem() {
		return new OrderItemBuilder();
	}

	/*------------------------------------------------------------------------
		OrderItemBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Product2BuilderStart
	------------------------------------------------------------------------*/
	public class Product2Builder {
		private Product2 obj = new Product2(Name = 'STRING');

		public Product2Builder withName(String value) {
			obj.Name = value;
			return this;
		}

		public Product2Builder withProductCode(String value) {
			obj.ProductCode = value;
			return this;
		}

		public Product2Builder withEan(String value) {
			obj.Dan360_ean13__c = value;
			return this;
		}
		

		public Product2Builder withIdSap(String value) {
			obj.Id_SAP__c = value;
			return this;
		}

		public Product2Builder withDescription(String value) {
			obj.Description = value;
			return this;
		}

		public Product2Builder withIsActive(Boolean value) {
			obj.IsActive = value;
			return this;
		}

		public Product2Builder withQuantityUnitOfMeasure(String value) {
			obj.QuantityUnitOfMeasure = value;
			return this;
		}

		public Product2Builder withUnidadesBulto(Integer value) {
			obj.Dan360_UnidadesPorBulto__c = value;
			return this;
		}

		public Product2 build() {
			return obj;
		}
	}

	public static Product2Builder aProduct() {
		return new Product2Builder();
	}

	/*------------------------------------------------------------------------
		Product2BuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Pricebook2BuilderStart
	------------------------------------------------------------------------*/
	public class Pricebook2Builder {
		Pricebook2 obj = new Pricebook2();

		public Pricebook2Builder withName(String value) {
			obj.Name = value;
			return this;
		}

		public Pricebook2Builder withCustomerSalesArea(Dan360_CustomerSalesArea__c value){
			obj.Dan360_CustomerSalesArea__c = value.Id;
			return this;
		}

		public Pricebook2Builder isCombinedList(String value) {
			obj.Id_lista_combinada__c = value;
			return this;
		}

		public Pricebook2Builder isActive(boolean value) {
			obj.IsActive = value;
			return this;
		}


		public Pricebook2 build() {
			return obj;
		}
	}

	public static Pricebook2Builder aPricebook() {
		return new Pricebook2Builder();
	}

	/*------------------------------------------------------------------------
		Pricebook2BuilderEnd
		------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		PricebookEntryBuilderStart
	------------------------------------------------------------------------*/
	public class PricebookEntryBuilder {
		private PricebookEntry obj = new PricebookEntry(UnitPrice = 1.1);

		public PricebookEntryBuilder withPricebook2Id(Id value) {
			obj.Pricebook2Id = value;
			return this;
		}

		public PricebookEntryBuilder withProduct2Id(Product2 value) {
			obj.Product2Id = value.Id;
			return this;
		}

		public PricebookEntryBuilder withUnitPrice(Decimal value) {
			obj.UnitPrice = value;
			return this;
		}

		public PricebookEntryBuilder withIsActive(Boolean value) {
			obj.IsActive = value;
			return this;
		}

		public PricebookEntryBuilder withUseStandardPrice(Boolean value) {
			obj.UseStandardPrice = value;
			return this;
		}

		public PricebookEntryBuilder withUnitOfMeasure(String value) {
			obj.Dan360_UnidadMedida__c = value;
			return this;
		}

		public PricebookEntryBuilder withDiscount(Decimal value) {
			obj.Dan360_Descuento__c = value;
			return this;
		}

		public PricebookEntryBuilder withExternalId(String value) {
			obj.Dan360_IDExterno__c = value;
			return this;
		}

		public PricebookEntry build() {
			return obj;
		}
	}

	/** It require following fields to can be inserted: Pricebook2Id, Product2Id. */
	public static PricebookEntryBuilder aPricebookEntry() {
		return new PricebookEntryBuilder();
	}

	/*------------------------------------------------------------------------
		PricebookEntryBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		PlantillaDeProductosStart
	------------------------------------------------------------------------*/
	public class PlantillaDeProductosBuilder {
		Dan360_PlantillaDeProductos__c obj = new Dan360_PlantillaDeProductos__c(
			Name = 'Nombre ' + Math.random() * 100
		);

		public PlantillaDeProductosBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public PlantillaDeProductosBuilder withBusinessUnit(String value) {
			obj.Dan360_UnidadNegocio__c = value;
			return this;
		}

		public Dan360_PlantillaDeProductos__c build() {
			return obj;
		}
	}

	public static PlantillaDeProductosBuilder aPlantillaDeProductos() {
		return new PlantillaDeProductosBuilder();
	}

	/*------------------------------------------------------------------------
		PlantillaDeProductosEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		ProductoPorPlantillaStart
	------------------------------------------------------------------------*/
	public class ProductoPorPlantillaBuilder {
		Dan360_ProductoPorPlantilla__c obj = new Dan360_ProductoPorPlantilla__c();

		public ProductoPorPlantillaBuilder withProduct(Product2 value) {
			obj.Dan360_Producto__c = value.Id;
			return this;
		}
		public ProductoPorPlantillaBuilder withIsActive(Boolean value) {
			obj.Dan360_Activo__c = value;
			return this;
		}

		public ProductoPorPlantillaBuilder withProductTemplate(Dan360_PlantillaDeProductos__c value) {
			obj.Dan360_PlantillaProductos__c = value.id;
			return this;
		}

		// Opciones : Trade Unit, Unidad
		public ProductoPorPlantillaBuilder withUnitMeasure(String value) {
			obj.Dan360_UnidadDeMedida__c = value;
			return this;
		}

		public ProductoPorPlantillaBuilder withVigencia(Date value) {
			obj.Dan360_Vigencia__c = value;
			return this;
		}

		public ProductoPorPlantillaBuilder withVigenciaDesde(Date value) {
			obj.Dan360_VigenciaDesde__c = value;
			return this;
		}

		public Dan360_ProductoPorPlantilla__c build() {
			return obj;
		}
	}

	public static ProductoPorPlantillaBuilder aProductoPorPlantilla() {
		return new ProductoPorPlantillaBuilder();
	}

	/*------------------------------------------------------------------------
		ProductoPorPlantillaEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		PlantillaPorCuentaStart
	------------------------------------------------------------------------*/
	public class PlantillaporCuentaBuilder {
		dAN360_PlantillaporcCuenta__c obj = new dAN360_PlantillaporcCuenta__c();

		public PlantillaporCuentaBuilder withAccount(account value) {
			obj.Dan360_Cuenta__c = value.Id;
			return this;
		}

		public PlantillaporCuentaBuilder withPlantillaDeProductos(
			Dan360_PlantillaDeProductos__c value
		) {
			obj.Dan360_PlantillaDeProductos__c = value.id;
			return this;
		}

		//Opciones: AMN , NuBa
		public PlantillaporCuentaBuilder withBusinessUnit(String value) {
			obj.Dan360_UnidadNegocio__c = value;
			return this;
		}

		public dAN360_PlantillaporcCuenta__c build() {
			return obj;
		}
	}

	public static PlantillaporCuentaBuilder aPlantillaPorCuenta() {
		return new PlantillaporCuentaBuilder();
	}

	/*------------------------------------------------------------------------
		PlantillaPorCuentaEnd
		------------------------------------------------------------------------*/


	/*------------------------------------------------------------------------
		Dan360_Partner__cBuilderStart
	------------------------------------------------------------------------*/
	public class PartnerBuilder {
		Dan360_Partner__c obj = new Dan360_Partner__c();

		public PartnerBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public PartnerBuilder withIdExterno(String value) {
			obj.Dan360_Id_Externo__c = value;
			return this;
		}

		public PartnerBuilder withClient(Account value) {
			obj.Dan360_Customer__c = value.Id;
			return this;
		}

		public PartnerBuilder withCustomerSalesArea(Dan360_CustomerSalesArea__c value) {
			obj.Dan360_CustomerSalesArea__c = value.Id;
			return this;
		}

		// Payer , Sold to , Ship to, Bill to
		public PartnerBuilder withRol(String value) {
			obj.Dan360_Rol__c = value;
			return this;
		}


		public Dan360_Partner__c build() {
			return obj;
		}
	}

	public static PartnerBuilder aPartner() {
		return new PartnerBuilder();
	}

	/*------------------------------------------------------------------------
	Dan360_Partner__cBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Dan360_CustomerSalesArea__c Builder Start
	------------------------------------------------------------------------*/
	public class CustomerSalesAreaBuilder {
		Dan360_CustomerSalesArea__c obj = new Dan360_CustomerSalesArea__c();

		public CustomerSalesAreaBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public CustomerSalesAreaBuilder withClient(Account value) {
			obj.Dan360_Customer__c = value.Id;
			return this;
		}

		public CustomerSalesAreaBuilder withUnidadNegocio(Dan360_SalesArea__c value) {
			obj.Dan360_SalesArea__c = value.Id;
			return this;
		}

		public CustomerSalesAreaBuilder withBlock(Boolean value) {
			obj.Dan360_Block__c = value;
			return this;
		}

		public CustomerSalesAreaBuilder withIdExterno(String value) {
			obj.Dan360_Id_Externo__c = value;
			return this;
		}

		public Dan360_CustomerSalesArea__c build() {
			return obj;
		}
	}

	public static CustomerSalesAreaBuilder aCustomerSalesArea() {
		return new CustomerSalesAreaBuilder();
	}

	/*------------------------------------------------------------------------
	Dan360_CustomerSalesArea__c Builder End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Dan360_SalesArea__c Builder Start
	------------------------------------------------------------------------*/
	public class SalesAreaBuilder {
		Dan360_SalesArea__c obj = new Dan360_SalesArea__c();

		public SalesAreaBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public SalesAreaBuilder withDistributionChannel(String value) {
			obj.Dan360_DistributionChannel__c = value;
			return this;
		}

		public SalesAreaBuilder withDivision(String value) {
			obj.Dan360_Division__c = value;
			return this;
		}

		public SalesAreaBuilder withSalesOrganization(String value) {
			obj.Dan360_SalesOrganization__c = value;
			return this;
		}

		public SalesAreaBuilder withIdExterno(String value) {
			obj.Dan360_Id_Externo__c = value;
			return this;
		}

		public Dan360_SalesArea__c build() {
			return obj;
		}
	}

	public static SalesAreaBuilder aSalesArea() {
		return new SalesAreaBuilder();
	}

	/*------------------------------------------------------------------------
	Dan360_SalesArea__c Builder End
	------------------------------------------------------------------------*/
	/*------------------------------------------------------------------------
	Dan360_ProductSalesArea__c Builder Start
	------------------------------------------------------------------------*/
	public class ProductSalesAreaBuilder {
		Dan360_ProductSalesArea__c obj = new Dan360_ProductSalesArea__c();

		public ProductSalesAreaBuilder withBloqueo(Boolean value) {
			obj.Bloqueo__c = value;
			return this;
		}

		public ProductSalesAreaBuilder withSalesArea(Dan360_SalesArea__c value) {
			obj.Dan360_SalesArea__c = value.Id;
			return this;
		}

		public ProductSalesAreaBuilder withProduct(Product2 value) {
			obj.Dan360_Producto__c = value.Id;
			return this;
		}


		public Dan360_ProductSalesArea__c build() {
			return obj;
		}
	}

	public static ProductSalesAreaBuilder aProductSalesArea() {
		return new ProductSalesAreaBuilder();
	}

	/*------------------------------------------------------------------------
	Dan360_ProductSalesArea__c Builder End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Cuota Start
	------------------------------------------------------------------------*/

	public class cuotaBuilder{

		Dan360_Cuota__c obj = new Dan360_Cuota__c();

		// Opciones CanalComecial: Acceso, Disprofarma, Distribuidor, E-Commerce, Employees, Export, Farmacity, Health Care, Home Care, Institutions, Intercompany, Marketing, MeLi, Modern Trade, Others, Pharmacy, Proximity, Tender management
		public cuotaBuilder withCanalComercial(String value) {
			obj.Dan360_CanalComercial__c = value;
			return this;
		}

		// Opciones CanalDistribucion: Venta Estándar, E-Commerce
		public cuotaBuilder withCanalDistribucion(String value) {
			obj.Dan360_CanalDistribucion__c = value;
			return this;
		}

		public cuotaBuilder withCliente(Account value) {
			obj.Dan360_Cliente__c = value.Id;
			return this;
		}

		public cuotaBuilder withCuota(Integer value) {
			obj.Dan360_Cuota__c = value;
			return this;
		}

		public cuotaBuilder withCuotaActiva(String value) {
			obj.Dan360_EstadoCuota__c = value;
			return this;
		}

		public cuotaBuilder withProducto(Product2 value) {
			obj.Dan360_Producto__c = value.Id;
			return this;
		}

		public cuotaBuilder withSaldo(Integer value) {
			obj.Dan360_Saldo__c = value;
			return this;
		}

		public cuotaBuilder withVigenciaDesde(Date value) {
			obj.Dan360_VigenciaDesde__c = value;
			return this;
		}

		public cuotaBuilder withVigenciaHasta(Date value) {
			obj.Dan360_VigenciaHasta__c = value;
			return this;
		}

		public Dan360_Cuota__c build() {
			return obj;
		}

	}

	public static cuotaBuilder aCuota(){
		return new cuotaBuilder();
	}


	/*------------------------------------------------------------------------
	Cuota End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Factura Start
	------------------------------------------------------------------------*/

	public class FacturaBuilder {
		Dan360_Factura__c obj = new Dan360_Factura__c();

		public FacturaBuilder withPedido(Order value) {
			obj.Dan360_Pedido__c = value.Id;
			return this;
		}

		public FacturaBuilder withRemito(Dan360_Remito__c value) {
			obj.Dan360_Remito__c = value.Id;
			return this;
		}

		public FacturaBuilder withSucursal(Account value) {
			obj.Dan360_Sucursal__c = value.Id;
			return this;
		}

		public FacturaBuilder withClient(Account value){
			obj.Dan360_Cliente__c = value.Id;
			return this;
		}

		public Dan360_Factura__c build() {
			return obj;
		}
	}

	public static FacturaBuilder aFactura() {
		return new FacturaBuilder();
	}


	/*------------------------------------------------------------------------
	Factura End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Remito Start
	------------------------------------------------------------------------*/

	public class RemitoBuilder {
		Dan360_Remito__c obj = new Dan360_Remito__c();

		public RemitoBuilder withPedido(Order value) {
			obj.Dan360_Pedido__c = value.Id;
			return this;
		}

		public RemitoBuilder withSucursal(Account value) {
			obj.Dan360_Sucursal__c = value.Id;
			return this;
		}

		public RemitoBuilder withFecha(Date value) {
			obj.Dan360_Fecha__c = value;
			return this;
		}

		public RemitoBuilder withDelivery(String value) {
			obj.Dan360_Delivery__c = value;
			return this;
		}

		public Dan360_Remito__c build() {
			return obj;
		}
	}

	public static RemitoBuilder aRemito() {
		return new RemitoBuilder();
	}


	/*------------------------------------------------------------------------
		Remito End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Producto de Factura Start
	------------------------------------------------------------------------*/

	public class ProductoDeFacturaBuilder {
		Dan360_ProductoDeFactura__c obj = new Dan360_ProductoDeFactura__c();

		public ProductoDeFacturaBuilder withCantidadProductoFacturado(Decimal value) {
			obj.Dan360_CantidadProductoFacturado__c = value;
			return this;
		}

		public ProductoDeFacturaBuilder withFactura(Dan360_Factura__c value) {
			obj.Dan360_Factura__c = value.Id;
			return this;
		}

		public ProductoDeFacturaBuilder withProducto(Product2 value) {
			obj.Dan360_Producto__c = value.Id;
			return this;
		}

		public ProductoDeFacturaBuilder withPrecioUnitario (Decimal value) {
			obj.Dan360_PrecioUnitario__c = value;
			return this;
		}

		public Dan360_ProductoDeFactura__c build() {
			return obj;
		}
	}

	public static ProductoDeFacturaBuilder aProductoDeFactura() {
		return new ProductoDeFacturaBuilder();
	}


	/*------------------------------------------------------------------------
	Producto de Factura End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Reclamo Start
	------------------------------------------------------------------------*/
	public class ReclamoBuilder {
		Case obj = new Case();

		public ReclamoBuilder withAccount(Account value) {
			obj.AccountId = value.Id;
			return this;
		}

		public ReclamoBuilder withCantidadADevolver(String value) {
			obj.Dan360_Cantidad_a_Devolver__c = value;
			return this;
		}

		public ReclamoBuilder withDiferenciaDePrecio(String value) {
			obj.Dan360_DiferenciaDePrecio__c = value;
			return this;
		}

		public ReclamoBuilder withCantidadProductosFaltantes(String value) {
			obj.Dan360_ProductosYCantidadesFaltantes__c = value;
			return this;
		}

		public ReclamoBuilder withFactura(Dan360_Factura__c value) {
			obj.Dan360_Factura__c = value.Id;
			return this;
		}

		public ReclamoBuilder withMotivoDeReclamo(String value) {
			obj.Dan360_MotivoDeReclamo__c = value;
			return this;
		}

		public ReclamoBuilder withPedido(Id value) {
			obj.Dan360_Pedido__c = value;
			return this;
		}

		public ReclamoBuilder withRemito(Id value) {
			obj.Dan360_Remito__c = value;
			return this;
		}

		public ReclamoBuilder withSucursal(Account value) {
			obj.Dan360_Sucursal__c = value.Id;
			return this;
		}

		public ReclamoBuilder withRecordType(Id value) {
			obj.RecordTypeId = value;
			return this;
		}

		public Case build() {
			return obj;
		}
	}

	public static ReclamoBuilder aReclamo() {
		return new ReclamoBuilder();
	}
	/*------------------------------------------------------------------------
	Reclamo Start
	------------------------------------------------------------------------*/


	/*------------------------------------------------------------------------
	Producto de Factura Start
	------------------------------------------------------------------------*/

	public class ProductoDeReclamoBuilder {
		Dan360_ProductosDeReclamo__c obj = new Dan360_ProductosDeReclamo__c();

		public ProductoDeReclamoBuilder withUnidadMedida(String value) {
			obj.Dan360_UnidadMedidaProducto__c = value;
			return this;
		}

		public ProductoDeReclamoBuilder withIdLinea(String value) {
			obj.Dan360_IDLineaReferenciaSAP__c = value;
			return this;
		}

		public ProductoDeReclamoBuilder withCantidadDevolver(String value) {
			obj.Dan360_CantidadDevolver__c = value;
			return this;
		}

		/* public ProductoDeReclamoBuilder withDiferenciaDePrecio(String value) {
			obj.Dan360_DiferenciaPrecio__c = value;
			return this;
		} */

		public ProductoDeReclamoBuilder withCantidadProductosFaltantes(String value) {
			obj.Dan360_CantidadProductoFaltante__c = value;
			return this;
		}

		public ProductoDeReclamoBuilder withProducto(Product2 value) {
			obj.Dan360_Producto__c = value.Id;
			return this;
		}

		public ProductoDeReclamoBuilder withReclamo(Id value) {
			obj.Dan360_Reclamo__c = value;
			return this;
		}

		public ProductoDeReclamoBuilder withRecordType(RecordType value) {
			obj.RecordType = value;
			return this;
		}

		public Dan360_ProductosDeReclamo__c build() {
			return obj;
		}
	}

	public static ProductoDeReclamoBuilder aProductoDeReclamo() {
		return new ProductoDeReclamoBuilder();
	}


	/*------------------------------------------------------------------------
	Producto de Factura End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Producto de Remito Start
	------------------------------------------------------------------------*/

	public class ProductoDeRemitoBuilder {
		Dan360_ProductoDeRemito__c obj = new Dan360_ProductoDeRemito__c();

		public ProductoDeRemitoBuilder withCantidadProducto(Decimal value) {
			obj.Dan360_CantidadProducto__c = value;
			return this;
		}

		public ProductoDeRemitoBuilder withProducto(Product2 value) {
			obj.Dan360_Producto__c = value.Id;
			return this;
		}

		public ProductoDeRemitoBuilder withRemito(Dan360_Remito__c value) {
			obj.Dan360_Remito__c = value.Id;
			return this;
		}

		public Dan360_ProductoDeRemito__c build() {
			return obj;
		}
	}

	public static ProductoDeRemitoBuilder aProductoDeRemito() {
		return new ProductoDeRemitoBuilder();
	}

	/*------------------------------------------------------------------------
	Producto de Remito End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Documentos De Cuenta Corriente Start
	------------------------------------------------------------------------*/

	public class DocumentoCuentaCorrienteBuilder {
		Dan360_DocumentosCuentaCorriente__c obj = new Dan360_DocumentosCuentaCorriente__c();

		public DocumentoCuentaCorrienteBuilder withTipoDeDocumento(String value) {
			obj.Dan360_TipoDeDocumento__c = value;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withNroComprobante(String value) {
			obj.Dan360_NroComprobante__c = value;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withCliente(Account account) {
			obj.Dan360_Cliente__c = account.Id;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withFechaDocumento(Date value) {
			obj.Dan360_FechaDocumento__c = value;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withVencimiento(Date value) {
			obj.Dan360_Vencimiento__c = value;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withRemito(Dan360_Remito__c deliveryNote) {
			obj.Dan360_Remito__c = deliveryNote.Id;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withImporteDocumento(Decimal value) {
			obj.Dan360_ImporteDocumento__c = value;
			return this;
		}


		public DocumentoCuentaCorrienteBuilder withSaldo(Decimal value) {
			obj.Dan360_Saldo__c = value;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withPedido(Order order) {
			obj.Dan360_Pedido__c = order.Id;
			return this;
		}

		public DocumentoCuentaCorrienteBuilder withCorreo(String value) {
			obj.Dan360_CorreoDeCliente__c = value;
			return this;
		}

		public Dan360_DocumentosCuentaCorriente__c build() {
			return obj;
		}
	}

	public static DocumentoCuentaCorrienteBuilder aDocumentoCuentaCorriente() {
		return new DocumentoCuentaCorrienteBuilder();
	}

	/*------------------------------------------------------------------------
		Documentos De Cuenta Corriente End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Tabla Intermedia De Cuenta Corriente Start
	------------------------------------------------------------------------*/

	public class TablaIntermediaCuentaCorrienteBuilder {
		Dan360_TablaIntermediaCuentaCorriente__c obj = new Dan360_TablaIntermediaCuentaCorriente__c();

		public TablaIntermediaCuentaCorrienteBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withCodigoCliente(String value) {
			obj.Dan360_CodigoCliente__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withCodigoEmpresaGrupo(String value) {
			obj.Dan360_CodigoEmpresaGrupo__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withIdRegistro(String value) {
			obj.Dan360_IdRegistro__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withTipoDeDocumento(String value) {
			obj.Dan360_TipoDocumento__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withFechaDocumento(String value) {
			obj.Dan360_FechaDocumento__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withVencimiento(String value) {
			obj.Dan360_Vencimiento__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withRemito(String value) {
			obj.Dan360_Remito__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withImporteDocumento(String value) {
			obj.Dan360_ImporteDocumento__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withMoneda(String value) {
			obj.Dan360_Moneda__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withSaldo(String value) {
			obj.Dan360_Saldo__c = value;
			return this;
		}

		public TablaIntermediaCuentaCorrienteBuilder withOrdenAplicacion(String value) {
			obj.Dan360_OrdenAplicacion__c = value;
			return this;
		}

		public Dan360_TablaIntermediaCuentaCorriente__c build() {
			return obj;
		}
	}

	public static TablaIntermediaCuentaCorrienteBuilder aTablaIntermediaCuentaCorriente() {
		return new TablaIntermediaCuentaCorrienteBuilder();
	}

	/*------------------------------------------------------------------------
		Tabla Intermedia De Cuenta Corriente End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Dan360MatriculaBuilderStart
	------------------------------------------------------------------------*/

	public class Dan360MatriculaBuilder {
		private Dan360_Matricula__c obj = new Dan360_Matricula__c();

		public Dan360MatriculaBuilder withRecordTypeId(RecordType value) {
			obj.RecordTypeId = value.Id;
			return this;
		}

		/** (2021-09-06 04:42:17) Valores disponibles:  'Buenos Aires', 'CABA', 'Catamarca', 'Chaco', 'Chubut', 'Córdoba', 'Corrientes', 'Entre Ríos', 'Formosa', 'Jujuy', 'La Pampa', 'La Rioja', 'Mendoza', 'Misiones', 'Neuquén', 'Río Negro', 'Salta', 'San Juan', 'San Luis', 'Santa Cruz', 'Santa Fe', 'Santiago del Estero', 'Tierra del Fuego', 'Tucumán' */
		public Dan360MatriculaBuilder withProvincia(String value) {
			obj.Provincia__c = value;
			return this;
		}

		public Dan360MatriculaBuilder withNumerodematricula(String value) {
			obj.Numero_de_matricula__c = value;
			return this;
		}

		public Dan360MatriculaBuilder withProfesional(Account value) {
			obj.Profesional__c = value.Id;
			return this;
		}

		/** (2021-09-06 04:42:17) Valores disponibles:  '25 de Mayo', '9 De Julio', 'Adolfo Gonzales Chaves', 'Alberti', 'Almirante Brown', 'Arrecifes', 'Avellaneda', 'Ayacucho', 'Azul', 'Bahia Blanca', 'Balcarce', 'Berazategui', 'Berisso', 'Bolivar', 'Bragado', 'Campana', 'Cañuelas', 'Capitan Sarmiento', 'Carlos Casares', 'Carlos Tejedor', 'Carmen De Areco', 'Castelli', 'Chacabuco', 'Chascomus', 'Colon', 'Coronel Brandsen', 'Coronel Dorrego', 'Coronel Pringles', 'Coronel Rosales', 'Daireaux', 'De La Costa', 'Ensenada', 'Escobar', 'Esteban Echeverria', 'Exaltacion De La Cruz', 'Ezeiza', 'Florencio Varela', 'General Alvarado', 'General Alvear', 'General Arenales', 'General Belgrano', 'General Lamadrid', 'General Pinto', 'General Pueyrredon', 'General Rodriguez', 'General San Martin', 'General Viamonte', 'General Villegas', 'Guamini', 'Hurlingham', 'Ituzaingo', 'Jose C. Paz', 'Junin', 'La Matanza', 'La Plata', 'Lanus', 'Las Flores', 'Leandro N Alem', 'Lincoln', 'Lobos', 'Lomas De Zamora', 'Lujan', 'Magdalena', 'Malvinas Argentinas', 'Mar Chiquita', 'Marcos Paz', 'Mercedes', 'Merlo', 'Monte', 'Moreno', 'Moron', 'Necochea', 'Olavarria', 'Pehuajo', 'Pergamino', 'Pilar', 'Pinamar', 'Presidente Peron', 'Puan', 'Punta Indio', 'Quilmes', 'Rivadavia', 'Rojas', 'Saladillo', 'San Andres De Giles', 'San Fernando', 'San Isidro', 'San Miguel', 'San Nicolas', 'San Vicente', 'Tandil', 'Tapalque', 'Tigre', 'Tornquist', 'Trenque Lauquen', 'Tres Arroyos', 'Tres De Febrero', 'Vicente Lopez', 'Villa Gesell', 'Villarino', 'Zarate' */
		public Dan360MatriculaBuilder withMunicipios(String value) {
			obj.Municipios__c = value;
			return this;
		}

		 public Dan360_Matricula__c build() {
			return obj;
		}

	}

	public static Dan360MatriculaBuilder aDan360Matricula() { return new Dan360MatriculaBuilder(); }

	public static Dan360MatriculaBuilder aDan360MatriculaNacional() {
		Dan360MatriculaBuilder val = new Dan360MatriculaBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('Dan360_Matricula__c', 'Nacional').Id;
		return val;
	}

	public static Dan360MatriculaBuilder aDan360MatriculaProvincial() {
		Dan360MatriculaBuilder val = new Dan360MatriculaBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('Dan360_Matricula__c', 'Provincial').Id;
		return val;
	}

	public static Dan360MatriculaBuilder aDan360MatriculaMunicipal() {
		Dan360MatriculaBuilder val = new Dan360MatriculaBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('Dan360_Matricula__c', 'Municipal').Id;
		return val;
	}

	/*------------------------------------------------------------------------
		Dan360MatriculaBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		Dan360AccountTeamManagementBuilderStart
	------------------------------------------------------------------------*/
	public class Dan360AccountTeamManagementBuilder {
		private Dan360_Account_Team_Management__c obj = new Dan360_Account_Team_Management__c();

		public Dan360AccountTeamManagementBuilder withOwnerId(Group value) {
			obj.OwnerId = value.Id;
			return this;
		}
		public Dan360AccountTeamManagementBuilder withOwnerId(User value) {
			obj.OwnerId = value.Id;
			return this;
		}

		public Dan360AccountTeamManagementBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public Dan360AccountTeamManagementBuilder withAccount(Account value) {
			obj.Account__c = value.Id;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Read/Write', 'Read Only' */
		public Dan360AccountTeamManagementBuilder withAccountAccessLevel(String value) {
			obj.AccountAccessLevel__c = value;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Read/Write', 'Read Only' */
		public Dan360AccountTeamManagementBuilder withCaseAccessLevel(String value) {
			obj.CaseAccessLevel__c = value;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Read/Write', 'Read Only' */
		public Dan360AccountTeamManagementBuilder withContactAccessLevel(String value) {
			obj.ContactAccessLevel__c = value;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Read/Write', 'Read Only' */
		public Dan360AccountTeamManagementBuilder withOpportunityAccessLevel(String value) {
			obj.OpportunityAccessLevel__c = value;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Account Manager', 'Channel Manager', 'Executive Sponsor', 'Lead Qualifier', 'Pre-Sales Consultant', 'Sales Manager', 'Sales Rep' */
		public Dan360AccountTeamManagementBuilder withTeamMemberRole(String value) {
			obj.TeamMemberRole__c = value;
			return this;
		}

		public Dan360AccountTeamManagementBuilder withUser(User value) {
			obj.User__c = value.Id;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Pendiente', 'Aprobado', 'Rechazado' */
		public Dan360AccountTeamManagementBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		/** (2021-09-06 04:39:07) Valores disponibles:  'Alergia', 'Dieta Cetogénica', 'Metabólicos', 'Oncología' */
		public Dan360AccountTeamManagementBuilder withDan360AreasTerapeuticas(String value) {
			obj.Dan360_Areas_Terapeuticas__c = value;
			return this;
		}

		public Dan360_Account_Team_Management__c build() {
			return obj;
		}

	}

	public static Dan360AccountTeamManagementBuilder aDan360AccountTeamManagement() { return new Dan360AccountTeamManagementBuilder(); }

	/*------------------------------------------------------------------------
		Dan360AccountTeamManagementBuilderEnd
	------------------------------------------------------------------------*/

		/*------------------------------------------------------------------------
				 VisMedConfigAppBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedConfigAppBuilder {
		private VisMed_ConfigApp__c obj = new VisMed_ConfigApp__c();

		public VisMedConfigAppBuilder withOwnerId(Group value) {
			 obj.OwnerId = value.Id;
			 return this;
		}
		public VisMedConfigAppBuilder withOwnerId(User value) {
			 obj.OwnerId = value.Id;
			 return this;
		}

		public VisMedConfigAppBuilder withName(String value) {
			 obj.Name = value;
			 return this;
		}

		public VisMedConfigAppBuilder withRecordTypeId(RecordType value) {
			 obj.RecordTypeId = value.Id;
			 return this;
		}

		public VisMedConfigAppBuilder withVisMedVistaCompacta(String value) {
			 obj.VisMed_Vista_Compacta__c = value;
			 return this;
		}

		public VisMedConfigAppBuilder withVisMedVistaDetalle(String value) {
			 obj.VisMed_Vista_Detalle__c = value;
			 return this;
		}

		public VisMedConfigAppBuilder withVisMedActiva(Boolean value) {
			 obj.VisMed_Activa__c = value;
			 return this;
		}

		public VisMedConfigAppBuilder withVisMedQuery(String value) {
			 obj.VisMed_Query__c = value;
			 return this;
		}

		 public VisMed_ConfigApp__c build() {
			 return obj;
		}

	}

	public static VisMedConfigAppBuilder aVisMedConfigApp() { return new VisMedConfigAppBuilder(); }

	public static VisMedConfigAppBuilder aVisMedConfigAppFuncionalidad() {
		VisMedConfigAppBuilder val = new VisMedConfigAppBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('VisMed_ConfigApp__c', 'Funcionalidad').Id;
		return val;
	}

	public static VisMedConfigAppBuilder aVisMedConfigAppObjeto() {
		VisMedConfigAppBuilder val = new VisMedConfigAppBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('VisMed_ConfigApp__c', 'Objeto').Id;
		return val;
	}

	/*------------------------------------------------------------------------
				 VisMedConfigAppBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
		PersonalAccountBuilderStart
	------------------------------------------------------------------------*/
	public class PersonalAccountBuilder {
		private String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

		private Account obj = new Account(FirstName = 'Furst Test ' + Math.random() * 100,
											LastName = 'Last Test ' + Math.random() * 100,
											RecordTypeId = recordTypeId);

		public PersonalAccountBuilder withProfesionalActivo(Boolean value) {
			obj.Profesional_Activo__c = value;
			return this;
		}

		public PersonalAccountBuilder withFirstName(String value) {
			obj.FirstName = value;
			return this;
		}

		public Account build() {
			return obj;
		}
	}

	public static PersonalAccountBuilder aPersonalAccount() {
		return new PersonalAccountBuilder();
	}

	/*------------------------------------------------------------------------
		PersonalAccountBuilderEnd
	------------------------------------------------------------------------*/


	/*------------------------------------------------------------------------
	Bajas Start
	------------------------------------------------------------------------*/

	public class VisMedBajasBuilder {
		private VisMed_Bajas__c obj = new VisMed_Bajas__c();

		public VisMedBajasBuilder withProfesional(Account value) {
			obj.Profesional__c = value.Id;
			return this;
		}

		public VisMedBajasBuilder withFechaDeDesactivacion(date value) {
			obj.Fecha_de_Desactivacion__c = value;
			return this;
		}

		public VisMedBajasBuilder withFechaDeReactivacion(date value) {
			obj.Fecha_de_Reactivacion__c= value;
			return this;
		}

		/** (2022-07-25 17:17:41) Valores disponibles:  'Pendiente', 'Aprobada', 'Rechazada' */
		public VisMedBajasBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		public VisMedBajasBuilder withMotivoDeLaBaja(String value) {
			obj.Motivo_de_la_Baja__c = value;
			return this;
		}

		public VisMedBajasBuilder withVisMedAPM(Contact value) {
			obj.VisMed_APM__c = value.Id;
			return this;
	   	}

		   public VisMedBajasBuilder withInstitucion(Account value) {
			obj.Institucion__c = value.Id;
			return this;
		}


		public VisMedBajasBuilder withRecordType(Id value) {
					obj.RecordTypeId = value;
			return this;
	   	}

		public VisMed_Bajas__c build() {
			return obj;
		}
	}

	public static VisMedBajasBuilder aVisMedBajas() {
		return new VisMedBajasBuilder();
	}

	public static VisMedBajasBuilder aVisMedBajasProfesionaldelaSalud() {
		VisMedBajasBuilder val = new VisMedBajasBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('VisMed_Bajas__c', 'Profesional_de_la_Salud').Id;
		return val;
	}

	/*------------------------------------------------------------------------
	Bajas End
	------------------------------------------------------------------------*/
	/*------------------------------------------------------------------------
	Seguimiento VisMedContactoCuentaUsuario Start
	------------------------------------------------------------------------*/

	public class VisMedContactCuentaUsuarioBuilder {
		private VisMed_Contacto_Cuenta_Usuario__c obj = new VisMed_Contacto_Cuenta_Usuario__c();

		public VisMedContactCuentaUsuarioBuilder withAPM(Contact value) {
			obj.VisMed_APM__c = value.Id;
			return this;
		}

		public VisMedContactCuentaUsuarioBuilder withProfesional(Account value) {
			obj.Profesional__c = value.Id;
			return this;
		}

		public VisMedContactCuentaUsuarioBuilder withInstitucion(Account value) {
			obj.Institucion__c = value.Id;
			return this;
		}

		public VisMedContactCuentaUsuarioBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		/** (2022-07-25 10:49:25) Valores disponibles:  'Adultos General Institucion', 'Adultos General Comunidad', 'Adultos Oncologia', 'Metabolicos', 'Epilepsia', 'Metabolicos y Epilepsia', 'Pediatricos General', 'Alergia' */
		public VisMedContactCuentaUsuarioBuilder withSegmentaPor(String value) {
			obj.Segmenta_Por__c = value;
			return this;
		}

		public VisMed_Contacto_Cuenta_Usuario__c build() {
			return obj;
		}
	}

	public static VisMedContactCuentaUsuarioBuilder aVisMedContactCuentaUsuarioBuilder() {
		return new VisMedContactCuentaUsuarioBuilder();
	}

	/*------------------------------------------------------------------------
	Seguimiento VisMedContactoCuentaUsuario End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Stock x Ciclo Start
	------------------------------------------------------------------------*/

	public class StockXCicloBuilder {
		Stock_x_Ciclo__c obj = new Stock_x_Ciclo__c();

		public StockXCicloBuilder withAPM(Contact contact) {
			obj.APM__c = contact.Id;
			return this;
		}

		public StockXCicloBuilder withCiclo(VisMed_Ciclo__c cycle) {
			obj.Ciclo__c = cycle.Id;
			return this;
		}

		public Stock_x_Ciclo__c build() {
			return obj;
		}
	}

	public static StockXCicloBuilder aStockXCiclo() {
		return new StockXCicloBuilder();
	}

	/*------------------------------------------------------------------------
	Stock x Ciclo End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Stock x MM Start
	------------------------------------------------------------------------*/

	public class StockXMMBuilder {
		Stock_x_MM__c obj = new Stock_x_MM__c();

		public StockXMMBuilder withCiclo(Stock_x_Ciclo__c stockByCycle) {
			obj.Stock_x_Ciclo__c = stockByCycle.Id;
			return this;
		}

		public StockXMMBuilder withProduct(Product2 product) {
			obj.Muestra_Medica__c = product.Id;
			return this;
		}

		public StockXMMBuilder withQuantity(Integer value) {
			obj.Recibido__c = value;
			return this;
		}

		public Stock_x_MM__c build() {
			return obj;
		}
	}

	public static StockXMMBuilder aStockMMCiclo() {
		return new StockXMMBuilder();
	}

	/*------------------------------------------------------------------------
	Stock x MM End
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
	Ciclo Start
	------------------------------------------------------------------------*/

	public class CicloBuilder {
		VisMed_Ciclo__c obj = new VisMed_Ciclo__c();

		public CicloBuilder withFechaInicio(Date value) {
			obj.Fecha_de_Inicio__c = value;
			return this;
		}

		public CicloBuilder withFechaFin(Date value) {
			obj.Fecha_de_Fin__c = value;
			return this;
		}

		public VisMed_Ciclo__c build() {
			return obj;
		}
	}

	public static CicloBuilder aCiclo() {
		return new CicloBuilder();
	}

	/*------------------------------------------------------------------------
	Ciclo End
	------------------------------------------------------------------------*/


	/*------------------------------------------------------------------------
				VisMedObjetivoBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedObjetivoBuilder {
		private VisMed_Objetivo__c obj = new VisMed_Objetivo__c();

		public VisMedObjetivoBuilder withOwnerId(Group value) {
			obj.OwnerId = value.Id;
			return this;
		}
		public VisMedObjetivoBuilder withOwnerId(User value) {
			obj.OwnerId = value.Id;
			return this;
		}

		public VisMedObjetivoBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public VisMedObjetivoBuilder withVisMedDescripcionObjetivo(String value) {
			obj.VisMed_DescripcionObjetivo__c = value;
			return this;
		}

		public VisMedObjetivoBuilder withVisMedFechaInicio(Date value) {
			obj.VisMed_FechaInicio__c = value;
			return this;
		}

		public VisMedObjetivoBuilder withVisMedFechaFin(Date value) {
			obj.VisMed_FechaFin__c = value;
			return this;
		}

		/** (2022-06-29 14:59:27) Valores disponibles:  'Adultos Instituciones', 'Adultos Comunidad', 'Adultos Comunidad e Instituciones', 'Adultos Oncologia Comunidad', 'Nicho', 'Paeds', 'Alergia' */
		public VisMedObjetivoBuilder withDan360AsignarObjetivo(String value) {
			obj.Dan360_AsignarObjetivo__c = value;
			return this;
		}

		public VisMedObjetivoBuilder withEditable(Boolean value) {
			obj.Editable__c = value;
			return this;
		}

		/** (2022-06-29 14:59:27) Valores disponibles:  'Pendiente', 'Activo', 'Inactivo' */
		public VisMedObjetivoBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		public VisMed_Objetivo__c build() {
			return obj;
		}

	}

	public static VisMedObjetivoBuilder aVisMedObjetivo() {
		return new VisMedObjetivoBuilder();
	}

	/*------------------------------------------------------------------------
				VisMedObjetivoBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				VisMedObjetivoPorCuentaBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedObjetivoPorCuentaBuilder {
		private VisMed_ObjetivoPorCuenta__c obj = new VisMed_ObjetivoPorCuenta__c();

		public VisMedObjetivoPorCuentaBuilder withEditable(Boolean value) {
			obj.Editable__c = value;
			return this;
		}

		/** (2022-06-29 19:34:29) Valores disponibles:  'Pendiente', 'Activo', 'Inactivo' */
		public VisMedObjetivoPorCuentaBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		public VisMedObjetivoPorCuentaBuilder withVisMedObjetivo(VisMed_Objetivo__c value) {
			obj.VisMed_Objetivo__c = value.Id;
			return this;
		}

		public VisMedObjetivoPorCuentaBuilder withVisMedAPM(User value) {
			obj.VisMed_APM__c = value.Id;
			return this;
		}

		public VisMed_ObjetivoPorCuenta__c build() {
			return obj;
		}

	}

	/** It require following fields to can be inserted: VisMed_Objetivo__c. */
	public static VisMedObjetivoPorCuentaBuilder aVisMedObjetivoPorCuenta() {
		return new VisMedObjetivoPorCuentaBuilder();
	}

	/*------------------------------------------------------------------------
				VisMedObjetivoPorCuentaBuilderEnd
	------------------------------------------------------------------------*/


	/*------------------------------------------------------------------------
				VisMedAccionBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedAccionBuilder {
		private VisMed_Accion__c obj = new VisMed_Accion__c();

		public VisMedAccionBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public VisMedAccionBuilder withVisMedObjetivo(VisMed_Objetivo__c value) {
			obj.VisMed_Objetivo__c = value.Id;
			return this;
		}

		public VisMedAccionBuilder withVisMedFechaInicio(Date value) {
			obj.VisMed_FechaInicio__c = value;
			return this;
		}

		public VisMedAccionBuilder withVisMedDescripcionAccion(String value) {
			obj.VisMed_DescripcionAccion__c = value;
			return this;
		}

		public VisMedAccionBuilder withVisMedFechaFin(Date value) {
			obj.VisMed_FechaFin__c = value;
			return this;
		}

		public VisMedAccionBuilder withEditable(Boolean value) {
			obj.Editable__c = value;
			return this;
		}

		/** (2022-06-30 12:17:12) Valores disponibles:  'Pendiente', 'Activo', 'Inactivo' */
		public VisMedAccionBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		public VisMed_Accion__c build() {
			return obj;
		}

	}

	/** It require following fields to can be inserted: VisMed_Objetivo__c. */
	public static VisMedAccionBuilder aVisMedAccion() { return new VisMedAccionBuilder(); }

	/*------------------------------------------------------------------------
				VisMedAccionBuilderEnd
	------------------------------------------------------------------------*/

		/*------------------------------------------------------------------------
				VisMedAccionPorCuentaBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedAccionPorCuentaBuilder {
		private VisMed_AccionPorCuenta__c obj = new VisMed_AccionPorCuenta__c();

		public VisMedAccionPorCuentaBuilder withVisMedObjetivoPorCuenta(VisMed_ObjetivoPorCuenta__c value) {
			obj.VisMed_ObjetivoPorCuenta__c = value.Id;
			return this;
		}

		public VisMedAccionPorCuentaBuilder withEditable(Boolean value) {
			obj.Editable__c = value;
			return this;
		}

		/** (2022-06-30 12:17:45) Valores disponibles:  'Pendiente', 'Activo', 'Inactivo' */
		public VisMedAccionPorCuentaBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		public VisMedAccionPorCuentaBuilder withVisMedObjetivo(VisMed_Objetivo__c value) {
			obj.VisMed_Objetivo__c = value.Id;
			return this;
		}

		public VisMedAccionPorCuentaBuilder withVisMedAccion(VisMed_Accion__c value) {
			obj.VisMed_Accion__c = value.Id;
			return this;
		}

		public VisMedAccionPorCuentaBuilder withVisMedAPM(User value) {
			obj.VisMed_APM__c = value.Id;
			return this;
		}

		public VisMedAccionPorCuentaBuilder withVisMedPromedioAvance(Decimal value) {
			obj.VisMed_PromedioAvance__c = value;
			return this;
		}

		public VisMed_AccionPorCuenta__c build() {
			return obj;
		}

	}

	/** It require following fields to can be inserted: VisMed_ObjetivoPorCuenta__c. */
	public static VisMedAccionPorCuentaBuilder aVisMedAccionPorCuenta() { return new VisMedAccionPorCuentaBuilder(); }

	/*------------------------------------------------------------------------
				VisMedAccionPorCuentaBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				Dan360EfectividadBuilderStart
	------------------------------------------------------------------------*/
	public class Dan360EfectividadBuilder {
		private Dan360_Efectividad__c obj = new Dan360_Efectividad__c();

		public Dan360EfectividadBuilder withVisMedDiasdeLicenciaUnicos(Double value) {
			obj.VisMed_Dias_de_Licencia_Unicos__c = value;
			return this;
		}

		public Dan360EfectividadBuilder withDiasdeLicenciaTranscurridos(Double value) {
			obj.Dias_de_Licencia_Transcurridos__c = value;
			return this;
		}

		public Dan360EfectividadBuilder withFechadeinicio(Date value) {
			obj.Fecha_de_inicio__c = value;
			return this;
		}

		public Dan360EfectividadBuilder withFechadeFin(Date value) {
			obj.Fecha_de_Fin__c = value;
			return this;
		}

		public Dan360EfectividadBuilder withVisMedTargetDiario(Double value) {
			obj.VisMed_Target_Diario__c = value;
			return this;
		}

		public Dan360EfectividadBuilder withVisMedVisitasrealizadas(Double value) {
			obj.VisMed_Visitas_realizadas__c = value;
			return this;
		}

		public Dan360EfectividadBuilder withVisMedCiclo(VisMed_Ciclo__c value) {
			obj.VisMed_Ciclo__c = value.Id;
			return this;
		}

		public Dan360EfectividadBuilder withVisMedAPM(Contact value) {
			obj.VisMed_APM__c = value.Id;
			return this;
		}

		public Dan360_Efectividad__c build() {
			return obj;
		}

	}

	/** It require following fields to can be inserted: VisMed_APM__c. */
	public static Dan360EfectividadBuilder aDan360Efectividad() { return new Dan360EfectividadBuilder(); }

	/*------------------------------------------------------------------------
				Dan360EfectividadBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				Dan360InteraccionesBuilderStart
	------------------------------------------------------------------------*/
	public class Dan360InteraccionesBuilder {
		private Dan360_Interacciones__c obj = new Dan360_Interacciones__c();

		public Dan360InteraccionesBuilder withRecordTypeId(RecordType value) {
			obj.RecordTypeId = value.Id;
			return this;
		}

		/** (2022-07-22 18:09:09) Valores disponibles:  'Pendiente', 'Aprobada', 'Rechazada' */
		public Dan360InteraccionesBuilder withEstado(String value) {
			obj.Estado__c = value;
			return this;
		}

		/** (2022-07-22 18:09:09) Valores disponibles:  'Presencial', 'Telefónica', 'Whatsapp', 'Email', 'Videollamada' */
		public Dan360InteraccionesBuilder withVisMedTipodeVisita(String value) {
			obj.VisMed_Tipo_de_Visita__c = value;
			return this;
		}

		/** (2022-07-22 18:09:09) Valores disponibles:  'Profesional ausente', 'Profesional sin tiempo' */
		public Dan360InteraccionesBuilder withVisMedMotivo(String value) {
			obj.VisMed_Motivo__c = value;
			return this;
		}

		public Dan360InteraccionesBuilder withVisMedEfectividad(Dan360_Efectividad__c value) {
			obj.VisMed_Efectividad__c = value.Id;
			return this;
		}

		public Dan360InteraccionesBuilder withProfesional(Account value) {
			obj.Profesional__c = value.Id;
			return this;
		}

		public Dan360InteraccionesBuilder withInteraccion(Dan360_Interacciones__c value) {
			obj.Interaccion__c = value.Id;
			return this;
		}

		public Dan360InteraccionesBuilder withVisMedFecha(Date value) {
			obj.VisMed_Fecha__c = value;
			return this;
		}

		public Dan360InteraccionesBuilder withDomiciliodelaVisita(Account value) {
			obj.VisMed_Domicilio_de_la_Visita__c = value.Id;
			return this;
		}

		public Dan360InteraccionesBuilder withAPM(Contact value) {
			obj.VisMed_APM__c = value.Id;
			return this;
		}

		public Dan360_Interacciones__c build() {
			return obj;
		}

	}

	public static Dan360InteraccionesBuilder aDan360Interacciones() {
		return new Dan360InteraccionesBuilder();
	}

	public static Dan360InteraccionesBuilder aDan360InteraccionesTareadeAccion() {
		Dan360InteraccionesBuilder val = new Dan360InteraccionesBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('Dan360_Interacciones__c', 'Tarea_de_Accion').Id;
		return val;
	}

	public static Dan360InteraccionesBuilder aDan360InteraccionesVisitaMedica() {
		Dan360InteraccionesBuilder val = new Dan360InteraccionesBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('Dan360_Interacciones__c', 'Visita_Medica').Id;
		return val;
	}

	public static Dan360InteraccionesBuilder aDan360InteraccionesNoVisita() {
		Dan360InteraccionesBuilder val = new Dan360InteraccionesBuilder();
		val.obj.RecordTypeId = XappiaHelper.getRecordType('Dan360_Interacciones__c', 'No_Visita').Id;
		return val;
	}

	/*------------------------------------------------------------------------
				Dan360InteraccionesBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				VisMedCicloBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedCicloBuilder {
		private VisMed_Ciclo__c obj = new VisMed_Ciclo__c();

		public VisMedCicloBuilder withOwnerId(Group value) {
			obj.OwnerId = value.Id;
			return this;
		}

		public VisMedCicloBuilder withName(String value) {
			obj.Name = value;
			return this;
		}

		public VisMedCicloBuilder withFechadeinicio(Date value) {
			obj.Fecha_de_inicio__c = value;
			return this;
		}

		public VisMedCicloBuilder withFechadeFin(Date value) {
			obj.Fecha_de_Fin__c = value;
			return this;
		}

		public VisMedCicloBuilder withVisMedCmptTiemponopromocional(Double value) {
			obj.VisMed_Cmpt_Tiempo_no_promocional__c = value;
			return this;
		}

		public VisMed_Ciclo__c build() {
			return obj;
		}

	}

	public static VisMedCicloBuilder aVisMedCiclo() { return new VisMedCicloBuilder(); }

	/*------------------------------------------------------------------------
				VisMedCicloBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				VisMedRecetaBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedRecetaBuilder {
		private VisMed_Receta__c obj = new VisMed_Receta__c();

		public VisMedRecetaBuilder withProfessional(Account account) {
			obj.Profesional_de_la_receta__c = account.Id;
			return this;
		}

		public VisMedRecetaBuilder withProduct(VisMed_ProductoDeReceta__c product) {
			obj.Producto__c = product.Id;
			return this;
		}

		public VisMedRecetaBuilder withQuarter(VisMed_Cuatrimestre__c quarter) {
			obj.Cuatrimestre__c = quarter.Id;
			return this;
		}

		public VisMedRecetaBuilder withQuantity(Integer quantity) {
			obj.Cantidad__c = quantity;
			return this;
		}

		public VisMed_Receta__c build() {
			return obj;
		}

	}

	public static VisMedRecetaBuilder aPrescription() { return new VisMedRecetaBuilder(); }

	/*------------------------------------------------------------------------
				VisMedRecetaBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				VisMedCuatrimestreBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedCuatrimestreBuilder {
		private VisMed_Cuatrimestre__c obj = new VisMed_Cuatrimestre__c();

		public VisMedCuatrimestreBuilder withInitialDate(Date initialDate) {
			obj.Fecha_inicio__c = initialDate;
			return this;
		}

		public VisMedCuatrimestreBuilder withEndDate(Date endDate) {
			obj.Fecha_fin__c = endDate;
			return this;
		}

		public VisMed_Cuatrimestre__c build() {
			return obj;
		}

	}

	public static VisMedCuatrimestreBuilder aQuarter() { return new VisMedCuatrimestreBuilder(); }

	/*------------------------------------------------------------------------
				VisMedRecetaBuilderEnd
	------------------------------------------------------------------------*/

	/*------------------------------------------------------------------------
				VisMedProductoDeRecetaBuilderStart
	------------------------------------------------------------------------*/
	public class VisMedProductoDeRecetaBuilder {
		private VisMed_ProductoDeReceta__c obj = new VisMed_ProductoDeReceta__c();

		public VisMedProductoDeRecetaBuilder withName(String name) {
			obj.Name = name;
			return this;
		}

		public VisMedProductoDeRecetaBuilder withCompany(String company) {
			obj.Compania__c = company;
			return this;
		}

		public VisMedProductoDeRecetaBuilder withBrand(String brand) {
			obj.Marca__c = brand;
			return this;
		}

		public VisMedProductoDeRecetaBuilder withIdSAP(String idSap) {
			obj.Id_SAP__c = idSap;
			return this;
		}

		public VisMedProductoDeRecetaBuilder withStage(String stage) {
			obj.Etapa__c = stage;
			return this;
		}

		public VisMedProductoDeRecetaBuilder withSegment(String segment) {
			obj.Segmento__c = segment;
			return this;
		}

		public VisMedProductoDeRecetaBuilder withSubStage(String subStage) {
			obj.Sub_Etapa__c = subStage;
			return this;
		}

		public VisMed_ProductoDeReceta__c build() {
			return obj;
		}

	}

	public static VisMedProductoDeRecetaBuilder aPrescriptionProduct() { return new VisMedProductoDeRecetaBuilder(); }

	/*------------------------------------------------------------------------
				VisMedProductoDeRecetaBuilderStart
	------------------------------------------------------------------------*/

	public class AppLog {
		private AppLog__c obj = new AppLog__c();

		public AppLog withName(String name) {
			obj.Name = name;
			return this;
		}

		public AppLog withRecordType(Id value){
			obj.RecordTypeId = value;
			return this;
		}

		public AppLog__c build() {
			return obj;
		}
	}

	public static AppLog anAppLog() { return new AppLog(); }
}