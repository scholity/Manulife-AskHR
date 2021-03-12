/*
The controller class for askhr_KnowledgeVote LWC component
*/
public with sharing class ASKHR_KnowledgeVoteController {
    
    /**
     * Description: Method getVotes
     * 
     * This method returns Vote Details of the given Knowledge Id.
     * The Vote Details include myVote and the count of Thumbs Up and Thumbs Down.
     * See the definition of the class VoteData
     *
     * @return VoteData - Returns Knowledge Articles Vote Details
     */
    @AuraEnabled(Cacheable=true)
    public static VoteData getVotes(String knowledgeId) {
        
        // Retrieve the KnowledgeArticleId 
        List<Knowledge__kav> listKnowledgeArticles = 
            [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :knowledgeId];
    
        String knowledgeArticleId = null;
        
        if (listKnowledgeArticles.size() > 0) {
            knowledgeArticleId = listKnowledgeArticles[0].KnowledgeArticleId;
        }
        
        return loadVoteData(knowledgeArticleId);
    }

    
    /**
     * Description: Method castMyVote
     * 
     * This method insert/update the Vote for the current user.
     * The knowledge Id and the users Vote is sent in the params.
     * It then returns the Vote Details of the given Knowledge Id.
     * The Vote Details include myVote and the count of Thumbs Up and Thumbs Down.
     * See the definition of the class VoteData
     *
     * @return VoteData - Returns Knowledge Articles Vote Details
     */
    @AuraEnabled
    public static VoteData castMyVote(ParamsWrapper params) {
        
        // Retrieve the KnowledgeArticleId 
        List<Knowledge__kav> listKnowledgeArticles = 
            [SELECT Id, KnowledgeArticleId FROM Knowledge__kav WHERE Id = :params.knowledgeId];

        String knowledgeArticleId = null;

        if (listKnowledgeArticles.size() > 0) {
            knowledgeArticleId = listKnowledgeArticles[0].KnowledgeArticleId;
            
            // Get the Vote of the current user.
            Id userId = UserInfo.getUserId();
            List<Vote> listVote = 
                [SELECT Id, Type FROM Vote 
                    WHERE ParentId = :knowledgeArticleId AND 
                    LastModifiedByID  = :userId];

            // if logged in User has already voted, just update Vote otherwise insert Vote
            if (listVote.size() > 0) {
                listVote[0].Type = params.type;
                update listVote[0];
            }
            else {
                Vote myVote = new Vote(ParentId = knowledgeArticleId, Type = params.type);
                insert myVote;
            }
        }

        return loadVoteData(knowledgeArticleId);
    }

    /*
    Loads the Vote Details of the Knowledge article.
    See the definition of the class VoteData.
    */
    private static VoteData loadVoteData(String knowledgeArticleId) {

        VoteData returnVoteData = new VoteData();
        // Set default values.
        returnVoteData.myVote = '0';
        returnVoteData.dislikeCount = 0;
        returnVoteData.likeCount = 0;

        if (knowledgeArticleId != null) {
            // Get the Vote of the current user.
            Id userId = UserInfo.getUserId();
            List<Vote> listVote = 
                [SELECT Id, Type FROM Vote 
                    WHERE ParentId = :knowledgeArticleId AND 
                    LastModifiedByID  = :userId];

            if (listVote.size() > 0) {
                returnVoteData.myVote = listVote[0].Type;
            }

            // Get the counts of Thumbs Up and Thumbs Down votes identified by Type 5 and 1 respectively.
            List<AggregateResult> listAR = 
                [SELECT Type, Count(Id) cnt FROM Vote 
                    WHERE ParentId = :knowledgeArticleId GROUP BY Type];

            for (AggregateResult ar : listAR ) {
                String type = (String)ar.get('Type');
                Integer cnt = Integer.valueOf(ar.get('cnt'));
                if (type == '1') {
                    returnVoteData.dislikeCount = cnt;
                }
                else if (type == '5') {
                    returnVoteData.likeCount = cnt;
                }
            }
        }
        
        return returnVoteData;
    }

    public class VoteData {
        // myVote will have 0 if the user has not voted yet.
        // myVote will have 1 if the user has voted Thumbs Down.
        // myVote will have 5 if the user has voted Thumbs Up.
        @AuraEnabled
        public String myVote {get; set;}

        // No of users who has voted Thumbs Up.
        @AuraEnabled
        public Integer likeCount {get; set;}

        // No of users who has voted Thumbs Down.
        @AuraEnabled
        public Integer dislikeCount {get; set;}
    }
    
    /*
    Wrapper class to be used by LWC to cast Vote.
    */
    public class ParamsWrapper {
        @AuraEnabled
        public String knowledgeId {get; set;}

        @AuraEnabled
        public String type {get; set;}
    }
}