#include "sharehelper.h"

#include <QString>
#include <QDebug>
#ifndef QT_SIMULATOR
#include <maemo-meegotouch-interfaces/shareuiinterface.h>
#include <MDataUri>
#endif

ShareHelper::ShareHelper(QObject *parent) : QObject(parent) { }

void ShareHelper::shareLink (const QString &link, const QString &title) {

//    qDebug() << "Make data URI from"
//             << link << title;

#ifndef QT_SIMULATOR
    MDataUri duri;

    duri.setMimeType ("text/x-url");
    duri.setTextData (link);
    duri.setAttribute ("title", title);

    if (duri.isValid() == false) {
        qCritical() << "Invalid URI";
        return;
    }

    QStringList items;
    items << duri.toString();
    // qDebug() << "URI:" << items.join (" ");

    // Create a interface object
    ShareUiInterface shareIf("com.nokia.ShareUi");

    // Check if interface is valid
    if (shareIf.isValid()) {
        // Start ShareUI application with selected files.
        // qDebug() << "Signalling share-ui daemon...";
        shareIf.share (items);
    } else {
        qCritical() << "Invalid interface";
        return;
    }
#else
    Q_UNUSED(title)
    Q_UNUSED(link)
#endif
}
