TEMPLATE = lib
CONFIG +=  plugin

QT          += qml quick gui quickcontrols2 svg concurrent
URI = org.kde.kirigami
QMAKE_MOC_OPTIONS += -Muri=org.kde.kirigami
HEADERS     += $$PWD/src/kirigamiplugin.h \
               $$PWD/src/enums.h \
               $$PWD/src/settings.h \
               $$PWD/src/columnview_p.h \
               $$PWD/src/columnview.h \
               $$PWD/src/formlayoutattached.h \
               $$PWD/src/mnemonicattached.h \
               $$PWD/src/scenepositionattached.h \
               $$PWD/src/libkirigami/basictheme_p.h \
               $$PWD/src/libkirigami/platformtheme.h \
               $$PWD/src/libkirigami/kirigamipluginfactory.h \
               $$PWD/src/libkirigami/tabletmodewatcher.h \
#               $$PWD/src/desktopicon.h \
               $$PWD/src/delegaterecycler.h \
    src/colorutils.h \
    src/icon.h \
    src/kirigami2_export.h \
    src/pagepool.h \
    src/scenegraph/paintedrectangleitem.h \
    src/scenegraph/shadowedborderrectanglematerial.h \
    src/scenegraph/shadowedbordertexturematerial.h \
    src/scenegraph/shadowedrectanglematerial.h \
    src/scenegraph/shadowedrectanglenode.h \
    src/scenegraph/shadowedtexturematerial.h \
    src/scenegraph/shadowedtexturenode.h \
    src/shadowedrectangle.h \
    src/shadowedtexture.h \
    src/wheelhandler.h
SOURCES     += $$PWD/src/kirigamiplugin.cpp \
               $$PWD/src/enums.cpp \
               $$PWD/src/settings.cpp \
               $$PWD/src/columnview.cpp \
               $$PWD/src/formlayoutattached.cpp \
               $$PWD/src/mnemonicattached.cpp \
               $$PWD/src/scenepositionattached.cpp \
               $$PWD/src/libkirigami/basictheme.cpp \
               $$PWD/src/libkirigami/platformtheme.cpp \
               $$PWD/src/libkirigami/kirigamipluginfactory.cpp \
               $$PWD/src/libkirigami/tabletmodewatcher.cpp \
#               $$PWD/src/desktopicon.cpp \
               $$PWD/src/delegaterecycler.cpp \
    src/colorutils.cpp \
    src/icon.cpp \
    src/pagepool.cpp \
    src/scenegraph/paintedrectangleitem.cpp \
    src/scenegraph/shadowedborderrectanglematerial.cpp \
    src/scenegraph/shadowedbordertexturematerial.cpp \
    src/scenegraph/shadowedrectanglematerial.cpp \
    src/scenegraph/shadowedrectanglenode.cpp \
    src/scenegraph/shadowedtexturematerial.cpp \
    src/scenegraph/shadowedtexturenode.cpp \
    src/shadowedrectangle.cpp \
    src/shadowedtexture.cpp \
    src/wheelhandler.cpp
RESOURCES   += $$PWD/kirigami.qrc \
    src/scenegraph/shaders/shaders.qrc


DEFINES     -= KIRIGAMI_BUILD_TYPE_STATIC

DEFINES += IS_KIRIGAMI2_EXPORT

API_VER=1.0

TARGET = $$qtLibraryTarget(org/kde/kirigami.2/kirigamiplugin)

importPath = $$[QT_INSTALL_QML]/org/kde/kirigami.2
target.path = $${importPath}

controls.path = $${importPath}
controls.files += $$PWD/src/controls/*

#For now ignore Desktop and Plasma stuff in qmake
styles.path = $${importPath}/styles
styles.files += $$PWD/src/styles/*

INSTALLS    += target controls styles

DISTFILES += \
    src/scenegraph/shaders/header_desktop.glsl \
    src/scenegraph/shaders/header_desktop_core.glsl \
    src/scenegraph/shaders/header_es.glsl \
    src/scenegraph/shaders/sdf.glsl \
    src/scenegraph/shaders/shadowedborderrectangle.frag \
    src/scenegraph/shaders/shadowedbordertexture.frag \
    src/scenegraph/shaders/shadowedrectangle.frag \
    src/scenegraph/shaders/shadowedrectangle.vert \
    src/scenegraph/shaders/shadowedtexture.frag






