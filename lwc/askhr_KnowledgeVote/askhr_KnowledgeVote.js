import { LightningElement, api, wire } from 'lwc';

/*
 ASKHR_KnowledgeVoteController.getVotes() Apex method 
*/
import getVotes from '@salesforce/apex/ASKHR_KnowledgeVoteController.getVotes';

/*
 ASKHR_KnowledgeVoteController.castMyVote() Apex method 
*/
import castMyVote from '@salesforce/apex/ASKHR_KnowledgeVoteController.castMyVote';


export default class Askhr_KnowledgeVote extends LightningElement {
    @api recordId;

    voteData;
    likeVariant = 'border';
    dislikeVariant = 'border';
    buttonDisabled = true;

    @wire(getVotes, { knowledgeId: '$recordId'})
    loadVoteData(result) {
        //console.log('recordid:' + this.recordId + ':' + recordId);
        //console.log('in loadVoteData:' + JSON.stringify(result));
        if (result.error) {
            console.log('Error in getVotes: ' + result.error);
        } else if (result.data) {
            this.voteData = result.data;
            this.loadVariables();
            this.buttonDisabled = false;
        }
    }
    
    likeArticle() {
        // Already liked it. So dont do anything
        if (this.likeVariant == 'brand') {
            return;
        }
        this.buttonDisabled = true;

        // Thumbs Up is stored as Type = 5 in Vote object
        this.vote('5');
    }

    dislikeArticle() {
        // Already disliked it. So dont do anything
        if (this.dislikeVariant == 'brand') {
            return;
        }
        this.buttonDisabled = true;

        // Thumbs down is stored as Type = 1 in Vote object
        this.vote('1');
    }

    /*
        Method that insert/update the current user vote.
    */
    vote(voteType) {
        // call apex method to inser/update vote
        castMyVote({params : {knowledgeId: this.recordId, type: voteType}})
            .then((result) => {
                this.voteData = result;
                this.loadVariables();
                this.buttonDisabled = false;
            })
            .catch((error) => {
                console.log('Error in castMyVote: ' + error);
                this.buttonDisabled = false;
            });
    }
    
    // update the icons based on the users vote
    loadVariables() {
        this.likeVariant = 'border';
        this.dislikeVariant = 'border';
        if (this.voteData.myVote == '1') {
            this.dislikeVariant = 'brand';
        }
        else if (this.voteData.myVote == '5') {
            this.likeVariant = 'brand';
        }
    }

    
	connectedCallback() {
		//console.log('calling getVotes');
        //console.log('recordid2:' +this.recordId);
		getVotes({knowledgeId : this.recordId});
	}
}