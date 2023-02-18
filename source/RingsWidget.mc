using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Props;
using Toybox.ActivityMonitor as Act;

(:glance)
class RingsWidget extends App.AppBase {

    hidden var progressTimer = null;
    
    function initialize() {
        AppBase.initialize();
    }
    
    function getRingsProgress() {
        var info = Act.getInfo();
        
        var calories = 0.0;
        if (info has :calories && info.calories != null) {
            calories = info.calories * 1.0;
        }
        var caloriesGoal = getPropertySafe("calorieGoal") * 1.0;
        
        var activeMins = 0.0;
        if (info has :activeMinutesDay && info.activeMinutesDay != null) {
            activeMins = info.activeMinutesDay.total * 1.0;
        }
        var activeMinsGoal = 150.0 / 7.0;
        if (info has :activeMinutesWeekGoal && info.activeMinutesWeekGoal != null) {
            activeMinsGoal = info.activeMinutesWeekGoal / 7.0;
        }
        
        var steps = 0.0;
        if (info has :steps && info.steps != null) {
            steps = info.steps * 1.0;
        }
        var stepsGoal = 10000.0;
        if (info has :stepGoal && info.stepGoal != null) {
            stepsGoal = info.stepGoal * 1.0;
        }
        
        //Sys.println(calories);
        //Sys.println(caloriesGoal);
        var caloriesProgress = calories / caloriesGoal;
        
        //Sys.println(activeMins);
        //Sys.println(activeMinsGoal);
        var activeMinsProgress = activeMins / activeMinsGoal;
        
        //Sys.println(steps);
        //Sys.println(stepsGoal);
        var stepsProgress = steps / stepsGoal;
        
        return [caloriesProgress, activeMinsProgress, stepsProgress];
    }
    
    //    090
    // 180 O 000  
    //    270
    function scaleProgressToAngle(progress) {
        var scaledProgress = progress * 360.0;
        if (scaledProgress >= 360.0) {
            scaledProgress = 360.0;
        } else if (scaledProgress <= 0.0) {
            scaledProgress = 0.001;
        }
        var rotatedProgress = 90.0 - scaledProgress;
        if (rotatedProgress < 0) {
            rotatedProgress = 360.0 + rotatedProgress;
        }
        return rotatedProgress;
    }

    function setPropertySafe(key, val) {
        var deviceSettings = Sys.getDeviceSettings();
        var ver = deviceSettings.monkeyVersion;
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 2 && ver[1] >= 4) || ver[0] > 2 ) ) {
            // new school devices (>2.4.0) use Storage
            Props.setValue(key, val);
        } else {
            // old school devices use AppBase properties
            setProperty(key, val);
        }
    }
    
    function getPropertySafe(key) {
        var deviceSettings = Sys.getDeviceSettings();
        var ver = deviceSettings.monkeyVersion;
        if ( ver != null && ver[0] != null && ver[1] != null && 
            ( (ver[0] == 2 && ver[1] >= 4) || ver[0] > 2 ) ) {
            // new school devices (>2.4.0) use Storage
            return Props.getValue(key);
        } else {
            // old school devices use AppBase properties
            return getProperty(key);
        }
    }
    
    function isMonochrome() {
        var deviceSettings = Sys.getDeviceSettings();
        var deviceId = Ui.loadResource(Rez.Strings.DeviceId);
        var isOcto = deviceId != null && deviceId.equals("octo");
        // only octo watches are mono... at least for now
        return isOcto;
    }

    //! onStart() is called on application start up
    function onStart(state) {
        progressTimer = new Timer.Timer();
        progressTimer.start(method(:updateProgress), 10000, true);
    }
    
    function updateProgress() {
        Ui.requestUpdate();
    }
    
    //! onStop() is called on application shutdown
    function onStop(state) {
        if (progressTimer != null) {
            progressTimer.stop();
        }
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new RingsView(), new RingsDelegate() ];
    }
    
    function getGlanceView() {
        return [ new RingsGlanceView() ];
    }

}