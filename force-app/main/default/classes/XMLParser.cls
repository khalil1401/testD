public class XMLParser  {
	//ejemplo: fault[1] -> 1; fault -> 0
	private static Integer getIndex(String subPath) {		
		String endPart = subPath.substringAfterLast('[');		
		String integerPart = endPart.substringBeforeLast(']');
		if (integerPart.isNumeric() && subPath.endsWith('[' + integerPart + ']')) {
			return Integer.valueOf(integerPart);
		} else {
			return 0;
		}
	}
	//body/fault[0]
	public static dom.XmlNode getNode(dom.XmlNode parent, String path) {
		String[] pathParts = path.split('/');
		String s;
				
		dom.XmlNode currentNode = parent;
		for (Integer i = 0; i < pathParts.size(); i++) {			
			Boolean founded = false;
			dom.XmlNode[] nodes = currentNode.getChildren();
			
			Integer index = getIndex(pathParts[i]);
			String arrayPart = '[' + String.valueOf(index) + ']';

			if (pathParts[i].contains(arrayPart)) {
				pathParts[i] = pathParts[i].substringBeforeLast(arrayPart);
			}
			for (dom.XmlNode node : nodes) {
				if (node.getName() == pathParts[i]) {
					if (index == 0) {
						founded = true;
						currentNode = node;
						break;
					} else {
						index--;
					}
				}				
			}
			if (!founded) {
				return null;
			}
		}

		return currentNode;
	}

	public static dom.XmlNode getNode(String document, String path) {
		dom.Document doc = new dom.Document();
		doc.load(document);		
		if (doc.getRootElement() == null) {
			doc.createRootElement('root', '', '');
		}
		return getNode(doc.getRootElement(), path);
	}

}