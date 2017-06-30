#ifndef PUCK_H
#define PUCK_H

#include "RoboroboMain/common.h"
#include "World/PuckGen.h"

/*
Puck belongs to some distribution, which assigns coordinates and colors.
*/

class PuckGen;

class Puck {
    private :
        static int _nextId; int _id;
        Sint16 _xCenterPixel; Sint16 _yCenterPixel;
        Sint16 _radius;
        double _energyPointValue;                          // Energy value measured in pucks.
        int _age; int _maxAge;
        Uint32 _puckColor; Uint8 _colorId;
        PuckGen* _puckGen;
        
    public :
        bool _isInitialized;
        Puck(PuckGen* puckGen);
        ~Puck();
        void step();
        void fillEnvironment(Uint32 c, Uint32 color);
        bool testEnvironment();

        void replace();
        void replace(bool logging);
        inline void drop() {_age = rand() % _maxAge; fillEnvironment(_colorId, _puckColor);}
        inline void take() {fillEnvironment(COLOR_WHITE, COLOR_WHITE);}
        
        inline void recolor(Uint8 id, Uint32 color) {_colorId = id; _puckColor = color; fillEnvironment(_colorId, _puckColor);}
        
        void setCoords(Sint16 x, Sint16 y);
        void setColor(Uint8 id, Uint32 color);
        void setEnergy(double energy);
        
        void getCoords(Sint16& x, Sint16& y) {
        	x = _xCenterPixel;
        	y = _yCenterPixel;
        }
        void getColorId(Uint8& id) {
        	id = _colorId;
        }
        
        static const Uint32 COLOR_WHITE = 0xFFFFFF;
        
        static const Uint32 COLOR_STEEL_BLUE     = 0x4682B4; // 0 
        static const Uint32 COLOR_LIME_GREEN     = 0x32CD32; // 1
        static const Uint32 COLOR_ORANGE_RED     = 0xFF4500; // 2
        static const Uint32 COLOR_INDIGO         = 0x4B0082; // 3
        static const Uint32 COLOR_SANDY_BROWN    = 0xF4A460; // 4   
        static const Uint32 COLOR_SEA_GREEN      = 0x2E8B57; // 5
        static const Uint32 COLOR_SIENNA         = 0xA0522D; // 6
        static const Uint32 COLOR_SLATE_GRAY     = 0x708090; // 7
        
        static const Uint32 PALETTE[];
};

#endif
