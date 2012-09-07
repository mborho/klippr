#include "kipptconnector.h"
#include <QObject>
#include <QString>
#include <QNetworkAccessManager>
#include <QNetworkRequest>
#include <QNetworkReply>
#include <QSignalMapper>

KipptConnector::KipptConnector(QObject *parent) : QObject(parent)
{
}

QString KipptConnector::deleteCall(QString ressource,QString path, QByteArray username, QByteArray apiToken  )
{

    QNetworkRequest request;
    request.setUrl(QUrl(path));
    request.setRawHeader("X-Kippt-Client", "Klippr for Meego");
    request.setRawHeader("X-Kippt-Username", username);
    request.setRawHeader("X-Kippt-API-Token", apiToken);

    m_NetCtrl.deleteResource(request);

    if(ressource == "clip") {
        connect(&m_NetCtrl, SIGNAL(finished(QNetworkReply*)), SLOT(deletedClip(QNetworkReply*)));
    } else if(ressource == "list") {
        connect(&m_NetCtrl, SIGNAL(finished(QNetworkReply*)), SLOT(deletedList(QNetworkReply*)));
    }

    return path;
}

void KipptConnector::deletedClip(QNetworkReply* apiReply)
{
    QVariant statusCode = apiReply->attribute( QNetworkRequest::HttpStatusCodeAttribute );
    emit clipDeleted(statusCode);
}

void KipptConnector::deletedList(QNetworkReply* apiReply)
{
    QVariant statusCode = apiReply->attribute( QNetworkRequest::HttpStatusCodeAttribute );
    emit listDeleted(statusCode);
}
