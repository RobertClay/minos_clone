#!/bin/bash
## Do the dodgy output thing where we pull the files out of the runtime directory and delete it

base_folder=output/default_config/baseline/2023_01*
wage_folder=output/default_config/livingWageIntervention/2023_01*
child_folder=output/default_config/hhIncomeChildUplift/2023_01*


echo "################################################"
echo "Doing dodgy output move to avoid having to fix the lineplot scripts"

cp -r $base_folder/* output/default_config/baseline
rm -r $base_folder/

cp -r $wage_folder/* output/default_config/livingWageIntervention
rm -r $wage_folder

cp -r $child_folder/* output/default_config/hhIncomeChildUplift
rm -r $child_folder

echo "Finished!!"
echo "################################################"