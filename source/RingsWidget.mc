using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Application.Properties as Props;
using Toybox.ActivityMonitor as Act;
using Toybox.UserProfile;
using Toybox.Time;
using Toybox.Time.Gregorian;

(:glance)
class RingsWidget extends App.AppBase {

    hidden var progressTimer = null;
    
    function initialize() {
        AppBase.initialize();
    }
    
    // https://forums.garmin.com/developer/connect-iq/f/discussion/208338/active-calories?pifragment-1298=2#979052
    function calculateActiveCalories(curCalories) {
        var today = Gregorian.info(Time.now(), Time.FORMAT_MEDIUM);        
        var profile = UserProfile.getProfile();
        var age = today.year - profile.birthYear;
        var weight = profile.weight / 1000.0;

        var restCalories = 2000.0;
        if (profile.gender == UserProfile.GENDER_MALE) {
            restCalories = 5.2 - 6.116*age + 7.628*profile.height + 12.2*weight;
        } else if (profile.gender == UserProfile.GENDER_FEMALE) {
            restCalories = -197.6 - 6.116*age + 7.628*profile.height + 12.2*weight;
        } else { // GENDER_MALE
            restCalories = 5.2 - 6.116*age + 7.628*profile.height + 12.2*weight;
        }
        restCalories = Math.round((today.hour*60+today.min) * restCalories / 1440 ).toNumber();
        var activeCalories = (curCalories - restCalories) * 1.0;
        return activeCalories;
    }
    
    function getRingsProgress() {
        var info = Act.getInfo();
        var timeOfDay = Time.now().subtract(Time.today()).value();
        var dayProgress = timeOfDay / 86400.0; // SECONDS_PER_DAY
        
        // ACTIVE CALORIES (RED) RING
        
        // get total calories
        var totalCalories = 2000.0 * dayProgress; // 2000 total calories as a fraction of today default
        if (info has :calories && info.calories != null) {
            totalCalories = info.calories * 1.0;
        }
        // get user provided resting calories
        var restingCaloriesGoal = getPropertySafe("calorieGoal") * 1.0;
        if (restingCaloriesGoal == null) {
            restingCaloriesGoal = 0.0; // 0 resting calories default (calculate automatically)
        }
        var activeCalories = 0.0;
        if (restingCaloriesGoal == 0.0) {
            // if resting calories goal is zero, calculate using magic formula
            activeCalories = calculateActiveCalories(totalCalories);
        } else {
            // else use user provided resting calories, scaled to the time of day, 
            // subtracted from total calories
            var restingCaloriesNow = restingCaloriesGoal * dayProgress;
            activeCalories = totalCalories - restingCaloriesNow;   
        }
        if (activeCalories < 0.0) {
            // failsafe: active calories can't be negative
            activeCalories = 0.0;
        }
        // get user provided active calories goal
        var activeCaloriesGoal = getPropertySafe("activeCalorieGoal") * 1.0;
        if (activeCaloriesGoal == null) {
            activeCaloriesGoal = 500.0; // 500 active calories default
        }
        
        // ACTIVE MINS (GREEN) RING
        
        // get active mins mode
        var activeMinsMode = getPropertySafe("activeMinsMode");
        if (activeMinsMode == null) {
            activeMinsMode = 0; // 0 means use Total (Moderate + 2x Vigorous)
        }
        // get active mins
        var activeMins = 0.0;
        if (info has :activeMinutesDay && info.activeMinutesDay != null) {
            if (activeMinsMode == 0) { // Total (Moderate + 2x Vigorous)
                activeMins = info.activeMinutesDay.total * 1.0;
            } else if (activeMinsMode == 1) { // Moderate + Vigorous
                activeMins = (info.activeMinutesDay.vigorous + info.activeMinutesDay.moderate) * 1.0;
            } else if (activeMinsMode == 2) { // Vigorous Only
                activeMins = info.activeMinutesDay.vigorous * 1.0;
            } else { // fallback - Total (Moderate + 2x Vigorous)
                activeMins = info.activeMinutesDay.total * 1.0;
            }
        }
        // get active mins goal
        var activeMinsGoal = 150.0 / 7.0; // 150 active minutes per week default
        if (info has :activeMinutesWeekGoal && info.activeMinutesWeekGoal != null) {
            activeMinsGoal = info.activeMinutesWeekGoal / 7.0;
        }
        
        // STEPS (BLUE) RING
        
        // get steps
        var steps = 0.0;
        if (info has :steps && info.steps != null) {
            steps = info.steps * 1.0;
        }
        // get steps goal
        var stepsGoal = 10000.0; // 10000 steps default
        if (info has :stepGoal && info.stepGoal != null) {
            stepsGoal = info.stepGoal * 1.0;
        }
        
        Sys.println("C: " + activeCalories);
        Sys.println("CG: " + activeCaloriesGoal);
        var caloriesProgress = activeCalories / activeCaloriesGoal;
        
        Sys.println("M: " + activeMins);
        Sys.println("MG: " + activeMinsGoal);
        var activeMinsProgress = activeMins / activeMinsGoal;
        
        Sys.println("S: " + steps);
        Sys.println("SG: " + stepsGoal);
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
            scaledProgress = 0.0001;
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