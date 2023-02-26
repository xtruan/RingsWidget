using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

class RingsView extends Ui.View {
    
        
    function initialize() {
        View.initialize();
    }

    //! Load your resources here
    function onLayout(dc as Gfx.Dc) {
    }

    function onHide() {
    }
    
    //! Restore the state of the app and prepare the view to be shown
    function onShow() {    
    }

    //! Update the view
    function onUpdate(dc as Gfx.Dc) {

        //Sys.println(App.getApp().scaleProgressToAngle(0));    
        //Sys.println(App.getApp().scaleProgressToAngle(.25));
        //Sys.println(App.getApp().scaleProgressToAngle(.5));
        //Sys.println(App.getApp().scaleProgressToAngle(.75));
        //Sys.println(App.getApp().scaleProgressToAngle(1));
    
        var rings = App.getApp().getRingsProgress();
        //Sys.println(rings);
        
        var calories = App.getApp().scaleProgressToAngle(rings[0]);
        var activeMins = App.getApp().scaleProgressToAngle(rings[1]);
        var steps = App.getApp().scaleProgressToAngle(rings[2]);
        
        var x = dc.getWidth() / 2;
        var y = dc.getHeight() / 2;
        
        // Set background color
        dc.setColor( Gfx.COLOR_TRANSPARENT, Gfx.COLOR_BLACK );
        dc.clear();
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        
        //Sys.println("x: " + x + ", y: " + y);
        var r = x;
        if (x >= y) {
            r = y;
        }
        var s = (r / 30);
        
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        
        dc.setPenWidth(6 * s);
        
//        dc.setColor( Gfx.COLOR_DK_GRAY, Gfx.COLOR_TRANSPARENT );
//        dc.drawCircle(
//            x,
//            y,
//            r - (6 * s));
//        dc.drawCircle(
//            x,
//            y,
//            r - (13 * s));
//        dc.drawCircle(
//            x,
//            y,
//            r - (20 * s));

        // first loop, colored rings
        
        if (!App.getApp().isMonochrome()) {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        dc.drawArc(
            x, 
            y, 
            r - (6 * s), 
            Gfx.ARC_CLOCKWISE, 
            90, 
            calories);
            
        if (!App.getApp().isMonochrome()) {
            dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
        }
        dc.drawArc(
            x, 
            y, 
            r - (13 * s), 
            Gfx.ARC_CLOCKWISE, 
            90, 
            activeMins);
            
        if (!App.getApp().isMonochrome()) {
            dc.setColor( Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT );
        }
        dc.drawArc(
            x, 
            y, 
            r - (20 * s), 
            Gfx.ARC_CLOCKWISE, 
            90, 
            steps);
            
        // second loop, 2x goal color ring
        
        dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
        if (!App.getApp().isMonochrome()) {
            // get second ring mode
            var secondRingMode = App.getApp().getPropertySafe("secondRingMode");
            if (secondRingMode == null) {
                secondRingMode = 0; // 0 means use COLOR_YELLOW
            }
        
            if (secondRingMode == 0) { // 0 means use COLOR_YELLOW
                dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
            } else if (secondRingMode == 1) { // 1 means use COLOR_ORANGE
                dc.setColor( Gfx.COLOR_ORANGE, Gfx.COLOR_TRANSPARENT );
            } else if (secondRingMode == 2) { // 0 means use COLOR_WHITE
                dc.setColor( Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT );
            } else if (secondRingMode == 3) { // 0 means don't draw, return
                return;
            } else {
                dc.setColor( Gfx.COLOR_YELLOW, Gfx.COLOR_TRANSPARENT );
            }
        }
        
        if (rings[0] > 1.0) {
            calories = App.getApp().scaleProgressToAngle(rings[0] - 1.0);
            dc.drawArc(
                x, 
                y, 
                r - (6 * s), 
                Gfx.ARC_CLOCKWISE, 
                90, 
                calories);
        }
            
        if (rings[1] > 1.0) {
            activeMins = App.getApp().scaleProgressToAngle(rings[1] - 1.0);
            dc.drawArc(
                x, 
                y, 
                r - (13 * s), 
                Gfx.ARC_CLOCKWISE, 
                90, 
                activeMins);
        }
            
        if (rings[2] > 1.0) {
            steps = App.getApp().scaleProgressToAngle(rings[2] - 1.0);
            dc.drawArc(
                x, 
                y, 
                r - (20 * s), 
                Gfx.ARC_CLOCKWISE, 
                90, 
                steps);
        }
                
    }
    
}
