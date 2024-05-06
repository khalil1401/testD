public with sharing class PricebookEntryHandler {
	public static void UpdateOrderProductPrice(Map<Id, PricebookEntry> pricebookEntries) {
		List<OrderItem> orderItems = new List<OrderItem>();

		for (OrderItem orderItem : [
			SELECT  Id,
					UnitPrice
			FROM    OrderItem
			WHERE   PricebookEntryId IN :pricebookEntries.keySet()
				AND Order.Status = 'Borrador'
		]) {
			PricebookEntry pricebookEntry = pricebookEntries.get(orderItem.PricebookEntryId);
			orderItem.UnitPrice = pricebookEntry.UnitPrice;

			orderItems.add(orderItem);
		}

		update orderItems;
	}
}