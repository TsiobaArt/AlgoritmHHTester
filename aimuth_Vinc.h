#ifndef AIMUTH_VINC_H
#define AIMUTH_VINC_H
#include <cmath>
#include <tuple>

#include <cmath>

const double a = 6378137.0; // Більша піввісь WGS84 еліпсоїда (метри)
const double b = 6356752.3142; // Менша піввісь WGS84 еліпсоїда (метри)
const double f = 1.0 / 298.257223563; // Стиснутість WGS84 еліпсоїда

double toRadians(double angleDegrees) {
    return angleDegrees * M_PI / 180.0;
}

double ellipsoidal_azimuth(double lat1, double lon1, double lat2, double lon2) {
    double lat1_rad = toRadians(lat1);
    double lon1_rad = toRadians(lon1);
    double lat2_rad = toRadians(lat2);
    double lon2_rad = toRadians(lon2);

    double L = lon2_rad - lon1_rad;
    double tanU1 = (1 - f) * std::tan(lat1_rad);
    double cosU1 = 1 / std::sqrt((1 + tanU1 * tanU1));
    double sinU1 = tanU1 * cosU1;
    double tanU2 = (1 - f) * std::tan(lat2_rad);
    double cosU2 = 1 / std::sqrt((1 + tanU2 * tanU2));
    double sinU2 = tanU2 * cosU2;

    double lambda = L;
    double lambda_prev;
    double sinLambda, cosLambda, sinSigma, cosSigma, cosSqAlpha, cos2SigmaM, C;




    for (int i = 0; i < 100; ++i) {
        sinLambda = std::sin(lambda);
        cosLambda = std::cos(lambda);
        sinSigma = std::sqrt((cosU2 * sinLambda) * (cosU2 * sinLambda) + (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda) * (cosU1 * sinU2 - sinU1 * cosU2 * cosLambda));
        cosSigma = sinU1 * sinU2 + cosU1 * cosU2 * cosLambda;
        double sigma = std::atan2(sinSigma, cosSigma);
        double sinAlpha = cosU1 * cosU2 * sinLambda / sinSigma;
        cosSqAlpha = 1 - sinAlpha * sinAlpha;
        cos2SigmaM = cosSigma - 2 * sinU1 * sinU2 / cosSqAlpha;

        double uSq = cosSqAlpha * (a * a - b * b) / (b * b);
        C = f / 16 * cosSqAlpha * (4 + f * (4 - 3 * cosSqAlpha));
        lambda_prev = lambda;

        lambda = L + (1 - C) * f * sinAlpha * (sigma + C * sinSigma * (cos2SigmaM + C * cosSigma * (-1 + 2 * cos2SigmaM * cos2SigmaM)));
        if (std::abs(lambda - lambda_prev) < 5.0e-15) { // точнічть
            break;
        }
    }

    double fwd_azimuth_rad = std::atan2(cosU2 * sinLambda, cosU1 * sinU2 - sinU1 * cosU2 * cosLambda);
    double fwd_azimuth_deg = fwd_azimuth_rad * 180.0 / M_PI;
    if (fwd_azimuth_deg < 0.0) {
        fwd_azimuth_deg += 360.0;
    }
    return fwd_azimuth_deg;
}

#endif // AIMUTH_VINC_H
