/**
 * Created by gorikbe on 05/03/2019.
 */

/**
 * This class maintains the count of Trigger executions on event form submission
 */
global class TriggerCount {
    static integer runTimes = 0;

    public static integer getRunTimes(){
        return runTimes;
    }

    public static void setRunTimes(){
        runTimes++;
    }

    public static void setRunTimes(Integer val){
        runTimes = val;

    }
}