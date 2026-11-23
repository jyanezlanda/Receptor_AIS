QT += widgets network serialport

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    aisdecoder.cpp \
    aistypes.cpp \
    connectionmanager.cpp \
    connectionpage.cpp \
    demosimulator.cpp \
    main.cpp \
    mainwindow.cpp \
    mappage.cpp \
    mapwidget.cpp \
    receiverlink.cpp \
    sshpage.cpp \
    sshsession.cpp \
    vesseldetailpanel.cpp \
    vesselmodel.cpp \
    ais_frame/ais_frame.c

HEADERS += \
    aisdecoder.h \
    aistypes.h \
    connectionmanager.h \
    connectionpage.h \
    demosimulator.h \
    mainwindow.h \
    mappage.h \
    mapwidget.h \
    receiverlink.h \
    sshpage.h \
    sshsession.h \
    vesseldetailpanel.h \
    vesselmodel.h \
    ais_frame/ais_frame.h

FORMS += \
    connectionpage.ui \
    mainwindow.ui \
    mappage.ui \
    sshpage.ui \
    vesseldetailpanel.ui

OTHER_FILES += \
    simulacion/generar_ais.py \
    simulacion/ais_sim.sh \
    simulacion/rp_falso.py

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target
