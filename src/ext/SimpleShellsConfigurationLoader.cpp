#include "Config/SimpleShellsConfigurationLoader.h"

#include "SimpleShells/include/SimpleShellsWorldObserver.h"
#include "SimpleShells/include/SimpleShellsAgentWorldModel.h"
#include "SimpleShells/include/SimpleShellsAgentObserver.h"
#include "SimpleShells/include/SimpleShellsControlArchitecture.h"

#include "World/RobotAgentWorldInterface.h"

SimpleShellsConfigurationLoader::SimpleShellsConfigurationLoader()
{
	// create the single instance of Agent-World Interface.
	_AgentWorldInterface = new RobotAgentWorldInterface();

}

SimpleShellsConfigurationLoader::~SimpleShellsConfigurationLoader()
{
	//nothing to do
}


WorldObserver* SimpleShellsConfigurationLoader::make_WorldObserver(World* wm)
{
	return new SimpleShellsWorldObserver(wm);
}

RobotAgentWorldModel* SimpleShellsConfigurationLoader::make_RobotAgentWorldModel()
{
	return new SimpleShellsAgentWorldModel();
}

AgentObserver* SimpleShellsConfigurationLoader::make_AgentObserver(RobotAgentWorldModel* wm)
{
	return new SimpleShellsAgentObserver(wm);
}

BehaviorControlArchitecture* SimpleShellsConfigurationLoader::make_BehaviorControlArchitecture(RobotAgentWorldModel* wm)
{
	return new SimpleShellsControlArchitecture(wm);
}

RobotAgentWorldInterface* SimpleShellsConfigurationLoader::make_RobotAgentWorldInterface()
{
	return _AgentWorldInterface;
}
