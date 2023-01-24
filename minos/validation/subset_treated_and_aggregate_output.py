"""
This script will produce aggregated and summarised values from multiple output files from Minos batch runs. As part of
this process, it will also subset both baseline and intervention outputs to ensure that the exact same sample is
included in the summarised aggregated values. This is so that when we come to plot these aggregated population level
outputs and investigate the effects of a certain intervention, we can be sure that the effects we are plotting are
across only the treated population.
"""

import pandas as pd
import glob as glob
import numpy as np
import argparse
import os
import yaml
from datetime import datetime
from aggregate_subset_functions import find_subset_function
from multiprocessing import Pool
from itertools import repeat


def aggregate_csv(filename, v, agg_method, subset_func):
    'converts a filename to a pandas dataframe'
    df = pd.read_csv(filename, low_memory=False)
    if subset_func:
       df = subset_func(df)
    return agg_method(df[v])

def subset_treated_and_aggregate_variables_by_year(source, years, tag, v, method, subset_func):
    """ Get aggregate values for value v using method function. Do this over the specified source and years.
    A MINOS batch run under a certain intervention will produce 1000 files over 10 years and 100 iterations.
    These files will all be in the source directory.
    For each year this function grabs all files. If the model runs from 2010-2020 there would be 100 files for 2010.
    For each file within a year the method function is used over variable v.
    The default is taking the mean over SF12 using np.nanmean.
    For each file this will produce a scalar value.
    This scalar value is used along with a year and tag tag as a row in the output dataframe df.
    These tags determine which year and which source the dataframe row belongs to.
    If the source is a £25 uplift intervention the tag tag will correspond to this.
    This is used later by sns.lineplot.
    This is repeated over all years to produce an output dataframe with 1000 rows.
    Each row is an aggregated v value for each iteration and year pair.
    Parameters
    ----------
    source: str
        What directory is being aggregated. E.g. output/baseline/
    years, v : list
        What range of years are being used. What set of variables are being aggregated.
    tag: str
        Which data source are being processed. adds a tag column to the df with this tag.
    method: func
    Returns
    -------
    df: pd.DataFrame
        Data frame with columns year, tag and v. Year is year of observation, tag is MINOS batch run and intervention
        it has come from, v is aggregated variable. Usually SF12.
    """

    df = pd.DataFrame()
    for year in years:
        files = glob.glob(os.path.join(source, f"*{year}.csv")) # grab all files at source with suffix year.csv.

        with Pool() as pool:
            aggregated_means = pool.starmap(aggregate_csv, zip(files, repeat(v), repeat(method), repeat(subset_func)))

        new_df = pd.DataFrame(aggregated_means)
        new_df.columns = [v]
        new_df['year'] = year
        new_df['tag'] = tag
        #for file in files: # loop over files. take aggregate value of v and add it as a row to output df.
        #    new_df = pd.read_csv(file, low_memory=False)
        #    if subset_func:
        #        new_df = subset_func(new_df)
        #    agg_var = new_df[v]
        #    agg_value = method(agg_var)
        #    new_df = pd.DataFrame([[year, tag, agg_value]], columns = ['year', 'tag', v])
        #    df = pd.concat([df, new_df], sort=False)
        df = pd.concat([df, new_df])
    return df


def main(source, base_dir, int_dir):
    
    ## Handle the datetime folder inside the output. Select most recent run

    # list all runtime folders in the baseline and intervention output directories
    b_runtime = os.listdir(os.path.abspath(os.path.join(source, base_dir)))
    i_runtime = os.listdir(os.path.abspath(os.path.join(source, int_dir)))

    list_of_runtime_lists = list([b_runtime, i_runtime])
    list_of_runtimes = list()

    # if there are more than 1 runtime directories, choose the most recent
    # if only 1 then use that
    for runtime_list in list_of_runtime_lists:
        # TODO: Replace this block (or encapsulate) in a try except block for proper error handling
        if len(runtime_list) > 1:
            runtime = max(runtime_list, key=lambda d: datetime.strptime(d, "%Y_%m_%d_%H_%M_%S"))
        elif len(runtime_list) == 1:
            runtime = runtime_list[0]
        else:
            raise RuntimeError("The output directory supplied contains no subdirectories, and therefore no data to "
                               "aggregate. Please check the output directory.")
        list_of_runtimes.append(runtime)

    base_source = os.path.join(source, base_dir, list_of_runtimes[0])
    int_source = os.path.join(source, int_dir, list_of_runtimes[1])

    print(base_source)
    print(int_source)

    subset_and_aggregated_df = subset_treated_and_aggregate_variables_by_year()


if __name__ == '__main__':
    
    ### For testing purposes only, replace this soon with command line args
    source = 'output/default_config'
    base_dir = 'baseline'
    int_dir = 'energyDownlift'
    
    main(source, base_dir, int_dir)
