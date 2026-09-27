public with sharing class ErrorLogger {
   
    public static void createErrorLogs(String message, String stackString,String cause,String className){

        Error_Log__c logs = new Error_Log__c();
        logs.ClassName__c = className != null ? className : null;
        logs.Error_Message__c = message != null ? message : null;
        logs.Error_Stack_Trace__c = stackString != null ? stackString : null;
        logs.Error_Cause__c = cause != null ? cause : null;

        insert logs;
    }
}