import QtQuick 2.0
import "components"
import com.reachtech.systemplugin 1.0

Rectangle {
    id: root
	objectName: "root"
    width: 800
    height: 480
    color: "#bbe5fb"
	signal message(string msg)
    
	System {
		id: system
	}
	
	Connections {
        target: mainView
        onAppConnectedChanged: {
			led_light1.on = mainView.appConnected
			
			if(mainView.appConnected) {
				connection.sendMessage("MS");
			}
			
			if(!mainView.appConnected) {
			
			}
        }
    }
	
	Connections {
		target: txtStatus;
		onTextChanged: {
			if(txtStatus.text == "Complete") {
				btnUpgrade.disabled = true
				connection.sendMessage("MV")
				connection.sendMessage("MQ")
			}
			
			if(txtStatus.text == "Ready") {
				btnUpgrade.disabled = false
				btnDone.disabled = false
				connection.sendMessage("MV");
			}
			
			if(txtStatus.text == "Idle") {
				btnDone.text = "Done"
				btnDone.disabled = false
			}
		}
	}
	
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
        text: "ISP Upgrade"
        anchors.horizontalCenterOffset: 0
        horizontalAlignment: Text.AlignHCenter
        font.family: "DejaVu Sans"
        font.pixelSize: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }
	
	ImageButton {
        id: btnUpgrade
        x: 207
        y: 138
        width: 113
        height: 70
        text: "Upgrade"
        imageUp: "images/internal_button_up.bmp"
        font.pixelSize: 20
        textColor: "#000000"
        imageDown: "images/internal_button_dn.bmp"
        font.family: "DejaVu Sans"
		disabled: true
		
        onButtonClick: {
            console.debug("Run Upgrade")
			connection.sendMessage("MU");
			btnUpgrade.disabled = true
			btnDone.disabled = true
        }
    }
	
	ImageButton {
        id: btnDone
        x: 207
        y: 213
        width: 113
        height: 70
        text: "Cancel"
        imageUp: "images/internal_button_up.bmp"
        font.pixelSize: 20
        textColor: "#000000"
        imageDown: "images/internal_button_dn.bmp"
        font.family: "DejaVu Sans"
		disabled: true
		
        onButtonClick: {
			btnUpgrade.disabled = true
			if(btnDone.text == "Cancel" && txtStatus.text == "Ready") {
				btnDone.disabled = true
				connection.sendMessage("MQ")
			} else {
				console.debug("Done Upgrading]")
				system.execute("/etc/init.d/tio-agent start")
				system.execute("/etc/init.d/sio-agent start")
				root.message("appview.qml")
			}
        }
    }
	
    Text {
        id: text1
        x: 395
        y: 138
        width: 131
        height: 30
        text: qsTr("Version Information")
        font.family: "DejaVu Sans"
        font.pixelSize: 23
    }

    Text {
        id: text2
        x: 413
        y: 174
        width: 96
        height: 23
        text: qsTr("Micro: ")
        font.family: "DejaVu Sans"
        font.pixelSize: 18
    }

    TextInput {
        objectName: "micro_input"
        id: micro_input
        x: 521
        y: 174
        width: 75
        height: 23
        text: qsTr("?")
        font.family: "DejaVu Sans"
        font.pixelSize: 18
    }
	
	Text {
        id: text4
        x: 395
        y: 288
        text: qsTr("Status")
        font.family: "DejaVu Sans"
        font.pixelSize: 23
    }
	
	Text {
        id: txtStatus
		objectName: "txtStatus"
        x: 521
        y: 288
        text: qsTr("Waiting")
        font.family: "DejaVu Sans"
        font.pixelSize: 23
		font.bold: true
		color: "red"
    }
	
	Timer {
		id:timer1
		repeat: false
		interval: 2000
		
		onTriggered: {
			system.execute("/etc/init.d/isp-agent start")
		}
	}

	Component.onCompleted: {
		led_light1.on = mainView.appConnected
		timer1.start()
	}

}

