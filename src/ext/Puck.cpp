#include "World/Puck.h"

#include "RoboroboMain/roborobo.h"
#include "Utilities/SDL_gfxPrimitives.h"

#include "World/World.h"

const Uint32 Puck::PALETTE[] = {COLOR_STEEL_BLUE, COLOR_LIME_GREEN, COLOR_ORANGE_RED, COLOR_INDIGO, COLOR_SANDY_BROWN, COLOR_SEA_GREEN, COLOR_SIENNA, COLOR_SLATE_GRAY};

int Puck::_nextId = 0;

Puck::Puck(PuckGen* puckGen) {
    _id = _nextId++;
    _puckGen = puckGen;
    _colorId = puckGen->getId();
    _maxAge = puckGen->getMaxAge();
    _radius = puckGen->getRadius();
    _isInitialized = false;
}


Puck::~Puck() {
}


void Puck::step() {
    _age++;
    if ((_age == _maxAge) && (_maxAge != -1)) {
        _puckGen->replace(this);
    }
}


void Puck::replace() {_puckGen->replace(this);}

void Puck::replace(bool logging) {_puckGen->replace(this, logging);}

void Puck::fillEnvironment(Uint32 c, Uint32 color) {
    Sint16 xc = _xCenterPixel, yc = _yCenterPixel, r = _radius;
    int id;
    if (c < 0xFF) {
        c = SDL_MapRGB(gEnvironmentImage->format, 0xFF, c, 0x00);
        id = _id;
    } else {id = 0;}
    for (Sint16 xi = xc - r; xi < xc + r; xi++) {
        for (Sint16 yi = yc - r; yi < yc + r; yi++) {
            putPixel32(gEnvironmentImage, xi, yi, c);
            gPuckMap[xi][yi] = id;
        }
    }    
    if (!gBatchMode) {
        for (Sint16 xi = xc - r; xi < xc + r; xi++) {
            for (Sint16 yi = yc - r; yi < yc + r; yi++) {
                putPixel32(gForegroundImage, xi, yi, color);
            }
        }    
    }
}

bool Puck::testEnvironment() {
    Sint16 xc = _xCenterPixel, yc = _yCenterPixel, r = _radius;
    for (Sint16 xi = xc - r; xi < xc + r; xi++) {
        for (Sint16 yi = yc - r; yi < yc + r; yi++) {
            if (getPixel32(gEnvironmentImage, xi, yi) != COLOR_WHITE) {
                return false;
            }
        }
    }
    return true;
}

void Puck::setCoords(Sint16 x, Sint16 y) {
    _xCenterPixel = x;
    _yCenterPixel = y;
}

void Puck::setColor(Uint8 id, Uint32 color) {
    _puckColor = color;
    _colorId = id;
}

void Puck::setEnergy(double energy) {
    _energyPointValue = energy;
}

