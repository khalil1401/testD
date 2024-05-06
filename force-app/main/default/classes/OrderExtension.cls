public with sharing class OrderExtension {
	public List<Order> selectedOrders;
	public List<String> ordersId;

	public OrderExtension(ApexPages.StandardSetController cntlr){
		ordersId = new List<String>();
		selectedOrders = cntlr.getSelected();

		for (Order order : selectedOrders) {
			ordersId.add(order.Id);
		}
	}

	public PageReference redirectToLC(){
		String returnUrl = '/lightning/cmp/c__MassApproving';
		PageReference pgReturnPage = new PageReference(returnUrl);
		pgReturnPage.setRedirect(false);
		return pgReturnPage;
	}
}