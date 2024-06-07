import Toybox.Lang;
import Toybox.WatchUi;

class PlusCodeNavTextPickerDelegate extends WatchUi.TextPickerDelegate {
    private var _controller as PlusCodeNavController;

    public function initialize(controller as PlusCodeNavController) {
        WatchUi.TextPickerDelegate.initialize();
        _controller = controller;
    }

    public function onTextEntered(text as String, changed as Boolean) as Boolean {
        _controller.setInput(text);
        return true;
    }

    public function onCancel() as Boolean {
        _controller.setInput(null);
        return true;
    }
}