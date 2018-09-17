/*
 *   Copyright 2011 Marco Martin <mart@kde.org>
 *   Copyright 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#include "delegaterecycler.h"

#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>

class DelegateCache
{
public:
    DelegateCache();
    ~DelegateCache();

    void ref(QQmlComponent *);
    void deref(QQmlComponent *);

    void insert(QQmlComponent *, QQuickItem *);
    QQuickItem *take(QQmlComponent *);

private:
    static const int s_cacheSize = 40;
    QHash<QQmlComponent *, int> m_refs;
    QHash<QQmlComponent *, QList<QQuickItem *> > m_unusedItems;
};

Q_GLOBAL_STATIC(DelegateCache, s_delegateCache)

DelegateCache::DelegateCache()
{
}

DelegateCache::~DelegateCache()
{
    for (auto& item : qAsConst(m_unusedItems)) {
        qDeleteAll(item);
    }
}

void DelegateCache::ref(QQmlComponent *component)
{
    m_refs[component]++;
}

void DelegateCache::deref(QQmlComponent *component)
{
    auto itRef = m_refs.find(component);
    if (itRef == m_refs.end()) {
        return;
    }

    (*itRef)--;
    if (*itRef <= 0) {
        m_refs.erase(itRef);

        qDeleteAll(m_unusedItems.take(component));
    }
}

void DelegateCache::insert(QQmlComponent *component, QQuickItem *item)
{
    auto& items = m_unusedItems[component];
    if (items.length() >= s_cacheSize) {
        item->deleteLater();
        return;
    }

    item->setParentItem(nullptr);
    items.append(item);
}

QQuickItem *DelegateCache::take(QQmlComponent *component)
{
    auto it = m_unusedItems.find(component);
    if (it != m_unusedItems.end() && !it->isEmpty()) {
        return it->takeFirst();
    }
    return nullptr;
}





DelegateRecycler::DelegateRecycler(QQuickItem *parent)
    : QQuickItem(parent)
{
}

DelegateRecycler::~DelegateRecycler()
{
    if (m_sourceComponent) {
        s_delegateCache->insert(m_sourceComponent, m_item);
        s_delegateCache->deref(m_sourceComponent);
    }
}

void DelegateRecycler::syncIndex()
{
    const QVariant newIndex = m_propertiesTracker->property("trackedIndex");
    if (!newIndex.isValid()) {
        return;
    }
    QQmlContext *ctx = QQmlEngine::contextForObject(m_item)->parentContext();
    ctx->setContextProperty(QStringLiteral("index"), newIndex);
}

void DelegateRecycler::syncModel()
{
    const QVariant newModel = m_propertiesTracker->property("trackedModel");
    if (!newModel.isValid()) {
        return;
    }
    QQmlContext *ctx = QQmlEngine::contextForObject(m_item)->parentContext();
    ctx->setContextProperty(QStringLiteral("model"), newModel);
}

void DelegateRecycler::syncModelData()
{
    const QVariant newModelData = m_propertiesTracker->property("trackedModelData");
    if (!newModelData.isValid()) {
        return;
    }
    QQmlContext *ctx = QQmlEngine::contextForObject(m_item)->parentContext();
    ctx->setContextProperty(QStringLiteral("modelData"), newModelData);
}

QQmlComponent *DelegateRecycler::sourceComponent() const
{
    return m_sourceComponent;
}

void DelegateRecycler::setSourceComponent(QQmlComponent *component)
{
    if (component && component->parent() == this) {
        qWarning() << "Error: source components cannot be declared inside DelegateRecycler";
        return;
    }
    if (m_sourceComponent == component) {
        return;
    }

    if (!m_propertiesTracker) {
        QQmlComponent *propertiesTrackerComponent = new QQmlComponent(qmlEngine(this), this);

        propertiesTrackerComponent->setData(QByteArrayLiteral("import QtQuick 2.3\nQtObject{property int trackedIndex: index; property var trackedModel: typeof model != 'undefined' ? model : null; property var trackedModelData: typeof modelData != 'undefined' ? modelData : null}"), QUrl());
        m_propertiesTracker = propertiesTrackerComponent->create(QQmlEngine::contextForObject(this));

        connect(m_propertiesTracker, SIGNAL(trackedIndexChanged()), this, SLOT(syncIndex()));
        connect(m_propertiesTracker, SIGNAL(trackedModelChanged()), this, SLOT(syncModel()));
        connect(m_propertiesTracker, SIGNAL(trackedModelDataChanged()), this, SLOT(syncModelData()));
    }

    if (m_sourceComponent) {
        if (m_item) {
            disconnect(m_item.data(), &QQuickItem::implicitWidthChanged, this, &DelegateRecycler::updateHints);
            disconnect(m_item.data(), &QQuickItem::implicitHeightChanged, this, &DelegateRecycler::updateHints);
            s_delegateCache->insert(component, m_item);
        }
        s_delegateCache->deref(component);
    }

    m_sourceComponent = component;
    s_delegateCache->ref(component);

    m_item = s_delegateCache->take(component);

    if (!m_item) {
        QQuickItem *candidate = parentItem();
        QQmlContext *ctx = nullptr;
        while (candidate) {
            QQmlContext *parentCtx = QQmlEngine::contextForObject(candidate);
            if (parentCtx) {
                ctx = new QQmlContext(QQmlEngine::contextForObject(candidate), candidate);
                break;
            } else {
                candidate = candidate->parentItem();
            }
        }

        Q_ASSERT(ctx);

        if (QQmlEngine *eng = qmlEngine(this)) {
            //share context object in order to never lose track of global i18n()
            ctx->setContextObject(eng->rootContext()->contextObject());
        }
        ctx->setContextProperty(QStringLiteral("model"), m_propertiesTracker->property("trackedModel"));
        ctx->setContextProperty(QStringLiteral("modelData"), m_propertiesTracker->property("trackedModelData"));
        ctx->setContextProperty(QStringLiteral("index"), m_propertiesTracker->property("trackedIndex"));

        QObject * obj = component->create(ctx);
        m_item = qobject_cast<QQuickItem *>(obj);
        if (!m_item) {
            obj->deleteLater();
        } else {
            connect(m_item.data(), &QObject::destroyed, ctx, &QObject::deleteLater);
        }
    } else {
        QQmlContext *ctx = QQmlEngine::contextForObject(m_item)->parentContext();

        ctx->setContextProperty(QStringLiteral("model"), m_propertiesTracker->property("trackedModel"));
        ctx->setContextProperty(QStringLiteral("modelData"), m_propertiesTracker->property("trackedModelData"));
        ctx->setContextProperty(QStringLiteral("index"), m_propertiesTracker->property("trackedIndex"));
    }

    if (m_item) {
        m_item->setParentItem(this);
        connect(m_item.data(), &QQuickItem::implicitWidthChanged, this, &DelegateRecycler::updateHints);
        connect(m_item.data(), &QQuickItem::implicitHeightChanged, this, &DelegateRecycler::updateHints);
        updateSize(true);
    }

    emit sourceComponentChanged();
}

void DelegateRecycler::resetSourceComponent()
{
    s_delegateCache->deref(m_sourceComponent);
    m_sourceComponent = nullptr;
}

void DelegateRecycler::geometryChanged(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    if (m_item && newGeometry.size() != oldGeometry.size()) {
        updateSize(true);
    }
    QQuickItem::geometryChanged(newGeometry, oldGeometry);
}

void DelegateRecycler::updateHints()
{
    updateSize(false);
}

void DelegateRecycler::updateSize(bool parentResized)
{
    if (!m_item) {
        return;
    }

    const bool needToUpdateWidth = parentResized && widthValid();
    const bool needToUpdateHeight = parentResized && heightValid();

    if (parentResized) {
        m_item->setPosition(QPoint(0,0));
    }
    if (needToUpdateWidth && needToUpdateHeight) {
        m_item->setSize(QSizeF(width(), height()));
    } else if (needToUpdateWidth) {
        m_item->setWidth(width());
    } else if (needToUpdateHeight) {
        m_item->setHeight(height());
    }

    if (m_updatingSize) {
        return;
    }

    m_updatingSize = true;

    setImplicitSize(m_item->implicitWidth() >= 0 ? m_item->implicitWidth() : m_item->width(),
                    m_item->implicitHeight() >= 0 ? m_item->implicitHeight() : m_item->height());

    m_updatingSize = false;
}


#include <moc_delegaterecycler.cpp>
