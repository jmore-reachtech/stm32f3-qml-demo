import QtQuick 2.0
import "components"
import com.reachtech.systemplugin 1.0

Rectangle {
    id: root
	objectName: "root"
    width: 800
    height: 480
    color: "#bbe5fb"
	/* We can send this signal which is caught in mainview */
	signal message(string msg)
    
	/* For our system.execute() calls */
	System {
		id: system
	}
	
	/* The mainview is listening for notReadyToSend signals. Watch that 
		that property to make sure we are still connected */
	Connections {
        target: mainView
        onAppConnectedChanged: {
            led_light1.on = mainView.appConnected
        }
    }
	
	/* Visual indicator for connection status */
	LEDLight {
        id: led_light1
        x: 738
        y: 5
        width: 58
        height: 58
        on: false
        font.pixelSize: 9
        textColor: "#000000"
        textPosition: "bottom"
        label: ""
        fieldSpacing: 2
        font.bold: true
        font.family: "Arial"
        imageOff: "images/ledoff.png"
        imageOn: "images/ledon.png"
    }
	
	Text {
        x: 159
        y: 46
        width: 800
        text: "STM32F3 Demo"
        anchors.horizontalCenterOffset: 0
        horizontalAlignment: Text.AlignHCenter
        font.family: "DejaVu Sans"
        font.pixelSize: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }

	/* Load the firmware screen */
    ImageButton {
        id: button2
        x: 207
        y: 138
        width: 113
        height: 70
        text: "Firmware"
        imageUp: "images/internal_button_up.bmp"
        font.pixelSize: 20
        textColor: "#000000"
        imageDown: "images/internal_button_dn.bmp"
        font.family: "DejaVu Sans"
        onButtonClick: {
			/* Before loading the upgrade screen stop the SIO and TIO Agents */
            console.debug("Go to Upgrade view")
			system.execute("/etc/init.d/tio-agent stop")
			system.execute("/etc/init.d/sio-agent stop")
			root.message("upgradeview.qml")
        }
    }
	
	/* Toggle LED on STM32f3 */
	Switch{
        id: switch_led3
        x: 375
        y: 138
        width: 113
        height: 57
        textOffBold: true
        textOnBold: true
        textOff: "LED 3 Off"
        textOn: "LED 3 On"
        imageOff: "images/internal_button_up.bmp"
        imageOn: "images/internal_button_dn.bmp"
        on: false;

        onOnChanged: {
            if (on)
                connection.sendMessage("L31");
            else
                connection.sendMessage("L30");
        }
    }
	
	/* Toggle LED on STM32f3 */
	Switch{
        id: switch_led5
        x: 375
        y: 205
        width: 113
        height: 57
        textOffBold: true
        textOnBold: true
        textOff: "LED 5 Off"
        textOn: "LED 5 On"
        imageOff: "images/internal_button_up.bmp"
        imageOn: "images/internal_button_dn.bmp"
        on: false;

        onOnChanged: {
            if (on)
                connection.sendMessage("L51");
            else
                connection.sendMessage("L50");
        }
    }

	/* Set the connection status once this screen loads */
	Component.onCompleted: {
		led_light1.on = mainView.appConnected
	}

}

