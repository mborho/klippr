#include <QObject>
#include <QNetworkReply>
#include <QNetworkAccessManager>

#ifndef KIPPTCONNECTOR_H
#define KIPPTCONNECTOR_H


class KipptConnector : public QObject
{
    Q_OBJECT

public:
    KipptConnector(QObject *parent = 0);

    Q_INVOKABLE QString deleteCall(QString ressource, QString sURL, QByteArray username, QByteArray apiToken);

signals:

     void clipDeleted(QVariant statusCode);
     void listDeleted(QVariant statusCode);

private slots:

    void deletedClip(QNetworkReply* apiReply);
    void deletedList(QNetworkReply* apiReply);

private:

    QNetworkAccessManager m_NetCtrl;

};

#endif // KIPPTCONNECTOR_H
