// Author: Devender Thareja
// September 2017
// 
public class ManulifeHelper {
    private static Map<Integer, String> frenchMonths = new Map<Integer, String>();
    private static Map<Integer, String> chineseMonths = new Map<Integer, String>();
    private static Map<Integer, String> japaneseMonths = new Map<Integer, String>();
    private static Map<Integer, String> indonesianMonths = new Map<Integer, String>();
    private static Map<Integer, String> englishMonths = new Map<Integer, String>();
    private static String chJaYrStr = '年';
    private static String chJaDayStr = '日';

    static{

        englishMonths.put(1, 'January');
        englishMonths.put(2, 'February');
        englishMonths.put(3, 'March');
        englishMonths.put(4, 'April');
        englishMonths.put(5, 'May');
        englishMonths.put(6, 'June');
        englishMonths.put(7, 'July');
        englishMonths.put(8, 'August');
        englishMonths.put(9, 'September');
        englishMonths.put(10, 'October');
        englishMonths.put(11, 'November');
        englishMonths.put(12, 'December');

        frenchMonths.put(1, 'janvier');
        frenchMonths.put(2, 'février');
        frenchMonths.put(3, 'mars');
        frenchMonths.put(4, 'avril');
        frenchMonths.put(5, 'mai');
        frenchMonths.put(6, 'juin');
        frenchMonths.put(7, 'juillet');
        frenchMonths.put(8, 'août');
        frenchMonths.put(9, 'septembre');
        frenchMonths.put(10, 'octobre');
        frenchMonths.put(11, 'novembre');
        frenchMonths.put(12, 'décembre');


        indonesianMonths.put(1,'Januari');
        indonesianMonths.put(2,'Februari');
        indonesianMonths.put(3,'Maret');
        indonesianMonths.put(4,'April');
        indonesianMonths.put(5,'Mei');
        indonesianMonths.put(6,'Juni');
        indonesianMonths.put(7,'Juli');
        indonesianMonths.put(8,'Agustus');
        indonesianMonths.put(9,'September');
        indonesianMonths.put(10,'Oktober');
        indonesianMonths.put(11,'November');
        indonesianMonths.put(12,'Desember');

        chineseMonths.put(1,'一月');
        chineseMonths.put(2,'二月');
        chineseMonths.put(3,'三月');
        chineseMonths.put(4,'四月');
        chineseMonths.put(5,'五月');
        chineseMonths.put(6,'六月');
        chineseMonths.put(7,'七月');
        chineseMonths.put(8,'八月');
        chineseMonths.put(9,'九月');
        chineseMonths.put(10,'十月');
        chineseMonths.put(11,'十一月');
        chineseMonths.put(12,'十二月');

        // Chinese and Japanese takes the same characters for Months.

        japaneseMonths.put(1,'一月');
        japaneseMonths.put(2,'二月');
        japaneseMonths.put(3,'三月');
        japaneseMonths.put(4,'四月');
        japaneseMonths.put(5,'五月');
        japaneseMonths.put(6,'六月');
        japaneseMonths.put(7,'七月');
        japaneseMonths.put(8,'八月');
        japaneseMonths.put(9,'九月');
        japaneseMonths.put(10,'十月');
        japaneseMonths.put(11,'十一月');
        japaneseMonths.put(12,'十二月');
        }
    
    public static String formatTheDate(DateTime theDate, String language){
        System.debug('Language='+language);
        String dateString = null;

        switch on language {
            when 'fr'{
                dateString = theDate.day()+ ' ' +frenchMonths.get(theDate.month()) +' '+theDate.year();
            }
            when 'zh_CN'{
                dateString = theDate.year()+chJaYrStr+' '+chineseMonths.get(theDate.month())+' '+theDate.day()+chJaDayStr;
            }
            when 'ja'{
                dateString = theDate.year()+chJaYrStr+' '+japaneseMonths.get(theDate.month())+' '+theDate.day()+chJaDayStr;
            }
            when 'in'{
                dateString =  indonesianMonths.get(theDate.month())+' '+theDate.day()+', '+theDate.year();
            }
            when 'en_US'{
                dateString = englishMonths.get(theDate.month())+' '+theDate.day()+', '+theDate.year();
            }
        }
        return dateString;
    }
}