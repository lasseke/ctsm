#!/usr/bin/env bash

### Define plotnames
plotname=(ALP1 ALP2 ALP3 ALP4 SUB1 SUB2 SUB3 SUB4 BOR1 BOR2 BOR3 BOR4)
suffix="_4PFTs_1.1.1"

build_cases="F"
change_runopts="F"
change_fatesparams="F"
run_cases="T"
add_fatesparam_namelist="F"

# Start with clean module list
module purge

if [ ${change_fatesparams} == "T" ]
then

  new_fatesparam_fname="SeedClim_PFTs_only_1.1.1" # Name of new paramfile you wish to create
  create_fatesparam_def="F"

  #source activate cesm
  module load netCDF-Fortran/4.4.4-intel-2018b
  module load Python/3.6.6-intel-2018b

  if [ ${create_fatesparam_def} == "T" ]
  then
    cd ~/ctsm/src/fates/parameter_files/
    ncgen -o fates_params_default.nc fates_params_default.cdl
  fi

  cd  ~/ctsm/src/fates/parameter_files/
  ~/ctsm/src/fates/tools/FatesPFTIndexSwapper.py --pft-indices=7,8,9,10,11 --fin=./fates_params_default.nc --fout=./$new_fatesparam_fname.nc

fi

########################## START LOOPING THROUGH PLOTS ###########

len=${#plotname[@]}
for (( i=0; i<$len; i++ ))
do

############################################ BUILD CASES #######################################################

if [ ${build_cases} == "T" ]
then

  cd ~/ctsm/cime/scripts
  ./create_newcase --case ~/ctsm_cases/${plotname[i]}$suffix --compset 2000_DATM%1PTGSWP3_CLM50%FATES_SICE_SOCN_MOSART_SGLC_SWAV --res 1x1_${plotname[i]} --machine saga --run-unsupported --project nn2806k

  cd ~/ctsm_cases/${plotname[i]}$suffix
  #./case.setup
  ./case.build
fi


############################################ CHANGE RUN OPTS ####################################################

if [ ${change_runopts} == "T" ]
then
  
  cd ~/ctsm_cases/${plotname[i]}$suffix
  
  ### Change run parameters in case
  ./xmlchange --file env_run.xml --id RUN_STARTDATE --val 0001-01-01    
  # set up the starting date of your simulation
  ./xmlchange --file env_run.xml --id STOP_OPTION --val nyears   
  # set the simulation periods to "years"
  ./xmlchange --file env_run.xml --id STOP_N --val 500 
  # set the length of simulation, i.e, how many years
  ./xmlchange --file env_run.xml --id CONTINUE_RUN --val FALSE
  # if you want to continue your simulation from restart file, set it to TRUE
  ./xmlchange --file env_run.xml --id RESUBMIT --val 3
  # set up how many times you want to resubmit your simulation.
  # e.g, STOP_N=5, RESUBMIT=10, you will have simulation for 5+5*10=55
  ./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 1901
  # set up the start year of the atmospheric forcing
  ./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END --val 1930
  # set up the end year of the atmospheric forcing
  ./xmlchange --file env_workflow.xml --id JOB_WALLCLOCK_TIME --val 95:00:00   
  # set up longer time for runing the simulation
  ./xmlchange DOUT_S=TRUE

fi


############################ CREATE FATES PARAM FILE AND SET AS OPTION ##########################################

if [ ${add_fatesparam_namelist} == "T" ]
then

   # Add input file as run parameter to cases
   echo 'fates_paramfile = "~/ctsm/src/fates/parameter_files/SeedClim_PFTs_only_1.1.1.nc"' >> ~/ctsm_cases/${plotname[i]}$suffix/user_nl_clm
  
fi


######################################### RUN CASES ##########################################


if [ ${run_cases} == "T" ]
then
  cd ~/ctsm_cases/${plotname[i]}$suffix
  ./case.submit
fi

done

# Flush modules again
module purge
