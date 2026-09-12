import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Page {
    width: parent.width
    height: parent.height

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.smallSpacing

        Column {
            Layout.fillWidth: true

            Text {
                text: qsTr("Need to connect to the internet first? Press <b>Super+I</b> (the Windows key + I) to open the network connection editor, then continue once you're online.")
                width: parent.width
                wrapMode: Text.WordWrap
            }
        }
    }
}
