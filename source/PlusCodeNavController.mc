import Toybox.Lang;
import Toybox.Position;
import Toybox.System;
import Toybox.WatchUi;

class PlusCodeNavController {
    public static const STATE_UNDEFINED = 0;
    public static const STATE_INITIALIZE_GPS = 1;
    public static const STATE_LOCATION_AVAILABLE = 2;
    public static const STATE_ENTER_CODE = 3;
    public static const STATE_CODE_ENTERED_ERROR_LENGTH = 4;
    public static const STATE_CODE_ENTERED_ERROR_NOPLUS = 5;
    public static const STATE_CODE_ENTERED_ERROR_CHARS = 6;
    public static const STATE_RESULT_OK = 7;
    private const OLC_MATRIX = "23456789CFGHJMPQRVWX";
    private var _state as Integer = STATE_UNDEFINED;
    private var _position as Position.Info?;
    private var _destination as Position.Location?;
    private var _input as String? = "";
    private var _help as Boolean = false;

    public function getState() {
        return _state;
    }

    public function initialize() {
        _state = STATE_INITIALIZE_GPS;
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, self.method(:onPosition));
    }

    public function onPosition(loc as Position.Info) as Void { 
        if (loc.accuracy >= Position.QUALITY_POOR) { 
            if (loc.when.greaterThan(Time.now().subtract(new Time.Duration(300)))) {
                Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
                _state = STATE_LOCATION_AVAILABLE;
                _position = loc;
                WatchUi.requestUpdate();
            }
        }
    }

    public function onScreenTap() as Void {
        if (_help) {
            _help = false;
            WatchUi.requestUpdate();
        } else if ((_state == STATE_LOCATION_AVAILABLE) || (_state == STATE_CODE_ENTERED_ERROR_LENGTH) || (_state == STATE_CODE_ENTERED_ERROR_NOPLUS) || (_state == STATE_CODE_ENTERED_ERROR_CHARS)) {
            _state = STATE_ENTER_CODE;
            //_input = "M8R5+F9";
            WatchUi.pushView(new WatchUi.TextPicker(_input), new $.PlusCodeNavTextPickerDelegate(self), WatchUi.SLIDE_DOWN);
        } else if (_state == STATE_RESULT_OK) {
            var waypoints, intent = null;

            PersistedContent.saveWaypoint(_destination, {:name => _input});
            waypoints = PersistedContent.getAppWaypoints();
            while (true) {
                var waypoint;

                waypoint = waypoints.next();
                if (waypoint == null) {
                    break;
                } else if (waypoint.getName().equals(_input)) {
                    intent = waypoint.toIntent();
                } else {
                    waypoint.remove();
                }
            }
            if (intent != null) {
                System.exitTo(intent);
            }
        }
    }

    public function onMenu() as Void {
        _help = !_help;
        WatchUi.requestUpdate();
    }

    public function setInput(input as String?) {
        _input = input;
        if (_input == null) {
            _state = STATE_LOCATION_AVAILABLE;
        } else {
            _input = _input.toUpper();
            if (_input.length() > 5) {
                _input = _input.substring(0, 4) + "+" + _input.substring(5, _input.length());
            }
            if ((_input.length() != 7) && (_input.length() != 8)) {
                _state = STATE_CODE_ENTERED_ERROR_LENGTH;
            } else if (!_input.substring(4, 5).equals("+")) {
                _state = STATE_CODE_ENTERED_ERROR_NOPLUS;
            } else {
                var ok;

                ok = true;
                for (var i = 0; i < _input.length(); i++) {
                    if (i != 4) {
                        ok = ok & (OLC_MATRIX.find(_input.substring(i, i + 1)) != null);
                    }
                }
                if (!ok) {
                    _state = STATE_CODE_ENTERED_ERROR_CHARS;
                } else {
                    _destination = calculateDestination();
                    _state = STATE_RESULT_OK;
                }
            }
        }
        WatchUi.requestUpdate();
    }

    public function getInput() as String? {
        return _input;
    }

    public function isHelp() as Boolean {
        return _help;
    }

    public function getRelDistance() as Long {
        return (calculateDistance(_position.position.toDegrees()[0],  _position.position.toDegrees()[1] + 0.5, _position.position.toDegrees()[0],  _position.position.toDegrees()[1] - 0.5) / 2).toLong();
    }

    private function calculateDestination() as Position.Location {
        var input, currentLat, currentLon, offsetLat, offsetLon, matrixLat, matrixLon, targetDistance, targetLat, targetLon;

        input = _input.substring(0, 4) + _input.substring(5, _input.length());
        if (input.length() > 6) {
            input = input.substring(0, 6);
        }
        currentLat = _position.position.toDegrees()[0];
        currentLon = _position.position.toDegrees()[1];
        //currentLat = 51.706387d;
        //currentLon = 5.264122d;
        matrixLat = currentLat.toLong();
        matrixLon = currentLon.toLong();
        offsetLat = 0;
        offsetLon = 0;
        targetDistance = 1000;
        targetLat = currentLat;
        targetLon = currentLon;
        for (var i = 0; i < (input.length() / 2); i++) {
            offsetLat += OLC_MATRIX.find(input.substring(i * 2, i * 2 + 1)) / Math.pow(20, (i + 1));
            offsetLon += OLC_MATRIX.find(input.substring(i * 2 + 1, i * 2 + 2)) / Math.pow(20, (i + 1));
        }
        for (var lat = -1; lat <= 1; lat++) {
            for (var lon = -1; lon <= 1; lon++) {
                var distance;

                distance = calculateDistance(matrixLat + lat + offsetLat, matrixLon + lon + offsetLon, currentLat, currentLon);
                if (distance < targetDistance) {
                    targetLat = matrixLat + lat + offsetLat;
                    targetLon = matrixLon + lon + offsetLon;
                    targetDistance = distance;
                }
            }
        }
        return new Position.Location({ :latitude => targetLat, :longitude => targetLon, :format => :degrees });
    }

    private function calculateDistance(lat1 as Double, lon1 as Double, lat2 as Double, lon2 as Double) as Double {
        var x, y, la1, lo1, la2, lo2;

        la1 = lat1 * Math.PI / 180;
        lo1 = lon1 * Math.PI / 180;
        la2 = lat2 * Math.PI / 180;
        lo2 = lon2 * Math.PI / 180;
        x = (lo2 - lo1) * Math.cos((la1 + la2) / 2);
        y = (la2 - la1);
        return Math.sqrt(x * x + y * y) * 6371;
    }
}