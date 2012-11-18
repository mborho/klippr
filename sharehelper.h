#ifndef SHAREHELPER_H
#define SHAREHELPER_H

#include <QObject>

class ShareHelper: public QObject
{
    Q_OBJECT
public:
    explicit ShareHelper(QObject *parent = 0);

signals:

public slots:

    void shareLink(const QString &link, const QString &title = QString());
};



#endif // SHAREHELPER_H
