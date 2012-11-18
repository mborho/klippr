#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"
#include <QDeclarativeContext>
#include "kipptconnector.h"
#include "sharehelper.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    QmlApplicationViewer viewer;
    QDeclarativeContext *ctxt = viewer.rootContext();

    KipptConnector *connector = new KipptConnector();
    ctxt->setContextProperty("KipptConnector", connector);    

    ShareHelper sh;
    ctxt->setContextProperty("Share", &sh);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/klippr/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
