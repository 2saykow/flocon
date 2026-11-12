// Slideshow shown by the installer while files are being copied.
import QtQuick 2.0;
import calamares.slideshow 1.0;

Presentation {
    id: presentation

    Timer {
        interval: 15000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Image { id: logo1; source: "flocon-logo.png"; width: 160; height: 160; fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent; anchors.verticalCenterOffset: -60 }
        Text { anchors.top: logo1.bottom; anchors.topMargin: 24; width: presentation.width; horizontalAlignment: Text.Center
               wrapMode: Text.WordWrap; font.pixelSize: 18
               text: "<b>Welcome to Flocon</b><br/>A simple, stable system, fully described by its configuration." }
    }

    Slide {
        Image { id: logo2; source: "flocon-logo.png"; width: 160; height: 160; fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent; anchors.verticalCenterOffset: -60 }
        Text { anchors.top: logo2.bottom; anchors.topMargin: 24; width: presentation.width; horizontalAlignment: Text.Center
               wrapMode: Text.WordWrap; font.pixelSize: 18
               text: "<b>Roll back at any time</b><br/>Every update creates a new version of the system;<br/>if something goes wrong, pick the previous one at boot." }
    }

    Slide {
        Image { id: logo3; source: "flocon-logo.png"; width: 160; height: 160; fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent; anchors.verticalCenterOffset: -60 }
        Text { anchors.top: logo3.bottom; anchors.topMargin: 24; width: presentation.width; horizontalAlignment: Text.Center
               wrapMode: Text.WordWrap; font.pixelSize: 18
               text: "<b>Ready to use</b><br/>Firefox, Thunderbird, LibreOffice and VLC are already installed." }
    }

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }
}
