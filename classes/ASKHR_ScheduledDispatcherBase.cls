public abstract class ASKHR_ScheduledDispatcherBase Implements Schedulable {
    
    public Interface IScheduleDispatchee 
    { 
        void execute(SchedulableContext sc); 
    } 
    
    protected abstract string GetScheduleDispatcheeTypeName();
    
    public void execute(SchedulableContext sc) 
    {
        Type targettype = Type.forName(GetScheduleDispatcheeTypeName());   
        if(targettype!=null) {
            IScheduleDispatchee obj = (IScheduleDispatchee)targettype.NewInstance();
            obj.execute(sc);   
        } 
    } 
}