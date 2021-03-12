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
@isTest
public class ASKHR_EmailTemplateFeedbackTest {

    static testMethod void emailfeedbackTest(){
        ASKHR_EmailTemplateFeedbackController etfc = new ASKHR_EmailTemplateFeedbackController();
        etfc.mRecipientName = 'Test';
        etfc.mHasButton = true;
        etfc.mHasAnswer = true;
        etfc.mArticleId = null;
        etfc.mTextAnswer = 'Test Answer';
        etfc.mTextInput = 'test1;test2;test3;test4';
        system.assertNotEquals(null, etfc.mTextHeader);
        system.assertNotEquals(null, etfc.mTextBody);
        system.assertNotEquals(null, etfc.mTextFooter);
        system.assertNotEquals(null, etfc.mButtonText);
        system.assertNotEquals(null, etfc.mTextAnswer);
        system.assertEquals(true, etfc.mHasButton);
        
        etfc.mTextInput = 'test1;test2;test3';
        system.assertNotEquals(null, etfc.mTextFooter);
                
        etfc.mTextInput = '';
        system.assertEquals('', etfc.mTextHeader);
        system.assertEquals('', etfc.mTextBody);
        system.assertEquals('', etfc.mTextFooter);
        system.assertNotEquals(null, etfc.mButtonText);
    }
}