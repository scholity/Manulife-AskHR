// Author: Devender Thareja
// September 2017
// 
@isTest
public class ManulifeHelper_Test {
    
    @isTest
    public static void testFormatTheDate(){
        List<DateTime> inDates = new List<DateTime> { 
            DateTime.newInstance(2017,01,01),
                DateTime.newInstance(2017,02,01),
                DateTime.newInstance(2017,03,01),
                DateTime.newInstance(2017,04,01),
                DateTime.newInstance(2017,05,01),
                DateTime.newInstance(2017,06,01),
                DateTime.newInstance(2017,07,01),
                DateTime.newInstance(2017,08,01),
                DateTime.newInstance(2017,09,01),
                DateTime.newInstance(2017,10,01),
                DateTime.newInstance(2017,11,01),
                DateTime.newInstance(2017,12,01)
                };
                    System.debug(inDates);
         System.assertEquals('1 janvier 2017', ManulifeHelper.formatTheDate(inDates[0], 'fr'),'Expected "1 janvier 2017": Received:'+ ManulifeHelper.formatTheDate(inDates[0], 'fr') );                        
         System.assertEquals('1 février 2017', ManulifeHelper.formatTheDate(inDates[1], 'fr'),'Not formated correctly "1 février 2017"');                        
         System.assertEquals('1 mars 2017', ManulifeHelper.formatTheDate(inDates[2], 'fr'),'Not formated correctly "1 mars 2017"');                        
         System.assertEquals('1 avril 2017', ManulifeHelper.formatTheDate(inDates[3], 'fr'), 'Not formated correctly "1 avril 2017"');                        
         System.assertEquals('1 mai 2017', ManulifeHelper.formatTheDate(inDates[4], 'fr'),'Not formated correctly "1 mai 2017"');                        
         System.assertEquals('1 juin 2017', ManulifeHelper.formatTheDate(inDates[5], 'fr'),'Not formated correctly "1 juin 2017"');                        
         System.assertEquals('1 juillet 2017', ManulifeHelper.formatTheDate(inDates[6], 'fr'),'Not formated correctly "1 juillet 2017"');                        
         System.assertEquals('1 août 2017', ManulifeHelper.formatTheDate(inDates[7], 'fr'),'Not formated correctly "1 août 2017"');                        
         System.assertEquals('1 septembre 2017', ManulifeHelper.formatTheDate(inDates[8], 'fr'),'Not formated correctly "1 septembre 2017"');                        
         System.assertEquals('1 octobre 2017', ManulifeHelper.formatTheDate(inDates[9], 'fr'),'Not formated correctly "1 octobre 2017"');                        
         System.assertEquals('1 novembre 2017', ManulifeHelper.formatTheDate(inDates[10], 'fr'),'Not formated correctly "1 novembre 2017"');                        
         System.assertEquals('1 décembre 2017', ManulifeHelper.formatTheDate(inDates[11], 'fr'),'Not formated correctly "1 décembre 2017"');                        
}
}