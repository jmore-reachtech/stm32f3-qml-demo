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
	
	/* The mainview is listening for readyToSend signals. Watch that 
		that property to make sure we are still connected */
	Connections {
        target: mainView
        onAppConnectedChanged: {
			led_light1.on = mainView.appConnected
			
			/* When this screen is loaded the previous connection (TIO Agent) 
				is terminated and the ISP Agent is loaded. Once the ISP Agent 
				loads we get notified here and we can send the (M)icro (S)tart 
				message. */
			if(mainView.appConnected) {
				connection.sendMessage("MS");
			}
			
			if(!mainView.appConnected) {
			
			}
        }
    }
	
	/* We need to watch the Status text to know what is happening. The Status text 
		is set by the ISP Agent
	*/
	Connections {
		target: txtStatus;
		onTextChanged: {
			/* After the upgrade is complete the ISP sets our status 
			to Complete. Ask the ISP Agent for the (M)icro (V)ersion and then
			send the (M)icro (Q)uit message. The upgrade is done at this point */
			if(txtStatus.text == "Complete") {
				btnUpgrade.disabled = true
				connection.sendMessage("MV")
				connection.sendMessage("MQ")
			}
			
			/* When the ISP Agent is ready to accept commands the Status 
			is set to Ready. We ask for the (M)icro (V)ersion and enable the 
			Upgrade and Cancel buttons */
			if(txtStatus.text == "Ready") {
				btnUpgrade.disabled = false
				btnDone.disabled = false
				connection.sendMessage("MV");
			}
			/* After we send the (M)icro (Q)uit message above the ISP Agent sets our 
			status to Idle, indicating the ISP is no longer accepting messages. 
			Enable the Done button so we can return to the appview screen */
			if(txtStatus.text == "Idle") {
				btnDone.text = "Done"
				btnDone.disabled = false
			}
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
        text: "ISP Upgrade"
        anchors.horizontalCenterOffset: 0
        horizontalAlignment: Text.AlignHCenter
        font.family: "DejaVu Sans"
        font.pixelSize: 30
        anchors.horizontalCenter: parent.horizontalCenter
    }
	
	/* Send the (M)icro (U)pdate message to start the upgrade */
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
		
		/* Disable all buttons during the update */
        onButtonClick: {
            console.debug("Run Upgrade")
			connection.sendMessage("MU");
			btnUpgrade.disabled = true
			btnDone.disabled = true
        }
    }
	
	/* This button handles both Cancel and Done */
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
			/* We decided to not upgrade, send the (M)icro (Q)uit message */
			if(btnDone.text == "Cancel" && txtStatus.text == "Ready") {
				btnDone.disabled = true
				connection.sendMessage("MQ")
			} else {
				/*The upgrade is complete. Restart the TIO and SIO agents and 
				go to the appview screen */
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
		/* This objectName is how the ISP agent finds the version input field */
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
		/* This objectName is how the ISP agent finds the status input field */
		objectName: "txtStatus"
        x: 521
        y: 288
        text: qsTr("Waiting")
        font.family: "DejaVu Sans"
        font.pixelSize: 23
		font.bold: true
		color: "red"
    }
	
	/* We use a timer here since we need to delay in order to give the SIO and TIO 
	agents time to cleanly shut down before we bring up the ISP Agent */
	Timer {
		id:timer1
		repeat: false
		interval: 2000
		
		onTriggered: {
			system.execute("/etc/init.d/isp-agent start")
		}
	}

	/* After the screen loads set the visual indicator and start a timer */
	Component.onCompleted: {
		led_light1.on = mainView.appConnected
		timer1.start()
	}

}

