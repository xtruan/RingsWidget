using Toybox.Application as App;
using Toybox.System as Sys;
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

(:glance)
class RingsGlanceView extends Ui.GlanceView {
    
    function initialize() {
        GlanceView.initialize();
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
        
        // Shift left for glance pretty-making
        x = r - (2 * s);
        
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
        
        if (!App.getApp().isMonochrome()) {
            dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
        }
        dc.drawArc(
            x, 
            y, 
            r - (6 * s), 
            Gfx.ARC_CLOCKWISE, 
            90, 
            90);
            
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
                
    }
    
//    function onUpdate(dc as Gfx.Dc) {
//        
//        var x = dc.getWidth() / 2;
//        var y = dc.getHeight() / 2;
//        
//        Sys.println("x: " + x + ", y: " + y);
//        var r = x;
//        if (x >= y) {
//            r = y;
//        }
//        var s = (r / 30);
//        
//        dc.setPenWidth(6 * s);
//        
//        if (dc has :setAntiAlias) {
//            dc.setAntiAlias(true);
//        }
//        
//        dc.setColor( Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT );
//        dc.drawArc(
//            (x / 2) - (9 * s), 
//            y, 
//            r - (25 * s), 
//            Gfx.ARC_CLOCKWISE, 
//            90, 
//            180);
//            
//        dc.setColor( Gfx.COLOR_GREEN, Gfx.COLOR_TRANSPARENT );
//        dc.drawArc(
//            x - (7 * s), 
//            y, 
//            r - (25 * s), 
//            Gfx.ARC_CLOCKWISE, 
//            90, 
//            180);
//            
//        dc.setColor( Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT );
//        dc.drawArc(
//            x + (x / 2) - (5 * s), 
//            y, 
//            r - (25 * s), 
//            Gfx.ARC_CLOCKWISE, 
//            90, 
//            180);
//        
//    }
}