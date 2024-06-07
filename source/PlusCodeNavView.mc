import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class PlusCodeNavView extends WatchUi.View {
    private var _controller as PlusCodeNavController;

    function initialize(controller as PlusCodeNavController) {
        View.initialize();
        _controller = controller;
    }

    function onLayout(dc as Dc) as Void {
    }

    function onShow() as Void {
    }

    function onHide() as Void {
    }

    function onUpdate(dc as Dc) as Void {
        var message;

        if (_controller.isHelp()) {
            message = WatchUi.loadResource(Rez.Strings.HELP);
        } else {
            switch (_controller.getState()) {
                case PlusCodeNavController.STATE_INITIALIZE_GPS: message = WatchUi.loadResource(Rez.Strings.STATE_INITIALIZE_GPS); break;
                case PlusCodeNavController.STATE_LOCATION_AVAILABLE: message = Lang.format(WatchUi.loadResource(Rez.Strings.STATE_LOCATION_AVAILABLE), [ _controller.getRelDistance() ]); break;
                case PlusCodeNavController.STATE_CODE_ENTERED_ERROR_LENGTH: message = Lang.format(WatchUi.loadResource(Rez.Strings.STATE_CODE_ENTERED_ERROR_LENGTH), [ _controller.getInput() ]); break;
                case PlusCodeNavController.STATE_CODE_ENTERED_ERROR_NOPLUS: message = Lang.format(WatchUi.loadResource(Rez.Strings.STATE_CODE_ENTERED_ERROR_NOPLUS), [ _controller.getInput() ]); break;
                case PlusCodeNavController.STATE_CODE_ENTERED_ERROR_CHARS: message = Lang.format(WatchUi.loadResource(Rez.Strings.STATE_CODE_ENTERED_ERROR_CHARS), [ _controller.getInput() ]); break;
                case PlusCodeNavController.STATE_RESULT_OK: message = WatchUi.loadResource(Rez.Strings.STATE_RESULT_OK); break;
                default: message = WatchUi.loadResource(Rez.Strings.STATE_UNDEFINED); break;
            }
        }
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        fitTextToDc(dc, Graphics.FONT_MEDIUM, message);
    }

    private function fitTextToDc(dc as Dc, font as Graphics.FontType, text as String) {
        var a, y, height;

        height = dc.getTextDimensions("ABC", font)[1];
        y = 0;
        a = text;
        while (a.length() > 0) {
            var cutoff, alreadyCutoff = false;

            cutoff = bisectTextWidth(dc, font, a, 0, a.length());
            for (var i = 0; i < cutoff; i++) {
                if (a.substring(i, i + 1).equals("\n")) {
                    cutoff = i + 1;
                    alreadyCutoff = true;
                    break;
                }
            }
            if ((cutoff < a.length()) && (!alreadyCutoff)) {
                for (var i = cutoff; i >= 0; i--) {
                    if (a.substring(i, i + 1).equals(" ")) {
                        cutoff = i;
                        break;
                    }
                }
            }
            dc.drawText(0, y, font, a.substring(0, cutoff), Graphics.TEXT_JUSTIFY_LEFT);
            y += height;
            a = a.substring(cutoff, a.length());
            while ((a.length() > 0) && (a.substring(0, 1).equals(" "))) {
                a = a.substring(1, a.length());
            }
            if (y > dc.getHeight()) {
                break;
            }
        }
    }

    private function bisectTextWidth(dc as Dc, font as Graphics.FontType, text as String, start as Number, end as Number) as Number {
        var middle;

        middle = (start + end) / 2;
        if ((end - start) <= 1) {
            if (dc.getTextWidthInPixels(text.substring(0, end), font) < dc.getWidth()) {
                return end;
            } else {
                return start;
            }
        } else if (dc.getTextWidthInPixels(text.substring(0, middle), font) < dc.getWidth()) {
            return bisectTextWidth(dc, font, text, middle, end);
        } else {
            return bisectTextWidth(dc, font, text, start, middle);
        }
    }    
}