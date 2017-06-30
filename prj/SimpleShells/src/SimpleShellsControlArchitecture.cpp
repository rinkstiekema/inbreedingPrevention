#include "SimpleShells/include/SimpleShellsControlArchitecture.h"

#include <algorithm>

bool genomeSortPredicate(const Genome & genomeOne, const Genome & genomeTwo) {
    return genomeOne.fitness > genomeTwo.fitness;
}

// Fitness should be positive
std::vector<Genome>::const_iterator SimpleShellsControlArchitecture::selectWeighted(std::vector<Genome> & genomes) {
    std::vector<Genome>::const_iterator a, b, c;

    if (genomes.size() < 2)
    	return genomes.begin();
    // else

    if (_randomSelection)
    {
      //std::cout  << "Iteration: " << gWorld->getIterations() << "; Size: " << genomes.size() << std::endl;
      return genomes.begin() + Rand::randint(0, genomes.size());
    }
    // else

    // NOTE : expect sorted genomes on fitnesses.
    a = genomes.begin();
    b = genomes.begin() + genomes.size() / 2;
    c = genomes.begin() + genomes.size() - 1;

#ifdef TOURNAMENT_SELECTION

    int candidate1 = Rand::randint(0, genomes.size());
    int candidate2 = Rand::randint(0, genomes.size());
    while (candidate2 == candidate1) candidate2 = Rand::randint(0, genomes.size());

    // Note: genomes expected to be sorted!
    return genomes.begin() + std::min(candidate1,candidate2);
#endif // TOURNAMENT_SELECTION

    double n(genomes.size() - 1);
    double pos(0.0);

    // Note: 1 <= _selectionPressure <= 2

    double fitnessTotal = .0;
    double rankedTotal = .0;

    // Loop reversed and replace fitness w. rank-based variant
    for (std::vector<Genome>::reverse_iterator genome = genomes.rbegin(); genome != genomes.rend(); genome++) {
        fitnessTotal += genome->fitness;
        genome->fitness = 2.0 - _selectionPressure + 2.0 * (_selectionPressure - 1.0) * pos/n;
	rankedTotal += genome->fitness;
	pos++;
    }

    double random = Rand::randouble() * rankedTotal;
    std::cout  << "Iteration: " << gWorld->getIterations() << "; Size: " << genomes.size() << "; Fitness: " << a->fitness << "; " << b->fitness << "; " << c->fitness << "; Fitness avg: " << fitnessTotal / genomes.size() << "; roulette wheel: "  << random <<  std::endl;
    for (std::vector<Genome>::const_iterator it = genomes.begin(); it < genomes.end(); it++) {
        random -= it->fitness;
        if (random <= 0)
           return it;
    }

    // Should never get here
    return genomes.begin();
}

void mutate(std::vector<double> & parameters, double delta) {
    for (std::vector<double>::iterator it = parameters.begin(); it < parameters.end(); it++)
    {
        //*it += (ranf() - 0.5) * delta;
        *it += Rand::gaussianf(0.0, delta);
    }
}



SimpleShellsControlArchitecture::SimpleShellsControlArchitecture( RobotAgentWorldModel *__wm ) : BehaviorControlArchitecture ( __wm ) {
	_wm = (SimpleShellsAgentWorldModel*)__wm;

    int tmpInt = 0;
    gProperties.checkAndGetPropertyValue("gMaxAncestorsSize", &tmpInt, true);
    gMaxAncestorsSize = tmpInt;
    gProperties.checkAndGetPropertyValue("gMaxGenePool", &tmpInt, true);
    gMaxGenePool = tmpInt;
    gProperties.checkAndGetPropertyValue("gMaxLifetimeGathering", &tmpInt, true);
    _maxLifetime[PHASE_GATHERING] = tmpInt;
    gProperties.checkAndGetPropertyValue("gMaxLifetimeMating", &tmpInt, true);
    _maxLifetime[PHASE_MATING] = tmpInt;
    gProperties.checkAndGetPropertyValue("gHiddenNeuronCount", &tmpInt, true);
    _hiddenNeuronCount = tmpInt;

    _randomSelection = false;
    gProperties.checkAndGetPropertyValue("gRandomSelection", &_randomSelection, false);
    _useMarket = true;
    gProperties.checkAndGetPropertyValue("gUseMarket", &_useMarket, true);
    _useSpecBonus = false;
    gProperties.checkAndGetPropertyValue("gUseSpecBonus", &_useSpecBonus, false);
    _task1Premium = 1.0;
    gProperties.checkAndGetPropertyValue("gTask1Premium", &_task1Premium, 1.0);
    _selectionPressure = 1.5;
    gProperties.checkAndGetPropertyValue("gSelectionPressure", &_selectionPressure, 1.5);

    if (_hiddenNeuronCount > 0) {
        _parameterCount = (_wm->_sensorCount * (gPuckColors + 1) + 1 + 2) * _hiddenNeuronCount + (_hiddenNeuronCount + 1) * 2;
        _response.assign(_hiddenNeuronCount, .0);
    } else {
        _parameterCount = (_wm->_sensorCount * (gPuckColors + 1) + 1 + 2) * 2;
    }

    _wm->_genePool.reserve(gMaxGenePool);

    _nearbyGenomes.reserve(gNbOfAgents); // Agent counter is unpredictable at this time

    _activeGenome.parameters.assign(_parameterCount, .0);
    mutate(_activeGenome.parameters, 1.0);

    _wm->_puckCounters = &(_activeGenome.pucks);
}


SimpleShellsControlArchitecture::~SimpleShellsControlArchitecture() {
	// nothing to do.
}

void SimpleShellsControlArchitecture::reset() {
    //std::cout << "[gathered] " << _wm->_world->getIterations() << ' ' << _activeGenome.id;
    //for (std::vector<int>::iterator i = _activeGenome.pucks.begin(); i < _activeGenome.pucks.end(); ++i)
       //std::cout << ' ' << *i;
    //std::cout << ' ' << _activeGenome._distance;
    //std::cout << '\n';
    // Set somewhat random lifetime
    _wm->_lifetime[PHASE_GATHERING] = _maxLifetime[PHASE_GATHERING] * (ranf() * 0.25 + 0.75);
    _wm->_lifetime[PHASE_MATING] = _maxLifetime[PHASE_MATING];
    // Remove all gathered genomes from the gene pool
    _wm->_genePool.clear();
    // Set all puck counters to zero
    _activeGenome.pucks.assign(gPuckColors, 0);
    _activeGenome._distance = 0.0;
    _activeGenome._lastXPos = _wm->getXReal();
    _activeGenome._lastYPos = _wm->getYReal();
    // Finally, update the active genome.
    _activeGenome.id = gNextGenomeId++;

    //std::cout << "[descendant] " <<  _wm->_world->getIterations() << ' ' << _wm->_winnerId << ' ' << _activeGenome.id << '\n';
}


double getSpecDeg(std::vector<int> & counts) {
    // Sum counts
    double totalCount = gPuckColors;
    for (uint i = 0; i < counts.size(); i++) {
        totalCount += counts[i];
    }
    // Translate counts to fractions, treating count of zero as a very small fraction
    std::vector<double> fractions;
    fractions.resize(counts.size());
    for (uint i = 0; i < counts.size(); i++) {
        fractions[i] = (counts[i] + 1) / totalCount;
    }
    // Calculate entropy of the given fractions
    double entropy = .0;
    for (uint i = 0; i < counts.size(); i++) {
        entropy -= fractions[i] * std::log(fractions[i]);
    }
    // Calculate base entropy (assuming all counts are same)
    double baseFraction = 1.0 / gPuckColors;
    double baseEntropy = -gPuckColors * baseFraction * std::log(baseFraction);
    // Calculate how much our case is different than this base = degree of specialization.
    // Will be around 1.0 for perfect specialist, and around .0 for perfect generalist.
    // Given that puck counts are skewed, all will be seen as specialists of small degree
    return 1.0 - entropy / baseEntropy;
}

double SimpleShellsControlArchitecture::calcCommonAncestorsRating(std::vector<Genome>::iterator itGenome){
    // Count common ancestors
    int iterator1 = 1;
    for (std::vector<int>::iterator itAncestor1 = itGenome->ancestors.begin(); itAncestor1 < itGenome->ancestors.end(); itAncestor1++){
        int iterator2 = 1;
        for (std::vector<int>::iterator itAncestor2 = _activeGenome.ancestors.begin(); itAncestor2 < _activeGenome.ancestors.end(); itAncestor2++){
            if(*itAncestor1 == *itAncestor2){
                return (double)1-(pow(2, (0-(iterator1*iterator2))));
            }
            iterator2 += 1;
        }
        iterator1 += 1;
    }

    return 1;
}

void SimpleShellsControlArchitecture::assignFitness(std::vector<Genome> & genomes) {
    // Calculate how many pucks of each color and how many puck in total were gathered.
    std::vector<int> puckTotals(gPuckColors, 0);
    int cumTotal = 0;

    for (std::vector<Genome>::iterator itGenome = genomes.begin(); itGenome < genomes.end(); itGenome++) {
        // Count different colors
        for (int i = 0; i < gPuckColors; i++) puckTotals[i] += itGenome->pucks[i];

        if(gPreventInbreeding) {
            itGenome->commonAncestorsRating = calcCommonAncestorsRating(itGenome);
        }
    }

    // Count the cumulative total
    for (int i = 0; i < gPuckColors; i++)
    {
        cumTotal += puckTotals[i];
        //std::cout << puckTotals[i] << ' ';
    }
    //std::cout << "(tot: " << cumTotal << ") ";

    // Calculate the puck prices (depending on puck fraction)
    std::vector<double> puckPrices;
    puckPrices.resize(gPuckColors);

    for (int i = 0; i < gPuckColors; i++) {
        // EH removed:  Bayesian-like trick: one 'virtual' puck is added to each color to avoid division by zero.
        if (_useMarket) {
            puckPrices[i] = (puckTotals[i] == 0) ? 0.0 : double(cumTotal) / double(puckTotals[i]);
        } else {
            puckPrices[i] = 1.0;
        }
    //std::cout << puckPrices[i] << ' ';
    }
    // TODO: better premium calculation for pucks
    puckPrices[0] *= _task1Premium;
    std::cout << std::endl;
    // Finally, use the prices to calculate fitness of a genome (and store it within)
    for (std::vector<Genome>::iterator itGenome = genomes.begin(); itGenome < genomes.end(); itGenome++) {
        // We are using roulette selection, so genomes which gathered no pucks will still receive a small fitness.
        double rating = .005;

        for (int i = 0; i < gPuckColors; i++) {
            rating += double(itGenome->pucks[i]) * puckPrices[i];
            std::cout << itGenome->pucks[i] << ' ';
        }

        if (_useSpecBonus) {
            // Calculate specialization degree (value in [0, 1] with 1 corresponding to ideal specialist)
            double degree = getSpecDeg(itGenome->pucks);
            // Use inverse logistic function to bring the specialization degree value from typical 0.3 .. 0.7 region into 0 .. 30 region, in such a way, that both specialists and generalists ends will be a bit amplified.
            double value = std::log(1.01/(degree+0.01) - 0.99) * 10.0 + 15.0;
            if (value < 0) value = 0; else if (value > 30) value = 30;
            if(gPreventInbreeding) {
                itGenome->fitness = (rating * (1.0 + value))*(itGenome->commonAncestorsRating);
            } else {
                itGenome->fitness = rating * (1.0 + value);
            }
        } else {
            if(gPreventInbreeding) {
                itGenome->fitness = rating*(itGenome->commonAncestorsRating);
            } else {
                itGenome->fitness = rating;
            }

        }
        //std::cout << itGenome->fitness << std::endl;
    }
}



// Just gather all nearby genomes. Duplicates will be handled elsewhere.
void SimpleShellsControlArchitecture::gatherGenomes(std::vector<Genome*> & genePool, int commDistSquared) {
    genePool.clear();
    std::vector<RobotAgentPtr>* agents = gWorld->listAgents();
    std::vector<RobotAgentPtr>::iterator itAgent;
    if (commDistSquared < 0) {
        for (itAgent = agents->begin(); itAgent < agents->end(); itAgent++) {
            RobotAgentPtr& agent = *itAgent;
            SimpleShellsControlArchitecture* controller = static_cast<SimpleShellsControlArchitecture*>(agent->getBehavior());
            genePool.push_back(controller->getGenome());
        }
    } else {
        for (itAgent = agents->begin(); itAgent < agents->end(); itAgent++) {
            RobotAgentPtr& agent = *itAgent;
            if (isRadioConnection(agent->getWorldModel()->_agentId,_wm->_agentId)) {
                SimpleShellsControlArchitecture* controller = static_cast<SimpleShellsControlArchitecture*>(agent->getBehavior());
                genePool.push_back(controller->getGenome());
            }
        }
    }
}



void SimpleShellsControlArchitecture::updateGenomes() {
    gatherGenomes(_nearbyGenomes, gMaxCommDistSquared);

    std::vector<Genome*>::iterator itNewGenomes;
    std::vector<Genome>::iterator itGatheredGenomes;
    for (itNewGenomes = _nearbyGenomes.begin(); itNewGenomes < _nearbyGenomes.end(); itNewGenomes++) {
        bool sameDNA = false;
        // Check if new genome has actually same vector as one of the gathered.
        for (itGatheredGenomes = _wm->_genePool.begin(); itGatheredGenomes < _wm->_genePool.end(); itGatheredGenomes++) {
            sameDNA = (itGatheredGenomes->id == (*itNewGenomes)->id);
            if (sameDNA) break;
        }
        // If parameter vector is the same, update puck counts within the genome (which are increasing monotonously).
        if (sameDNA) {
            for (int i = 0; i < gPuckColors; i++) itGatheredGenomes->pucks[i] = (*itNewGenomes)->pucks[i];
        } else {
            _wm->_genePool.push_back(**itNewGenomes);
            Genome & genome = _wm->_genePool.back();
            // TODO: are those two lines needed?
            genome.pucks.assign((*itNewGenomes)->pucks.begin(), (*itNewGenomes)->pucks.end());
            genome.parameters.assign((*itNewGenomes)->parameters.begin(), (*itNewGenomes)->parameters.end());
            if (_wm->_genePool.size() == gMaxGenePool) {
                _wm->nextAction(); break;
            }
        }
    }
}


void SimpleShellsControlArchitecture::updateActuators() {
    std::vector<double> & parameters = _activeGenome.parameters;
    int geneToUse = 0;

    double trans = .0, rotor = .0;

    if (_hiddenNeuronCount > 0) {
        // Calculating response of the hidden layer.
        // Initiate with biases.
        for (int n = 0; n < _hiddenNeuronCount; n++) {
            _response[n] = 1.0 * parameters[geneToUse++];
            // Using those in hopes to initiate feedback loop, which will make trajectories more random, and hence more likely to encounter pucks
            _response[n] += parameters[geneToUse++] * _wm->_desiredRotationalVelocity / gMaxRotationalSpeed;
            _response[n] += parameters[geneToUse++] * _wm->_desiredTranslationalValue / gMaxTranslationalSpeed;
        }

        // Distance to obstacle along each of the sensor rays.
        // Distances to pucks of various colors along each of the sensor rays.
        for (int s = 0; s < _wm->_sensorCount; s++) {
            double normObstacleRange = _wm->_rangeSensors[s]->getNormObstacleRange();
            for (int n = 0; n < _hiddenNeuronCount; n++) {
                _response[n] += parameters[geneToUse++] * normObstacleRange;
            }
            for (int c = 0; c < gPuckColors; c++) {
                double normPuckRange = _wm->_rangeSensors[s]->getNormPuckRange(c);
                for (int n = 0; n < _hiddenNeuronCount; n++) {
                    _response[n] += parameters[geneToUse++] * normPuckRange;
                }
            }
        }

        // Activation
        for (int n = 0; n < _hiddenNeuronCount; n++) {
            _response[n] = tanh(_response[n]);
        }

        for (int n = 0; n < _hiddenNeuronCount; n++) {
            trans += _response[n] * parameters[geneToUse++];
            rotor += _response[n] * parameters[geneToUse++];
        }
    } else {
        trans += parameters[geneToUse++] * _wm->_desiredRotationalVelocity / gMaxRotationalSpeed;
        trans += parameters[geneToUse++] * _wm->_desiredTranslationalValue / gMaxTranslationalSpeed;
        rotor += parameters[geneToUse++] * _wm->_desiredRotationalVelocity / gMaxRotationalSpeed;
        rotor += parameters[geneToUse++] * _wm->_desiredTranslationalValue / gMaxTranslationalSpeed;
        for (int s = 0; s < _wm->_sensorCount; s++) {
            double normObstacleRange = _wm->_rangeSensors[s]->getNormObstacleRange();
            trans += normObstacleRange * parameters[geneToUse++];
            rotor += normObstacleRange * parameters[geneToUse++];
            for (int c = 0; c < gPuckColors; c++) {
                double normPuckRange = _wm->_rangeSensors[s]->getNormPuckRange(c);
                trans += normPuckRange * parameters[geneToUse++];
                rotor += normPuckRange * parameters[geneToUse++];
            }
        }
    }

    // Output layer
    // Initiate with biases.
    trans += 1.0 * parameters[geneToUse++];
    rotor += 1.0 * parameters[geneToUse++];

    trans = tanh(trans);
    rotor = tanh(rotor);

    _wm->_desiredTranslationalValue = trans * gMaxTranslationalSpeed * _wm->_speedPenalty;
    _wm->_desiredRotationalVelocity = rotor * gMaxRotationalSpeed * _wm->_speedPenalty;
}

void SimpleShellsControlArchitecture::select() {
    // If the egg has gathered enough genomes or it's time is up, reactivate it with one of the gathered genomes.
    // Assign subjective fitness to genomes
    assignFitness(_wm->_genePool);
    // Do roulette selection (need to sort genomes vector first, because we are calculating medians for logging)
    std::sort(_wm->_genePool.begin(), _wm->_genePool.end(), genomeSortPredicate);
    std::vector<Genome>::const_iterator winner = selectWeighted(_wm->_genePool);
    _wm->_winnerId = winner->id;

    // Prevent getting more ancestors than max
    if((int)(_activeGenome.ancestors.size()) == gMaxAncestorsSize){
        _activeGenome.ancestors.pop_back();
    }
    // Put winner's ID to first element of ancestors array
    _activeGenome.ancestors.insert(_activeGenome.ancestors.begin(), winner->id);

    //std::cout << "Ancestors = ";
    for(std::vector<int>::const_iterator itAncestor = _activeGenome.ancestors.begin(); itAncestor != _activeGenome.ancestors.end(); ++itAncestor){
        std::cout << *itAncestor << " ";
    }
    std::cout << std::endl;

    // Reactivate with the winning genome
    for (int i = 0; i < _parameterCount; i++) _activeGenome.parameters[i] = winner->parameters[i];
    // Mutate a bit
    mutate(_activeGenome.parameters, 0.1);
    // Do some logging
    _wm->dumpGenePoolStats();
}

void SimpleShellsControlArchitecture::step() {
    /*if (gWorld->getIterations() == 500000) {
      _task1Premium = 1.0;
      std::cout << "Setting _task1Premium to 1\n";
    }
    if (gWorld->getIterations() == 750000) {
      gProperties.checkAndGetPropertyValue("gTask1Premium", &_task1Premium, 1.0);
      std::cout << "Setting _task1Premium to " << _task1Premium << "\n";
    }
*/
    bool done = false;
    while (!done) {
        switch (_wm->_action) {
            case ACTION_SELECT:
                select();
                _wm->advance();
                break;
            case ACTION_ACTIVATE :
                reset();
                _wm->_phase = PHASE_GATHERING;
                _wm->setRobotLED_colorValues(34, 139, 34);
                _wm->advance();
                break;
            case ACTION_GATHER :
                updateActuators();
                _wm->advance();
                // Last turn of gathering can't be combined with the braking turn.
                done = true;
                break;
            case ACTION_BRAKE :
                _wm->_desiredTranslationalValue = 0;
                _wm->_desiredRotationalVelocity = 0;
                _wm->_phase = PHASE_MATING;
                _wm->setRobotLED_colorValues(255, 69, 0);
                _wm->advance();
                break;
            case ACTION_MATE :
                updateGenomes();
                // Last turn of mating can be combined with selection, activation and first turn of gathering
                if (_wm->advance() > 0) done = true;
                break;
        }
    }
    if (gWorld->getIterations() % 10 == 0)
    {
        double dx = _activeGenome._lastXPos - _wm->getXReal();
        double dy = _activeGenome._lastYPos - _wm->getYReal();
        _activeGenome._distance += sqrt(dx*dx + dy*dy);
        _activeGenome._lastXPos = _wm->getXReal();
        _activeGenome._lastYPos = _wm->getYReal();
    }
}
