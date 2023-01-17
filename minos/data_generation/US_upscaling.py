"""File for scaling up Understanding Society population. For now just merge with chris' spatial data."""

import pandas as pd
import US_utils
def spatial_pidp_upscale(data):
    """Simply merge on chris' data to produce a full scale individually representative pop"""
    #TODO there is a household level representative pop available.
    spatial_data = pd.read_csv("persistent_data/ADULT_population_GB_2018.csv")
    data = spatial_data.merge(data, how='left', on='pidp')
    return data

def main():
    # get final_US data
    # merge with chris' data to get full scale pop.
    # some way to deal with clashing hidp/pidps.
    file_names = ["data/complete_US/2018_US_cohort.csv"]
    data = US_utils.load_multiple_data(file_names)[0]
    data = spatial_pidp_upscale(data)
    US_utils.save_multiple_files(data, [2018], "upscaled_US", "")
    return

if __name__ == '__main__':
    main()