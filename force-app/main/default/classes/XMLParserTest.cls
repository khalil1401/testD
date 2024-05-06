@IsTest 
class XMLParserTest  {
	@IsTest static void getNodeShouldReturnNullIfPathDoesnotExist() {
		System.assertEquals(null, XMLParser.getNode(xmlSample, 'dfq[0]/rew'));
		System.assertEquals(null, XMLParser.getNode(xmlSample, 'breakfast_menu/qw'));
		//la busqueda se empiza adentro del root element
		System.assertEquals(null, XMLParser.getNode(xmlSample, 'breakfast_menu/food'));
		System.assertEquals(null, XMLParser.getNode(xmlSample, 'foo[0]d'));
		System.assertEquals(null, XMLParser.getNode(xmlSample, 'food[-1]'));
		System.assertEquals(null, XMLParser.getNode(xmlSample, 'food[100]'));
	}

	@IsTest static void getNodeShouldReturnCorrectNode() {
		System.assertEquals('food', XMLParser.getNode(xmlSample, 'food').getName());
		System.assertEquals('Belgian Waffles', XMLParser.getNode(xmlSample, 'food/name').getText());
		System.assertEquals('$7.95', XMLParser.getNode(xmlSample, 'food[1]/price').getText());
	}

	static final String xmlSample = 
		  '<breakfast_menu>'
		+ '<food>'
		+ '<name>Belgian Waffles</name>'
		+ '<price>$5.95</price>'
		+ '<description>'
		+ 'Two of our famous Belgian Waffles with plenty of real maple syrup'
		+ '</description>'
		+ '<calories>650</calories>'
		+ '</food>'
		+ '<food>'
		+ '<name>Strawberry Belgian Waffles</name>'
		+ '<price>$7.95</price>'
		+ '<description>'
		+ 'Light Belgian waffles covered with strawberries and whipped cream'
		+ '</description>'
		+ '<calories>900</calories>'
		+ '</food>'
		+ '<food>'
		+ '<name>Berry-Berry Belgian Waffles</name>'
		+ '<price>$8.95</price>'
		+ '<description>'
		+ 'Light Belgian waffles covered with an assortment of fresh berries and whipped cream'
		+ '</description>'
		+ '<calories>900</calories>'
		+ '</food>'
		+ '<food>'
		+ '<name>French Toast</name>'
		+ '<price>$4.50</price>'
		+ '<description>'
		+ 'Thick slices made from our homemade sourdough bread'
		+ '</description>'
		+ '<calories>600</calories>'
		+ '</food>'
		+ '<food>'
		+ '<name>Homestyle Breakfast</name>'
		+ '<price>$6.95</price>'
		+ '<description>'
		+ 'Two eggs, bacon or sausage, toast, and our ever-popular hash browns'
		+ '</description>'
		+ '<calories>950</calories>'
		+ '</food>'
		+ '</breakfast_menu>';
}