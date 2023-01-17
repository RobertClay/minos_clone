""" File for subsetting US data. If only interested in fraction of population as input. """

import US_utils
import pandas as pd

def get_scottish(data):
    "get the scots."
    return data.loc[data['region']=='Scotland',]

#def main():
#    # get files
#    # subset by X.
#    # save files.
#    file_names = ["data/upscaled_US/2018_US_cohort.csv"]
#    data = US_utils.load_multiple_data(file_names)[0]
#    data =get_scottish(data)
#    US_utils.save_multiple_files(data, [2018], "subsetted_US", "")


def main():
    # get files
    # subset by X.
    # save files.
    file_names = ["data/final_US/2019_US_cohort.csv"]
    data = US_utils.load_multiple_data(file_names)
    data = get_scottish(data)
    US_utils.save_multiple_files(data, [2019], "data/scotland_US/", "")

if __name__ == '__main__':
    main()