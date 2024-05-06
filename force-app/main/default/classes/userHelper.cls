public with sharing class userHelper {
    public static void sendEmailToUserCommunity(List<User> users){
        String profileToSend = Dan360_ConfiguracionesGenerales__mdt.getInstance('Dan360_ConfiguracionesGenerales').Dan360_PerfilesOMSComunidad__c;
        System.debug(profileToSend);
        List<String> profilesToSend = profileToSend.split(', ');

        List<String> usersProfilesIds = new List<String>();

        
        
        for(User usuario : users){
            usersProfilesIds.add(usuario.ProfileId);
        }

        Map<Id,Profile> mapIdProfile = new Map<Id,Profile>([SELECT Id, Name FROM PROFILE WHERE Id IN : usersProfilesIds]);
        System.debug(mapIdProfile);

        for(User usuario : users){
            if(usuario.VisMed_Es_un_Visitador_Medico__c == false && profilesToSend.contains(mapIdProfile.get(usuario.ProfileId).Name)){
                System.debug('Enviar Mail');
                System.resetPassword(usuario.Id, true);
            }
        }

    }
}