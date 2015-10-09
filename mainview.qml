import QtQuick 2.0
import "components"
import com.reachtech.systemplugin 1.0

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
	
    Connections {
        target: loader.item
        onMessage: {
            loader.source = msg;            
        }
    }
	
	Text {
        id: txtMessage
        anchors.centerIn:parent
        font.pixelSize: 32
        color: "Red"
        text: "Loading QML Application...Please Wait."
        visible: true
    }

	Component.onCompleted: {
	}

}

