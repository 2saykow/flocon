// Diaporama affiché par l'installateur pendant la copie des fichiers.
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
               text: "<b>Bienvenue sur Flocon</b><br/>Un système simple, stable et entièrement décrit par sa configuration." }
    }

    Slide {
        Image { id: logo2; source: "flocon-logo.png"; width: 160; height: 160; fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent; anchors.verticalCenterOffset: -60 }
        Text { anchors.top: logo2.bottom; anchors.topMargin: 24; width: presentation.width; horizontalAlignment: Text.Center
               wrapMode: Text.WordWrap; font.pixelSize: 18
               text: "<b>Retour en arrière à tout moment</b><br/>Chaque mise à jour crée une nouvelle version du système ;<br/>en cas de problème, choisissez la précédente au démarrage." }
    }

    Slide {
        Image { id: logo3; source: "flocon-logo.png"; width: 160; height: 160; fillMode: Image.PreserveAspectFit
                anchors.centerIn: parent; anchors.verticalCenterOffset: -60 }
        Text { anchors.top: logo3.bottom; anchors.topMargin: 24; width: presentation.width; horizontalAlignment: Text.Center
               wrapMode: Text.WordWrap; font.pixelSize: 18
               text: "<b>Prêt à l'emploi</b><br/>Firefox, Thunderbird, LibreOffice et VLC sont déjà installés." }
    }

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }
}
