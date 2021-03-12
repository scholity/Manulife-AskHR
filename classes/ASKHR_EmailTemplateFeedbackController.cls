/** 
*@description this class is the controller for article feedback email
*/

public class ASKHR_EmailTemplateFeedbackController {

    public String mRecipientName { get; Set; } //recipient Id in the form of User Id
    public Id mArticleId { get; Set; }
    public String mTextHeader { get{ return getHeader();} Set; }
    public String mTextBody { get { return getBody(); } Set; } //the output text
    public String mTextFooter { get { return getFooter(); } Set; } //the footer text
    public String mTextAnswer { get; Set; }
    public Boolean mHasButton { get; Set; }
    public Boolean mHasAnswer { get; Set; }
    public String mButtonText { get{ return getButtonText(); } Set; }
    public String mTextInput { get; Set; }
	//constructor
    public ASKHR_EmailTemplateFeedbackController(){

        
        if (String.isBlank(mTextInput))
        {
        mTextInput = '';
        }

        if (String.isBlank(mRecipientName))
        {
            mRecipientName = '';
        }
    } 

    /**
    *@description this method gets the header
	*@return String of replaced recipient name
    */
    private String getHeader(){
        String[] str = mTextInput.split(';');

        if (str.size() > 0)
        {
            //replace the recipient
            return str[0].replace('{recipient.Name}',mRecipientName);
        }else return '';

    }

	/**
    *@description this method gets the body 
	*@return String of body text
    */
    private String getBody(){
        String[] str = mTextInput.split(';');

        if (str.size() > 1)
        {
            return str[1];
        }else return '';

    }
	/**
    *@description this method gets the button text
	*@return String of button text
    */
    private String getButtonText(){
        String[] str = mTextInput.split(';');

        if (str.size() == 4)
        {
            return str[2];           
        }else return '';
    }
	/**
    *@description this method gets the footer
	*@return String of footer text
    */
    private String getFooter(){
        String[] str = mTextInput.split(';');

        if (str.size() == 4)
        { 
            return str[3];
        }else if(str.size() == 3){
            return str[2];
        }else return '';
    }
     
 }