public with sharing class LeadFollowUpTaskCreateBatch implements Database.Batchable<SObject>, Database.Stateful {

    private Set<Id> errorIds = new Set<Id>();

    public Database.QueryLocator start(Database.BatchableContext context) {

        return Database.getQueryLocator([SELECT Id,Status,Rating,Name,AnnualRevenue,OwnerId FROM Lead WHERE Status = 'Open - Not Contacted' AND Rating !='Cold' AND Rating !=NULL]);
    }

    public void execute(Database.BatchableContext context, List<Lead> scope) {
         Set<Id> leadIds = new Set<Id>();
          Map<Id,Lead> nonExistingLeadMap = new Map<Id,Lead>();

        for(Lead ld : scope){
            leadIds.add(ld.Id);
            nonExistingLeadMap.put(ld.Id,ld);
        }

        for (Task tsk : [SELECT WhoId FROM Task WHERE WhoId IN :leadIds]) {
                nonExistingLeadMap.remove(tsk.WhoId);
         }

        List<Task> tasksToCreate = new List<Task>();

        for(Lead ld : nonExistingLeadMap.values()){
            Boolean isHot = ld.Rating == 'Hot';
            Task tsk = new Task();
            tsk.Subject = isHot ? 'Call' : 'Email';
            tsk.Priority = isHot ? 'High' : 'Normal';
            tsk.Status = 'Not Started';
            tsk.ActivityDate = isHot ? Date.today().addDays(3) : Date.today().addDays(7);
            tsk.OwnerId = ld.OwnerId;
            tsk.WhoId = ld.Id;
            tsk.Description = ld.Name + 'Follow Up Task Created On : '  + String.valueOf(System.now());
            tasksToCreate.add(tsk);
        }
                
        Database.saveResult[] srList = Database.Insert(tasksToCreate,false);
        for (Integer i = 0; i < srList.size(); i++) {
                if (!srList[i].isSuccess()) {
                    errorIds.add(scope[i].Id);
                }
            }
    }

   public void finish(Database.BatchableContext context) {

        if (errorIds.isEmpty()) {
            return;
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(new String[] {'arnab.sfdc07@gmail.com'});
        email.setSubject('Lead Follow-Up Batch - Task Creation Errors');

        String body = 'The following Lead IDs had Task creation failures:\n\n';

        for (Id leadId : errorIds) {
            body += leadId + '\n';
        }
        email.setPlainTextBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

    }
}
