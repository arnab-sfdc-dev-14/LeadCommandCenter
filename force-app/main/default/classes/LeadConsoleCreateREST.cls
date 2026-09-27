@RestResource(urlMapping='/lead-followup/*')
global with sharing class LeadConsoleCreateREST {
   
    @HttpPost
    global static void createLead(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;

        String requestBody = req.requestBody.toString();
        Map<String,Object> payload = (Map<String,Object>) JSON.deserializeUntyped(requestBody);

        Lead ld = new Lead();
        ld.FirstName = (String) payload.get('firstName');
            ld.LastName = (String) payload.get('lastName');
            ld.Company = (String) payload.get('company');
            ld.Description = (String) payload.get('description');
            ld.Phone = (String) payload.get('phone');
            ld.Email = (String) payload.get('email');
            ld.LeadSource = (String) payload.get('leadSource');
            ld.Industry = (String) payload.get('industry');

            if (payload.containsKey('annualRevenue')) {
                ld.AnnualRevenue =
                    Decimal.valueOf(String.valueOf(payload.get('annualRevenue')));
            }

            if (payload.containsKey('numberOfEmployees')) {
                ld.NumberOfEmployees =
                    Integer.valueOf(String.valueOf(payload.get('numberOfEmployees')));
            }

            try{
                insert ld;
                res.statusCode = 201;
                res.responseBody = Blob.valueOf(
                    JSON.serialize(new Map<String, Object>{
                        'success' => true,
                        'leadId' => ld.Id,
                        'message' => 'Lead created successfully'
                    })
                );


            }catch (Exception e) {

            res.statusCode = 400;
            res.responseBody = Blob.valueOf(
                JSON.serialize(new Map<String, Object>{
                    'success' => false,
                    'message' => e.getMessage()
                })
                );
            }
    }



    /* ************************* SAMPLE JSON *********************************

{
    "firstName": "Rahul",
    "lastName": "Sharma",
    "company": "ABC Technologies",
    "description": "Interested in enterprise Salesforce implementation",
    "phone": "+91-9876543210",
    "email": "rahul.sharma@example.com",
    "leadSource": "Web",
    "industry": "Technology",
    "annualRevenue": 75000000,
    "numberOfEmployees": 250
}
    ************************* SAMPLE JSON *********************************
*/
}