public with sharing class FeatureManager {
	/* @Description:
	 *       FeatureManager se encarga de la opcion que tiene el Administrador de activar o desactivar
	 *       acciones que se ejecutan a nivel codigo. Esta orientado a Triggers pero por su simpleza puede
	 *       ser utilizado para ocurrencias similares.
	 *   @Requirements:
	 *       - Crear custom setting FeatureSwitch de tipo Hierarchy protegida dentro del entorno.
	 */

	public static Boolean isFeatureTurnedOn (String featureName) {
		Map<String, Object> feature = FeatureSwitch__c.getOrgDefaults().getPopulatedFieldsAsMap();

		if(!feature.containsKey(featureName + '__c')) {
			return true;
		}

		return (Boolean)feature.get(featureName + '__c');
	}
}