import Toybox.Lang;
import Toybox.WatchUi;

class PlusCodeNavDelegate extends WatchUi.BehaviorDelegate {
    private var _controller as PlusCodeNavController;

    function initialize(controller as PlusCodeNavController) {
        BehaviorDelegate.initialize();
        _controller = controller;
    }

    function onMenu() as Boolean {
        _controller.onMenu();
        return true;
    }

    function onTap(evt as ClickEvent) as Boolean {
        _controller.onScreenTap();
        return true;
    }
}