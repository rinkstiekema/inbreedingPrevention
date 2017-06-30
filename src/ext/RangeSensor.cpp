#include "RangeSensor.h"


RangeSensor::RangeSensor(int id, double originDistance, double originAngle, double targetDistance, double targetAngle, double maxSensorDistance) {
    _id = id;
    _originDistance = originDistance;
    _originAngle = originAngle;
    _targetDistance = targetDistance;
    _targetAngle = targetAngle;
    _sensorRay.maxRange = maxSensorDistance;
}


void RangeSensor::update(double xReal, double yReal, double orientationAngle) {
        double sinOrigin, cosOrigin, sinTarget, cosTarget;
		sincos(_originAngle + orientationAngle, &sinOrigin, &cosOrigin);
		sincos(_targetAngle + orientationAngle, &sinTarget, &cosTarget);

		_sensorRay.x1 = xReal + _originDistance * cosOrigin;
		_sensorRay.y1 = yReal + _originDistance * sinOrigin;
		_sensorRay.x2 = xReal + _targetDistance * cosTarget;
		_sensorRay.y2 = yReal + _targetDistance * sinTarget;
}


void RangeSensor::cast(SDL_Surface* surface) {
    int ranges[50]; int pixels[50];    // (R<<16)+(G<<8)+B; R=objects, B=agents, G=pucks (if R==0xFF)

    int count = castSensorRay(surface, _sensorRay, ranges, pixels);

    // Clear puck ranges
    for (int i = 0; i < MAX_PUCK_COLORS; i++) _puckRanges[i] = _sensorRay.maxRange;
    // Last entry will always be about obstacle collision (or the lack thereof).
    for (int i = 0; i < count - 1; i++) {
        int g = (pixels[i] & 0x00FF00) >> 8;
        _puckRanges[g] = ranges[i];
    }
    _obstacleRange = ranges[count-1];
    _obstacleId = pixels[count-1];
}


double RangeSensor::getNormObstacleRange() {
    if (_obstacleRange == _sensorRay.maxRange) return 5.0;
    return 1.0 * _obstacleRange / _sensorRay.maxRange;
}

double RangeSensor::getNormPuckRange(int i) {
    if (_puckRanges[i] == _sensorRay.maxRange) return 5.0;
    return 1.0 * _puckRanges[i] / _sensorRay.maxRange;
}

