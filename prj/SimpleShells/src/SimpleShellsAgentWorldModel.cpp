#include "SimpleShells/include/SimpleShellsAgentWorldModel.h"

#include "World/World.h"
#include <numeric>

SimpleShellsAgentWorldModel::SimpleShellsAgentWorldModel() {
    setRobotLED_status(true);
    _action = ACTION_ACTIVATE;
    _speedPenalty = 1.0;
    _specialisation = 0.0;

    // For backward compatibility, we might check gSpecialisation as bool and as double; bool false-> 0.0, true->1.0 
    ///bool temp(false);
    ///if (gProperties.checkAndGetPropertyValue("gSpecialisation", &temp, false)) {
        ///_specialisation = temp ? 1.0 : 0.0;
    ///} else {

    gProperties.checkAndGetPropertyValue("gSpecialisation", &_specialisation, 0.0);
}

SimpleShellsAgentWorldModel::~SimpleShellsAgentWorldModel() {
}

void SimpleShellsAgentWorldModel::dumpGenePoolStats() const {
    std::vector<Genome>::const_reverse_iterator itGenome;
    double totalFitness = .0;
    gLogFile << "EggHatched: (" << gWorld->getIterations() << "; " << _xReal << "; " << _yReal << "); [";   
    for (itGenome = _genePool.rbegin(); itGenome < _genePool.rend(); itGenome++) {
        if (itGenome != _genePool.rbegin()) {
            gLogFile << ", ";
        }
        gLogFile << "[";
        for (int i = 0; i < gPuckColors; i++) {
            gLogFile << itGenome->pucks[i] << ", ";
        }
        gLogFile << itGenome->fitness << ", " << itGenome->id << "]";
        totalFitness += itGenome->fitness;
    }
    gLogFile << "]; Winner: " << _winnerId << std::endl;
}

void SimpleShellsAgentWorldModel::setSpeedPenalty() {

    _speedPenalty = 1.0;
    if (_puckCounters && ! _puckCounters->empty())
    {
        double max = (double) *(std::max_element(_puckCounters->begin(), _puckCounters->end()));
        double sum = (double) std::accumulate(_puckCounters->begin(), _puckCounters->end(), 0);
	double x = (sum == 0.0) ? 1.0 : (max/sum); // x is the specialisation level 

        _speedPenalty = pow(x, _specialisation);
//        std::cout << "specialisation: " << x << " (" << max << '/' << sum << "); speed penalty: " << _speedPenalty << ", penalty level: " << _specialisation << '\n';
    }
}
