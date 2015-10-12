import QtQuick 2.0
import "components"
import com.reachtech.systemplugin 1.0

/* This page stays loaded for the entire session */
Rectangle {
    id: mainView
    width: 800
    height: 480
	color: "#2D2D2D"
	property bool appConnected: false
    
	Loader{
        id: loader
		source: ""
    }

	/* We wait for readyToSend before enabling the GUI */
	Connections {
        target: connection
        onReadyToSend: {
			appConnected = true;
			if(loader.source == "")
				loader.source = "appview.qml";
            txtMessage.visible = false;
        }
		onNotReadyToSend: {
			appConnected = false;
		}
    }
	
	/* Sub screens call this to load a different screen */
    Connections {
        target: loader.item
        onMessage: {
            loader.source = msg;            
        }
    }
	
	/* Welcome screen until we are readyToSend */
	Text {
        id: txtMessage
        anchors.centerIn:parent
        font.pixelSize: 32
        color: "Red"
        text: "Loading QML Application...Please Wait."
        visible: true
    }

	/* Any post load stuff can be done here */
	Component.onCompleted: {
	}

}

