/**
 * Created by tiandai on 2018-10-29.
 */

public virtual with sharing class MCMessage {

    public virtual with sharing class MessageError {
        public String type;
        public String trace;
        public String message;
    }

    public virtual with sharing class MCResponse {
        public List<Rendering> renderings;
        public String pageRenderings;
        public String message;
        public String contentRemaining;
    }

    public virtual with sharing class Rendering {
        public Map<String, String> renderMap;
        public String originId;
        public String contentIdcontentId;
    }

    public virtual with sharing class Article implements Comparable{
        public String coid;
        public String articleDate;

        // Constructor
        public Article(String coid, String articleDate) {
            this.coid = coid;
            this.articleDate = articleDate;
        }

        // Implement the compareTo() method
        public Integer compareTo(Object compareTo) {
            Article compareToArticle = (Article)compareTo;
            Double thisDate = Double.valueOf(articleDate);
            Double compareToDate = Double.valueOf(compareToArticle.articleDate);

            if (thisDate == compareToDate) return 0;
            if (thisDate < compareToDate) return 1;
            return -1;
        }
    }
}