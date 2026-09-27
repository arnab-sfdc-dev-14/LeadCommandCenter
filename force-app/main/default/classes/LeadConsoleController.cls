public with sharing class LeadConsoleController {
@AuraEnabled(cacheable=true)
public static List<Lead> getLeadDetails(){
    String userId = Userinfo.getUserId();
    return [SELECT Id,Name,Rating,Company,AnnualRevenue,Status,LeadSource,Industry,LastmodifiedDate FROM Lead WHERE OwnerId=:userId];
}

@AuraEnabled
public static Boolean checkExistingTask(String leadId){
    List<Task> tskRec = [SELECT Id FROM Task WHERE WhoId =: leadId LIMIT 1];
    if(!tskRec.isEmpty()){
        return true;
    }else {
        return false;
    }
}

@AuraEnabled
public static Boolean createFollowUpTask(String leadId){
    
    Lead ld = [SELECT Id,Name,OwnerId,Rating FROM Lead WHERE Id=:leadId LIMIT 1];
    Boolean isHot = ld.Rating == 'Hot';
        Task tsk = new Task();
        tsk.Subject = isHot ? 'Call' : 'Email';
        tsk.Priority = isHot ? 'High' : 'Normal';
        tsk.Status = 'Not Started';
        tsk.ActivityDate = isHot ? Date.today().addDays(3) : Date.today().addDays(7);
        tsk.OwnerId = ld.OwnerId;
        tsk.WhoId = ld.Id;
        tsk.Description = ld.Name + 'Follow Up Task Created On : '  + String.valueOf(System.now());

        try{
            insert tsk;
            System.debug('Task Created: ' +tsk.Id);
            return true;
        }catch(DmlException e){
            System.debug('Error@@: ' +e.getMessage());
            return false;

        }
    }
}