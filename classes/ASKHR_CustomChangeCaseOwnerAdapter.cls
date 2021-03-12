/**
 *@description adapter class for ASKHR_CustomChangeCaseOwnerExtension
*/

public abstract without sharing class ASKHR_CustomChangeCaseOwnerAdapter {
	//constructor
    public static ASKHR_CustomChangeCaseOwnerAdapter adapt(ApexPages.StandardController controller){
        return new StandardControllerAdapter(controller);
    }
    //constructor
    public static ASKHR_CustomChangeCaseOwnerAdapter adapt(ApexPages.StandardSetController controller){
        return new StandardSetControllerAdapter(controller);
    }
    
    public abstract ApexPages.PageReference save();
    public abstract List<Case> getSelected();
    
    public class StandardControllerAdapter extends ASKHR_CustomChangeCaseOwnerAdapter {
        ApexPages.StandardController m_Controller;
        
        StandardControllerAdapter(ApexPages.StandardController controller){
            this.m_Controller = controller;
        }
        
        public override ApexPages.PageReference save(){
            return m_Controller.save();
        }
        
        public override List<Case> getSelected(){
            return new List<Case>{(Case)m_Controller.getRecord()};
        }
    }
    
    public class StandardSetControllerAdapter extends ASKHR_CustomChangeCaseOwnerAdapter {
        ApexPages.StandardSetController m_Controller;
        
        StandardSetControllerAdapter(ApexPages.StandardSetController controller){
            m_Controller = controller;
        }
        
        public override ApexPages.PageReference save(){
            return m_Controller.save();
        }
        
        public override List<Case> getSelected(){
            return (List<Case>)m_Controller.getSelected();
        }
    }
}