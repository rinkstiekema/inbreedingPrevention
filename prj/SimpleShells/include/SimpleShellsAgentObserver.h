/*
 *  BasicAgentObserver.h
 *  roborobo-online
 *
 *  Created by Nicolas on 27/05/10.
 *
 */

 
#ifndef SIMPLESHELLSAGENTOBSERVER_H
#define SIMPLESHELLSAGENTOBSERVER_H

#include "RoboroboMain/common.h"
#include "RoboroboMain/roborobo.h"

#include "SimpleShells/include/SimpleShellsAgentWorldModel.h"

#include "Observers/AgentObserver.h"

class SimpleShellsAgentObserver : public AgentObserver
{
	protected:
	SimpleShellsAgentWorldModel	*_wm;

	public:
		//Initializes the variables
		SimpleShellsAgentObserver( );
		SimpleShellsAgentObserver( RobotAgentWorldModel *__wm );
		~SimpleShellsAgentObserver();
				
		void reset();
		void step();
		
};


#endif

