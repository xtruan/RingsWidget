using Toybox.System as Sys;
using Toybox.WatchUi as Ui;

class RingsDelegate extends Ui.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }
    
    function onKey(key) {
        Sys.println("Key: " + key.getKey());
        if (key.getKey() == Ui.KEY_ESC) {
            Sys.println("Quitting!");
            return false;
        }
        return false;
    }

}