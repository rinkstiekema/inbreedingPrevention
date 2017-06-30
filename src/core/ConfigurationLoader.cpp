#include "Config/ConfigurationLoader.h"
#include <string.h>

//-------------------------
//Include under your loaders
#include "Config/SimpleShellsConfigurationLoader.h"

ConfigurationLoader::ConfigurationLoader() {
	//nothing to do
}

ConfigurationLoader::~ConfigurationLoader() {
	//nothing to do
}

ConfigurationLoader* ConfigurationLoader::make_ConfigurationLoader (std::string configurationLoaderObjectName) {
	if(configurationLoaderObjectName == "SimpleShellsConfigurationLoader") {
		return new SimpleShellsConfigurationLoader();
	} else {
		return NULL;
	}
}
