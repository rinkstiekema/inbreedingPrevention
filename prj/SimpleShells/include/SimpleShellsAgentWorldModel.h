#ifndef SIMPLESHELLSAGENTWORLDMODEL_H
#define SIMPLESHELLSAGENTWORLDMODEL_H

#include "RoboroboMain/common.h"
#include "RoboroboMain/roborobo.h"

#include "WorldModels/RobotAgentWorldModel.h"

class World;

enum {PHASE_GATHERING, PHASE_MATING};
enum {ACTION_ACTIVATE, ACTION_GATHER, ACTION_BRAKE, ACTION_MATE, ACTION_SELECT, ACTION_SIZE};

class SimpleShellsAgentWorldModel : public RobotAgentWorldModel {
	public:
        std::vector<int>* _puckCounters;
        std::vector<Genome> _genePool;

        int _lifetime[2];
        int _phase;
        int _action;
        double _speedPenalty;
        double _specialisation;
        
        Uint32 _winnerId;

		SimpleShellsAgentWorldModel();
		virtual ~SimpleShellsAgentWorldModel();

        inline int lifetime() {
            return _lifetime[_phase];
        }

        inline void nextAction() {
            _action = (_action + 1) % ACTION_SIZE;
        }

        inline int advance() {
            if (((_action == ACTION_GATHER) || (_action == ACTION_MATE)) && (--_lifetime[_phase] > 0)) return _lifetime[_phase];
            _action = (_action + 1) % ACTION_SIZE;
            return 0;
        }

        void dumpGenePoolStats() const;
        void setSpeedPenalty();
};


#endif


