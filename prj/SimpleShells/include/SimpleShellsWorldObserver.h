#ifndef SIMPLESHELLSWORLDOBSERVER_H
#define SIMPLESHELLSWORLDOBSERVER_H

#include "RoboroboMain/common.h"
#include "RoboroboMain/roborobo.h"

#include "Observers/WorldObserver.h"
#include "Utilities/Timer.h"

#include <ios>
#include <iostream>

class World;

class SimpleShellsWorldObserver : public WorldObserver
{
	private:
		Timer *timer;
	protected:

	public:
		SimpleShellsWorldObserver( World *__world );
		~SimpleShellsWorldObserver();

		void reset();
		void step();

};

#endif

