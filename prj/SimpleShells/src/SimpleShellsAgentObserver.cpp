#include "SimpleShells/include/SimpleShellsAgentObserver.h"



SimpleShellsAgentObserver::SimpleShellsAgentObserver( )
{
}

SimpleShellsAgentObserver::SimpleShellsAgentObserver( RobotAgentWorldModel *__wm )
{
	_wm = (SimpleShellsAgentWorldModel*)__wm;
}

SimpleShellsAgentObserver::~SimpleShellsAgentObserver()
{
	// nothing to do.
}

void SimpleShellsAgentObserver::reset()
{
	// nothing to do.
}

void SimpleShellsAgentObserver::step()
{
	// nothing to do.
}

