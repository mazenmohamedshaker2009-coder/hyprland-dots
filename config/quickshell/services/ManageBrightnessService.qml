import QtQuick
import Quickshell
import Quickshell.Io

import "../" 1.0

Item {
    id: root

    signal brightnessUpdated(real brightness)

    property real brightness: 0
    property bool brightnessInternalRequest: false
    property real lastBrightness: -1
    property bool initialized: false

    // كشف مسار الجهاز تلقائياً لضمان عدم حدوث خطأ
    property string backlightDevice: "intel_backlight"

    Component.onCompleted: {
        detectBacklight.running = true;
    }

    Process {
        id: detectBacklight
        command: ["sh", "-c", "if [ -d /sys/class/backlight/intel_backlight ]; then echo 'intel_backlight'; elif [ -d /sys/class/backlight/amdgpu_bl0 ]; then echo 'amdgpu_bl0'; else ls /sys/class/backlight | head -n 1; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                let dev = text.trim();
                if (dev.length > 0) {
                    root.backlightDevice = dev;
                }
                brightnessGetter.running = true;
            }
        }
    }

    // =========================================================
    // Control Functions (Setter Methods - Silent & Precise)
    // =========================================================
    
    function setBrightness(val) {
        root.brightnessInternalRequest = true; // تفعيل القفل قبل تغيير الإضاءة

        let percentage = Math.max(0, Math.min(100, val));
        
        // تحديث القيمة محلياً فوراً لضمان سلاسة السلايدر أثناء السحب
        root.brightness = percentage;
        root.lastBrightness = percentage;

        // استخدام brightnessctl إن وجد (لتجاوز مشاكل الصلاحيات)، أو sysfs كبديل
        brightnessSetter.command = [
            "sh",
            "-c",
            "if command -v brightnessctl >/dev/null 2>&1; then " +
            "  brightnessctl set " + percentage + "% -q; " +
            "else " +
            "  max=$(cat /sys/class/backlight/" + root.backlightDevice + "/max_brightness); " +
            "  target=$((max * " + percentage + " / 100)); " +
            "  echo $target > /sys/class/backlight/" + root.backlightDevice + "/brightness; " +
            "fi"
        ];
        brightnessSetter.running = true;
    }

    // Process لتنفيذ تغيير الإضاءة
    Process {
        id: brightnessSetter
        running: false
        onRunningChanged: {
            if (!running) {
                // تأخير بسيط لإلغاء القفل لضمان عدم حدوث تداخل مع الـ udev monitor
                lockTimer.restart();
            }
        }
    }

    Timer {
        id: lockTimer
        interval: 150
        repeat: false
        onTriggered: {
            root.brightnessInternalRequest = false;
        }
    }


    // =========================================================
    // Backlight event monitor (Udev)
    // =========================================================

    Process {
        id: monitor

        command: [
            "udevadm",
            "monitor",
            "--udev",
            "--subsystem-match=backlight"
        ]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (root.brightnessInternalRequest)
                    return

                if (data.includes(root.backlightDevice) || data.includes("backlight"))
                    brightnessGetter.running = true
            }
        }
    }


    // =========================================================
    // Brightness Getter
    // =========================================================

    Process {
        id: brightnessGetter

        command: [
            "sh",
            "-c",
            "if command -v brightnessctl >/dev/null 2>&1; then " +
            "  brightnessctl get; brightnessctl max; " +
            "else " +
            "  cat /sys/class/backlight/" + root.backlightDevice + "/brightness; " +
            "  cat /sys/class/backlight/" + root.backlightDevice + "/max_brightness; " +
            "fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.brightnessInternalRequest)
                    return

                let lines = text.trim().split('\n');
                if (lines.length < 2) return;

                let current = parseFloat(lines[0]);
                let max = parseFloat(lines[1]);

                if (isNaN(current) || isNaN(max) || max === 0)
                    return;

                const value = Math.round((current * 100) / max);

                const brightnessChanged =
                    root.initialized &&
                    Math.abs(root.lastBrightness - value) > 0.0001

                root.brightness = value
                root.lastBrightness = value

                if (brightnessChanged)
                    root.brightnessUpdated(value)

                root.initialized = true
            }
        }
    }
}
