#include "SimpleShells/include/SimpleShellsWorldObserver.h"

#include "World/World.h"


SimpleShellsWorldObserver::SimpleShellsWorldObserver( World *__world ) : WorldObserver( __world )
{
	_world = __world;
}

SimpleShellsWorldObserver::~SimpleShellsWorldObserver()
{
	// nothing to do.
}

void SimpleShellsWorldObserver::reset()
{
	timer = new Timer();
	timer->start();
}

void SimpleShellsWorldObserver::step()
{
    int iteration = _world->getIterations();
    if (iteration == _world->_colorChangeIteration) {_world->doColorChange();}
    if (iteration % 1000 == 0) {
        double progress = (double)iteration / (double)gMaxIt * 100.0;
        std::cout << std::endl << "##########" << std::endl << "# ";
        std::cout.width(5); std::cout.precision(1);
        std::cout << std::fixed << progress;
        std::cout << "% #" << std::endl << "##########" << std::endl << std::endl;
    }

	if (_world->getIterations() == gMaxIt - 1) {
		printf("Took %d ms.\n", timer->get_ticks());
	}
}


