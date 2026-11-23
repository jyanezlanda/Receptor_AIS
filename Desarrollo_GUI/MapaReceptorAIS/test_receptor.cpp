// Prueba del formato "Receptor Red Pitaya" sin interfaz grafica: usa las mismas clases que la aplicacion (ConnectionManager,
// ReceiverLink, AisDecoder, VesselModel) contra un servidor de datos (simulacion/rp_falso.py o el adc_server).
// Uso:  test_receptor HOST PUERTO SEGUNDOS [reconectar]      Escribe en la salida estandar un JSON con los estados, los contadores y los buques.
#include "aisdecoder.h"
#include "connectionmanager.h"
#include "vesselmodel.h"

#include <QCoreApplication>
#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>
#include <cstdio>

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);
    if (argc < 4) {
        std::fprintf(stderr, "uso: %s HOST PUERTO SEGUNDOS [reconectar]\n", argv[0]);
        return 2;
    }
    ConnectionManager manager;
    AisDecoder decoder;
    VesselModel model;
    QJsonArray states;
    quint64 words = 0;
    quint32 lastLevel = 0;
    bool seenOpen = false;

    QObject::connect(&manager, &ConnectionManager::wordsReceived, &decoder, &AisDecoder::feedWords);
    QObject::connect(&manager, &ConnectionManager::wordsReceived, [&](const QVector<quint32> &w) { words += quint64(w.size()); });
    QObject::connect(&manager, &ConnectionManager::receiverStatus, [&](quint32 level, bool open, quint32) { lastLevel = level; seenOpen = seenOpen || open; });
    QObject::connect(&decoder, &AisDecoder::vesselDecoded, &model, &VesselModel::upsert);
    QObject::connect(&manager, &ConnectionManager::stateChanged, [&](ConnectionManager::State s, const QString &message) {
        states.append(QJsonObject{{"estado", ConnectionManager::stateText(s)}, {"mensaje", message}});
        if (s == ConnectionManager::State::Connecting)
            decoder.reset();
    });

    ConnectionConfig c;
    c.interface = ConnectionConfig::Interface::Ethernet;
    c.dataFormat = ConnectionConfig::DataFormat::Receiver;
    c.protocol = ConnectionConfig::Protocol::Tcp;
    c.role = ConnectionConfig::Role::Client;
    c.host = QString::fromLocal8Bit(argv[1]);
    c.port = quint16(QString::fromLocal8Bit(argv[2]).toUInt());
    c.timeoutMs = 3000;
    c.autoReconnect = argc > 4 && QString::fromLocal8Bit(argv[4]) == QLatin1String("1");
    manager.open(c);
    QTimer::singleShot(int(QString::fromLocal8Bit(argv[3]).toDouble() * 1000), &app, &QCoreApplication::quit);
    app.exec();

    const AisDecoder::Stats &st = decoder.stats();
    QJsonArray vessels;
    for (const Vessel &v : model.vessels())
        vessels.append(QJsonObject{{"mmsi", double(v.mmsi)}, {"nombre", v.name}, {"destino", v.destination}, {"indicativo", v.callsign}, {"tipo", v.shipType},
                                   {"lat", std::isnan(v.lat) ? QJsonValue() : QJsonValue(v.lat)}, {"lon", std::isnan(v.lon) ? QJsonValue() : QJsonValue(v.lon)},
                                   {"eslora", v.length}, {"mensajes", int(v.msgCount)}});
    const QJsonObject stats{{"palabras", double(words)}, {"mensajes", double(st.messages)}, {"bits", double(st.rxBits)}, {"candidatas", double(st.rxCandidates)}, {"fcs_malo", double(st.rxBadFcs)},
                            {"descartadas", double(st.rxDiscarded)}, {"abortadas", double(st.rxAborted)}, {"tramas", double(st.rxFrames)}, {"nivel", double(lastLevel)}, {"squelch_visto_abierto", seenOpen}};
    std::printf("%s\n", QJsonDocument(QJsonObject{{"estados", states}, {"stats", stats}, {"buques", vessels}}).toJson(QJsonDocument::Compact).constData());
    manager.close();
    return 0;
}
