public interface ASKHR_ISendSurvey_Responder {

    void SendSuccess();
    void SendFail(String errorMessage, String errorType);
}