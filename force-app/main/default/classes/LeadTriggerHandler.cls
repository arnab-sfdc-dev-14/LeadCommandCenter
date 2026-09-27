public with sharing class LeadTriggerHandler {

    //Rating based on  AnnualRevenue :
    /**
     * AnnualRevenue < 50,00,000 : Cold
     * AnnualRevenue > 50,00,000 AND AnnualRevenue <= 5,00,00,000 : Warm
     * AnnualRevenue >= 5,00,00,000 : Hot
     */
    
    public static void handleBeforeInsert(List<Lead> newLeadList){
        for(Lead ld : newLeadList){
            ld.Rating = scoreRatings(ld.AnnualRevenue);
        }
    }

    public static void handleBeforeUpdate(List<Lead> newLeadList,Map<Id,Lead> oldLeadMap){

        for(Lead ld : newLeadList){
            if(oldLeadMap.get(ld.Id).AnnualRevenue != ld.AnnualRevenue && ld.AnnualRevenue !=NULL){
                ld.Rating = scoreRatings(ld.AnnualRevenue);
            }
        }
    }


    //Method to score the rating
    private static String scoreRatings(Decimal annualRev){
        String ratingScore;
            if(annualRev < 5000000.00){
                ratingScore = 'Cold';
            }else if(annualRev >= 5000000.00 && annualRev < 50000000.00){
                ratingScore = 'Warm';
            }else if(annualRev > 50000000){
                ratingScore = 'Hot';
            }

        return ratingScore;
    }
}