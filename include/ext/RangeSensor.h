
#ifndef RANGESENSOR_H
#define RANGESENSOR_H

#include "RoboroboMain/common.h"
#include "Utilities/SDL_gfxPrimitivesExtra.h"

struct SensorRay;

class RangeSensor {
    public:
        /* Sensor id. I don't believe it's used anywhere.*/
        int _id;

        /* Sensor ray goes from origin to target -- angles and distances to those aroe measured from the center of the agent */
        double _originDistance;
        double _originAngle;
        double _targetDistance;
        double _targetAngle;

        // Colors are numbered from 0 to 15 -- green component corresponds to index (hate to rephrase certain celibrity, but 16 colors should be enough).
        static const int MAX_PUCK_COLORS = 16;
        int _puckRanges[MAX_PUCK_COLORS];
        int _obstacleRange;
        int _obstacleId;

        // x1, y1, x2, y2 and maxRange.
        SensorRay _sensorRay;

        void update(double xReal, double yReal, double agentHeading);

        RangeSensor(int id, double originDistance, double originAngle, double targetDistance, double targetAngle, double maxSensorDistance);
        void cast(SDL_Surface* surface);

        void getOldSensorData(double* sensorData) {
            sensorData[0] = (double)_id;
            sensorData[1] = _originDistance;
            sensorData[2] = _originAngle;
            sensorData[3] = _targetDistance;
            sensorData[4] = _targetAngle;
            /* Range to obstacle [5] and obstacle id [6] are updated elsewhere. */
        }

        double getNormObstacleRange();
        double getNormPuckRange(int i);
};


#endif
