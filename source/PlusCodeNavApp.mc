import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class PlusCodeNavApp extends Application.AppBase {
    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var controller = new $.PlusCodeNavController();
        return [ new $.PlusCodeNavView(controller), new $.PlusCodeNavDelegate(controller) ];
    }
}

function getApp() as PlusCodeNavApp {
    return Application.getApp() as PlusCodeNavApp;
}