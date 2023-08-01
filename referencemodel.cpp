#include "referencemodel.h"

ReferenceModel::ReferenceModel(QObject *parent)
    : QSqlTableModel{parent}
{

}
QHash<int, QByteArray> ReferenceModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[Latitude]       = "latitude";
    roles[Longitude]      = "longitude";
    roles[ReaLatitude]    = "reaLatitude";
    roles[ReaLongitude]   = "reaLongitude";
    roles[Zoom]           = "zoom";
    roles[Name]           = "name";

    return roles;
}

void ReferenceModel::updateModel()
{
    this->setTable(REFERENCE_TABLE);
    this->select();
}

QVariant ReferenceModel::data(const QModelIndex &index, int role) const
{
    if (index.isValid()) {
        if (role == Qt::EditRole) return QSqlTableModel::data(index,role);
        if (role > Qt::UserRole) {
            int columnId = role - Qt::UserRole - 1;
            QModelIndex modelIndex = this->index(index.row(), columnId);

            return QSqlTableModel::data(modelIndex, Qt::DisplayRole);
        }
    }

    return QVariant();
}
