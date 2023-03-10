"""
Superclass for MINOS modules to try and reduce a lot of boilerplate. Removes a lot of repetition and makes modules
easier to build.


"""

from datetime import datetime as dt

class Base():

    def pre_setup(self, config, simulation):
        """ Load in anything required for the module to run into the config and simulation object.

        This default does nothing. If any further setup is required it is done in each module.

        Parameters
        ----------
        config : vivarium.config_tree.ConfigTree
            Config yaml tree for vivarium with the items needed for this module to run.

        simulation : vivarium.interface.interactive.InteractiveContext
            The initiated vivarium simulation object before simulation.setup() is run with updated config/inputs.

        Returns
        -------
            simulation : vivarium.interface.interactive.InteractiveContext
                The initiated vivarium simulation object with anything needed to run the module.
                E.g. rate tables.
        """
        return simulation

    def on_initialize_simulants(self, pop_data):
        """  Initiate columns for mortality when new simulants are added. By default adds no columns.

        Parameters
        ----------
        pop_data: vivarium.framework.population.SimulantData
            Custom vivarium class for interacting with the population data frame.
            It is essentially a pandas DataFrame with a few extra attributes such as the creation_time,
            creation_window, and current simulation state (setup/running/etc.).
        Returns
        -------
        None
        """
        # Initiate any columns created by this module and add them to the main population.
        # No synthetic columns for housing currently. Maybe housing history variables added here.
        return pop_data

    def generate_fixed_crn_key(self):
        "CRN randomness streams in vivarium use hash some input string key as the seed for RNG."
        "If we want a fixed seed for each vivarium run just use the name of the module."
        "Useful if trying to reduce variance. Or for non-random models e.g. OLS."
        return f"{self.name}"

    def generate_random_crn_key(self):
        "Provides random hash for each minos run using date time."
        "Provides more stochasticity in random models e.g. binomial/clm"
        "Seems like vivarium uses a 10 digit congruency generator to produces hashes."
        "Very unlikely to repeat but even then doesn't matter.."
        return f"{self.name}{dt.now()}"

    def plot(self, pop_data, config):
        """ Default plot method for modules. Does nothing.

        Modules can specify another plot object that saves distributions of state.

        Parameters
        ----------
        pop_data: population data from vivarium. Whatever columns needs plotting.

        config: vivarium.configTree

            Config yaml for any needed plot parameters.

        Returns
        -------
        None
        """
