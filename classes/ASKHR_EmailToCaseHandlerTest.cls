/**
* This class contains unit tests for validating the behavior of Apex classes
* and triggers.
*
* Unit tests are class methods that verify whether a particular piece
* of code is working properly. Unit test methods take no arguments,
* commit no data to the database, and are flagged with the testMethod
* keyword in the method definition.
*
* All test methods in an organization are executed whenever Apex code is deployed
* to a production organization to confirm correctness, ensure code
* coverage, and prevent regressions. All Apex classes are
* required to have at least 75% code coverage in order to be deployed
* to a production organization. In addition, all triggers must have some code coverage.
* 
* The @isTest class annotation indicates this class only contains test
* methods. Classes defined with the @isTest annotation do not count against
* the organization size limit for all Apex scripts.
*
* See the Apex Language Reference for more information about Testing and Code Coverage.
*/
/*
*This  test case will test ASKHR_EmailMessageHandler
*/

@isTest
public class ASKHR_EmailToCaseHandlerTest {
    
    //
    static testMethod void validateEmailToCase(){
        Map<String, Id> rtMap= new Map<String, Id>();
        List<RecordType>rtList=[select Id, Name from RecordType];
        
        for(RecordType rt:rtList){
            rtMap.put(rt.Name, rt.Id);
        }
        
        Test.startTest();   
        //init custom setting
        List<Email_Routing_Config__c> emrSettings=new List<Email_Routing_Config__c>();
        Email_Routing_Config__c emrSetting1= new Email_Routing_Config__c();
        emrSetting1.Name='GmailTest';
        emrSetting1.Queue_Name__c='Benefits';
        emrSetting1.Routing_Email_Address__c='askhrbenefit@gmail.com';
        emrSettings.add(emrSetting1);
        
        Email_Routing_Config__c emrSetting2= new Email_Routing_Config__c();
        emrSetting2.Name='HRSS_TestBenefits';
        emrSetting2.Queue_Name__c='Benefits';
        emrSetting2.Routing_Email_Address__c='hrss_testbenefits@manulife.com';
        emrSettings.add(emrSetting2);
        
        Email_Routing_Config__c emrSetting3= new Email_Routing_Config__c();
        emrSetting3.Name='HRSS_TestER';
        emrSetting3.Queue_Name__c='Employee Relations';
        emrSetting3.Routing_Email_Address__c='hrss_tester@manulife.com';
        emrSettings.add(emrSetting3);
        
        Email_Routing_Config__c emrSetting4= new Email_Routing_Config__c();
        emrSetting4.Name='HRSS_TestPayroll';
        emrSetting4.Queue_Name__c='Payroll';
        emrSetting4.Routing_Email_Address__c='hrss_testpayroll@manulife.com';
        emrSettings.add(emrSetting4);
        
        Email_Routing_Config__c emrSetting5= new Email_Routing_Config__c();
        emrSetting5.Name='HRSS_TestRecuitment';
        emrSetting5.Queue_Name__c='Recruitment';
        emrSetting5.Routing_Email_Address__c='hrss_testrecuitment@manulife.com';
        emrSettings.add(emrSetting5);
        
        insert emrSettings;
        
        Map<String,String> emRoutingMap=ASKHR_EmailMessageService.getEmailRoutingConfigs();
        //system.debug('***emRoutingMap'+emRoutingMap);
        
        Map<String, Id> queueMap=ASKHR_EmailMessageService.getOwnerIdByName();
        //system.debug('***queueMap'+queueMap);
        Map<String, String> caseSubjectAddressMap=new Map<String, String>();
        List<Case> insertedCaseList=new List<Case>();
        List<EmailMessage> insertedEmails=new List<EmailMessage>();
        
        //    system.debug('***general queue Id is '+queueMap.get('General'));
        for(String address:emRoutingMap.keySet()){
            //OwerId is General queue, Record Type is General HR Case
            //default case ower is general
            Integer var=Crypto.getRandomInteger();
            Case c=new Case(Origin='Email', Secondary_Country_of_Reference__c = 'USA', OwnerId= queueMap.get('Benefits'), 
                            SuppliedEmail='abcTestClass@gmail.com', Priority='Medium', Status='New', 
                            Subject='Subject TestEmail2Case from TestClass'+var,
                            RecordTypeId=rtMap.get('General HR Case') );    
            insertedCaseList.add(c);
            caseSubjectAddressMap.put(c.Subject, address);      
        }   
        insert insertedCaseList;
        for(Case newcase:insertedCaseList){
            Integer emailvar=Crypto.getRandomInteger();
            String cid=newCase.Id;
            EMailMessage emTest1=new EmailMessage(ParentId=cid, ToAddress=caseSubjectAddressMap.get(newcase.Subject), 
                                                  FromAddress='abcTestClass@gmail.com', Subject=newcase.Subject+emailvar, FromName='TestClass',
                                                  TextBody=newcase.Subject+'textbody'+emailvar);
            insertedEmails.add(emTest1);
            
            EMailMessage emTest2=new EmailMessage(ParentId=cid,ToAddress=caseSubjectAddressMap.get(newcase.Subject), 
                                                  FromAddress='abcTestClass@gmail.com', Subject='Multiple test for duplicated case id'+emailvar, FromName='TestClass',
                                                  TextBody='Multiple test for duplicated case id description'+emailvar);
            insertedEmails.add(emTest2);        
        }
        
        insert insertedEmails;  
        Test.stopTest();   
        Map<Id, Case>expectedResultMap=new Map<Id, Case>();
        if(expectedResultMap.size()>0){
            //system.debug('***'+caseIdAddressMap.keySet());
            expectedResultMap.putAll(insertedCaseList);
            List<case> caseResult= new List<case>();
            caseResult=[select Id, Origin, OwnerId, SuppliedEmail,Priority, Status  from case where Id in :expectedResultMap.keySet()]; 
            
            Case expectedCase= new Case();
            //ensure the owner is changed based on email routing address
            for(Case newcase:caseResult ){
                expectedCase=expectedResultMap.get(newcase.Id);
                system.assert(newcase.OwnerId==expectedCase.OwnerId);
                //system.debug('*** ownerId'+newcase.OwnerId+ 'address '+ caseIdAddressMap.get(newcase.Id));
                //system.debug('***expected owner id '+queueMap.get(emRoutingMap.get(caseIdAddressMap.get(newcase.Id))));
                //system.assert(newcase.Id==queueMap.get(emRoutingMap.get(caseIdAddressMap.get(newcase.Id))));
            }
            
        }
        delete insertedEmails;     
    }
    
    @isTest (SeeAllData=true)static void validateEmailToCaseWorkday(){
        
        Contact testSender = ASKHR_TestUtility.createManagerContact();
        
        Map<String, Id> rtMap= new Map<String, Id>();
        List<RecordType>rtList=[select Id, Name from RecordType];
        
        for(RecordType rt:rtList){
            rtMap.put(rt.Name, rt.Id);
        }
        
        Test.startTest();   
        //init custom setting
        List<Email_Routing_Config__c> emrSettings=new List<Email_Routing_Config__c>();      
        Email_Routing_Config__c emrSetting5= new Email_Routing_Config__c();
        emrSetting5.Name='Test Workday';
        emrSetting5.Queue_Name__c='Workday Support';
        emrSetting5.Routing_Email_Address__c='hrss_testworkdaysupport@manulife.com';
        emrSettings.add(emrSetting5);
        
        insert emrSettings;
        
        Map<String, Id> queueMap = ASKHR_EmailMessageService.getOwnerIdByName();
        //system.debug('***queueMap'+queueMap);
        Map<String, String> caseSubjectAddressMap=new Map<String, String>();
        List<EmailMessage> insertedEmails=new List<EmailMessage>();
        
        
        Integer var=Crypto.getRandomInteger();
        Case c=new Case(Origin='Workday Support Email', Secondary_Country_of_Reference__c = 'USA', OwnerId= queueMap.get('Workday Support'), 
                        SuppliedEmail='abcTestClass@gmail.com', Priority='Low', Status='New', 
                        Subject='Subject TestEmail2Case from TestClass'+var,
                        Description= 'Testing',
                        Description__c = 'Tesing',
                        RecordTypeId=rtMap.get('Function') );   
        caseSubjectAddressMap.put(c.Subject, 'workday_support@manulife.com');   
        insert c;
        
        Case c2=new Case(Origin='Workday Support Email', Secondary_Country_of_Reference__c = 'USA', OwnerId= queueMap.get('Workday Support'), 
                         SuppliedEmail='abcTestClass@gmail.com', Priority='Low', Status='New', 
                         Subject='EIB '+var,
                         Description= 'Testing',
                         Description__c = 'Tesing',
                         RecordTypeId=rtMap.get('Function') );   
        caseSubjectAddressMap.put(c.Subject, 'workday_support@manulife.com');   
        insert c2;
        
        Integer emailvar=Crypto.getRandomInteger();
        
        EMailMessage emTest1=new EmailMessage(ParentId=c.Id, ToAddress=caseSubjectAddressMap.get('Testing'), 
                                              FromAddress='test@manulife.com', Subject='IQN ' + emailvar, FromName='TestClass',
                                              TextBody='Testing textbody '+emailvar, HtmlBody= 'Testing textbody'+emailvar,
                                              Incoming = true);
        insertedEmails.add(emTest1);
        
        EMailMessage emTest2=new EmailMessage(ParentId=c2.Id, ToAddress=caseSubjectAddressMap.get('Testing'), 
                                              FromAddress='abcTestClass@gmail.com', Subject='EIB ' + emailvar, FromName='TestClass',
                                              TextBody='EIB '+emailvar, HtmlBody= '<p>EIB textbody<br>EIB textbody<br></p><p>Thanks</p><p>hello</p>From:Me'+emailvar,
                                              Incoming = true);
        insertedEmails.add(emTest2);           
        insert insertedEmails;
        
        Test.stopTest();   
        
        delete insertedEmails;     
    }
    
    static testMethod void validateUpdateDeleteEmailMessage(){
        Test.startTest();
        
        List<Email_Routing_Config__c> emrSettings=new List<Email_Routing_Config__c>();
        Email_Routing_Config__c emrSetting1= new Email_Routing_Config__c();
        emrSetting1.Name='GmailTest';
        emrSetting1.Queue_Name__c='Benefits';
        emrSetting1.Routing_Email_Address__c='askhrbenefit@gmail.com';
        
        insert emrSetting1;
        Map<String, Id> queueMap=ASKHR_EmailMessageService.getOwnerIdByName();
        //test update and delte
        Integer varUpdate=Crypto.getRandomInteger();
        Case c=new Case(Origin='Email', Secondary_Country_of_Reference__c = 'USA', OwnerId=queueMap.get('Benefits'), 
                        SuppliedEmail='abcTestClass@gmail.com', Priority='Medium', Status='New', 
                        Subject='Update Subject TestEmail2Case from TestClass'+varUpdate);
        insert c;
        EMailMessage emTestDelete=new EmailMessage(ParentId=c.Id,ToAddress='askhrbenefit@gmail.com', 
                                                   FromAddress='abcTestClass@gmail.com', Subject='Update test'+varUpdate, FromName='TestClass',
                                                   TextBody='Update test description'+varUpdate);
        insert emTestDelete;
                
        Test.stopTest();
        delete c;
        
        //emTestDelete.delete();
        List<EmailMessage> emUpdateTestResult=new  List<EmailMessage>();
        emUpdateTestResult= [select Id from EmailMessage where Id=:emTestDelete.Id];
        //system.debug('*** test delete '+emUpdateTestResult);
        system.assert(emUpdateTestResult.isEmpty());
        // EmailMessage emDeleteTest=[select FromName from EmailMessage where Id=:emTestUpdate.Id];
        
        // delete emDeleteTest;
    }
    
    /*static testMethod void checkHTMLTest(){
        
    }*/
}