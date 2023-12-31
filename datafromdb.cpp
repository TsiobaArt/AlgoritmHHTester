#include "datafromdb.h"

DataFromDB::DataFromDB(QObject *parent) : QObject(parent) {
    m_db = QSqlDatabase::addDatabase("QSQLITE");
    m_db.setDatabaseName(_dbName);

    if (!m_db.open()) {
        qDebug() << "Error: connection with database fail";
    } else {
        qDebug() << "Database: connection ok";
    }
}

void DataFromDB::loadData(const QString &table, const double rcsRange, const double signalStrengthRange) {
    //    int id = 3;
    QSqlQuery query(m_db);
    query.prepare("SELECT data FROM " + table /*+ " WHERE id = 2"*/);

    if (!query.exec()) {
        qDebug() << "Error: could not execute query -" << query.lastError().text();
        return;
    }

    while (query.next()) {
        QString jsonData = query.value(0).toString();
        QJsonArray jsonArray = QJsonDocument::fromJson(jsonData.toUtf8()).array();
        m_coordinates.clear();
        _allDataDb.clear();
        for (const QJsonValue& value : qAsConst(jsonArray)) {
            QJsonObject jsonObject = value.toObject();
            // Отримати значення вкладених полів
            //            int bearing = jsonObject.value("bearing").toInt();
            //            double headAngle = jsonObject.value("headAngle").toDouble();
            // Розпарсити масив "list" в вектор об'єктів StructData
            QVector<StructData> dataList;
            QJsonArray listArray = jsonObject.value("list").toArray();
            for (const QJsonValue& itemValue : qAsConst(listArray)) {
                QJsonObject item = itemValue.toObject();

                // Отримати значення полів об'єкта "list"
                //                double azimuthBearing = item.value("AzimuthBearing").toDouble();
                double signalStrength = item.value("SignalStrength").toDouble();
                double latitude =  item.value("latitude").toDouble();
                double rcsFilter = item.value("Rcs").toDouble();
                double longitude = item.value("longitude").toDouble();
                double distance = item.value("Distance").toDouble();
                double azimuthBearing = item.value("AzimuthBearing").toDouble();
                // Створити об'єкт StructData та додати його до вектора
                StructData data;

                data.latitude  = latitude;
                data.longitude = longitude;
                data.Rcs       = rcsFilter;
                data.Distance  = distance;
                data.AzimuthBearing = azimuthBearing;

                dataList.append(data);
                Point point;
                point.lat = latitude;
                point.lon = longitude;

                //                m_coordinates.push_back(point);
                if (rcsFilter >= rcsRange && signalStrength >= signalStrengthRange) {
                    m_coordinates.push_back(point);
                    _allDataDb.push_back(data);
                }
            }
        }
    }
}



std::vector<Point> DataFromDB::getCoordinates() const {
    return m_coordinates;
}

std::vector<StructData> DataFromDB::getAllData() const {
    return _allDataDb;
}

void DataFromDB::processingData(const double rcs, const double distance, const double azimuthBearning)
{


    m_coordinates.clear();
    qDebug() << "distance " << distance;
    std::vector<std::vector<StructData>> clusters;
    std::sort(_allDataDb.begin(), _allDataDb.end(), [](const StructData& a, const StructData& b) {
          return a.Distance < b.Distance;
      });
//    for (const auto& data : _allDataDb) {
//        std::cout  << ", Distance: " << data.Distance;
//    }
    for (const auto& data : _allDataDb) {
           if (clusters.empty() ||
               (data.Distance - clusters.back().back().Distance) > distance) {
               // Якщо clusters порожній або остання дистанція в останньому кластері відрізняється
               // від поточної дистанції більше, ніж на порогове значення, додаємо новий кластер
               clusters.push_back({data});
           } else {
               // В іншому випадку додаємо дані до останнього кластеру
               clusters.back().push_back(data);
           }
       }

//       for (const auto& cluster : clusters) {
//           std::cout << "Cluster start distance: " << cluster.front().Distance
//                     << ", end distance: " << cluster.back().Distance << '\n';
//       }


       // ---------------------------------------------------------------
       for (const auto& cluster : clusters) {
               double sumLat = 0.0, sumLon = 0.0;
               int count = 0;
               std::vector<StructData> exceedsThreshold;

               for (const auto& data1 : cluster) {
                   bool withinThreshold = true;
                   for (const auto& data2 : cluster) {
                       if (std::abs(data1.AzimuthBearing - data2.AzimuthBearing) > azimuthBearning) {
                           withinThreshold = false;
                           break;
                       }
                   }

                   if (withinThreshold) {
                       // Усі відмінності всередині кластера знаходяться в межах порога, додати до розрахунку центроїда
                       sumLat += data1.latitude;
                       sumLon += data1.longitude;
                       count++;
                   } else {
                       // Точка має принаймні одну різницю, яка перевищує порогове значення, за винятком для подальшої обробки
                       exceedsThreshold.push_back(data1);
                   }
               }

               if (count > 0) {
                   // порахувати центрої там де похибка одинакова
                   Point centroid;
                   centroid.lat = sumLat / count;
                   centroid.lon = sumLon / count;
                   m_coordinates.push_back(centroid);
               }

               // додати точки там які не прошли первірку на  позибки
               for (const auto& data : exceedsThreshold) {
                   Point point;
                   point.lat = data.latitude;
                   point.lon = data.longitude;
                   m_coordinates.push_back(point);
               }
           }
       // ---------------------------------------------------------------
}



