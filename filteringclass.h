#ifndef FILTERINGCLASS_H
#define FILTERINGCLASS_H

#include <vector>
#include <algorithm>
#include <iostream>
#include "StructData.h"

class FilteringClass
{
public:
    FilteringClass();
    ~FilteringClass();

    void process(const std::vector<StructData>& data, double rcsThreshold, double distanceThreshold, double azimuthBearingThreshold);
    std::vector<Point> getCoordinates() const;

private:
    std::vector<Point> m_coordinates;

};

#endif // FILTERINGCLASS_H
