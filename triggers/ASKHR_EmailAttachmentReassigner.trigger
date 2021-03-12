trigger ASKHR_EmailAttachmentReassigner on Attachment (before insert) {
    
    if (Trigger.isBefore) {         
        for(Attachment a: trigger.new){
            //TODO: figure better way to handle this 
            if(a.ParentId == null) continue;
                        
            String s = string.valueOf(a.ParentId);
            
            if(s.substring(0, 3) == '02s')  
              a.ParentId = [Select ParentId from EmailMessage where Id = :a.ParentId].ParentId; 
                //String ownerName = [Select Owner.Name from Case where Id = :a.ParentId].Owner.Name;             
            
           if(a != null && a.ContentType != null && a.BodyLength != null){
                
               if(a.ContentType.equals('image/png') || a.ContentType.equals('image/gif') || a.ContentType.equals('image/jpeg'))
                {
                    //Signature Logo Size
                    if((a.BodyLength <= 9900 && a.BodyLength >= 6000) || (a.BodyLength <= 10750 && a.BodyLength >= 10650 ) || (a.BodyLength <= 28600 && a.BodyLength >= 28500) || a.BodyLength == 26542 )
                        a.ParentId = s;
                                      
                    //Icon Size
                    if(a.BodyLength <= 3700 && a.BodyLength >= 100)
                        a.ParentId = s;       
                }
                              
            }
        }       
               
    }
}

/*
trigger AttachmentFilterTrigger on Attachment ( after insert ) {
 
    // inspect the attachment's parentId to see if it belongs to an incident object
    // then maybe look at the bodyLength and delete the attachment if too small.
    // I imagine signature images are probably very small sizes.
    
    
}*/