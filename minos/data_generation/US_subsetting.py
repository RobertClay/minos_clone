""" File for subsetting US data. If only interested in fraction of population as input. """

import US_utils
def get_scottish(data):



    return data.loc[data['region']=='Scotland',]

def main():
    # get files
    # subset by X.
    # save files.
    file_names = ["data/upscaled_US/2018_US_cohort.csv"]
    data = US_utils.load_multiple_data(file_names)[0]
    data =get_scottish(data)
    US_utils.save_multiple_files(data, [2018], "subsetted_US", "")
if __name__ == '__main__':
    main()