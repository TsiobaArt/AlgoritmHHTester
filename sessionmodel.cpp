#include "sessionmodel.h"

SessionModel::SessionModel(QObject *parent)
    :QSqlTableModel(parent)
{
    this->updateModel();

}

QHash<int, QByteArray> SessionModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    roles[IdRole]                = ID;
    roles[DateRole]              = DATE;
    roles[TableNameRole]         = TABLE_NAME;
    roles[SessionNameRole]       = SESSION_NAME;
    roles[NotesRole]             = NOTES;

    return roles;
}

void SessionModel::updateModel()
{
    this->setTable(INFO_TABLE);
    this->select();
}

QVariant SessionModel::data(const QModelIndex &index, int role) const
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

