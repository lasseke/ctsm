#!/bin/bash
plotname=(ALP1 ALP2 ALP3 ALP4 SUB1 SUB2 SUB3 SUB4 BOR1 BOR2 BOR3 BOR4)
suffix="_4PFTs_1.1.1"

creat_paramfile="T"               # T or F, switch for creating script grid or not
run_cases="F"                     # T or F, run cases with new parameter files?

fates_paramfile_name="SeedClim_PFTs_only_1.1.1" # Name of new paramfile you wish to create

run_startdate="0001-01-01"
run_years=5
run_resubmit=10
run_atmforcing_startyr=1901
run_atmforcing_endyr=1950
run_jobtime="08:00:00"


if [ ${creat_paramfile} == "T" ]
then
  #source activate cesm
  module load netCDF-Fortran/4.4.4-intel-2018b 
  module load Python/3.6.6-intel-2018b 

  ~/ctsm/src/fates/tools/FatesPFTIndexSwapper.py --pft-indices=7,8,9,10,11 --fin=~/ctsm/src/fates/parameter_files.nc --fout=~/ctsm/src/fates/parameter/$fates_paramfile_name.nc

  ncgen -o ~/ctsm/src/fates/parameter/SeedClim_PFTs_only_1.1.1.nc ~/ctsm/src/fates/parameter/$fates_paramfile_name.cdl

  len=${#plotname[@]}
  for (( i=0; i<$len; i++ ))
  do
    cd ~/ctsm_cases/$(plotname[i])$suffix 
    source activate cesm

    ./xmlchange --file env_run.xml --id RUN_STARTDATE --val $run_startdate                    # set up the starting date of your simulation
    ./xmlchange --file env_run.xml --id STOP_OPTION --val nyears                              # set the simulation periods to "years"
    ./xmlchange --file env_run.xml --id STOP_N --val $run_years                               # set the length of simulation, i.e, how many years
    ./xmlchange --file env_run.xml --id CONTINUE_RUN --val TRUE                               # if you want to continue your simulation from restart file, set it to TRUE
    ./xmlchange --file env_run.xml --id RESUBMIT --val $run_resubmit                          # set up how many times you want to resubmit your simulation.
                                                                                            # e.g, STOP_N=5, RESUBMIT=10, you will have simulation for 5+5*10=55
    ./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val $run_atmforcing_startyr   # set up the start year of the atmospheric forcing
    ./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END --val $run_atmforcing_endyr       # set up the end year of the atmospheric forcing
    ./xmlchange --file env_workflow.xml --id JOB_WALLCLOCK_TIME --val $run_jobtime            # set up longer time for runing the simulation
    ./xmlchange DOUT_S=TRUE

    # Specify input files
    echo 'fates_paramfile=~/ctsm/src/fates/parameter/$fates_paramfile_name.nc' >> ~/ctsm_cases/$(plotname[i])$suffix/user_nl_clm

  done
fi

if [ ${run_cases} == "T" ]
then
  len=${#plotname[@]}
  for (( i=0; i<$len; i++ ))
  do
    ~/ctsm/src/fates/tools/FatesPFTIndexSwapper.py --pft-indices=7,8,9,10,11 --fin=~/src/fates/parameter_files.nc --fout=~/ctsm_cases/$(plotname[i])$suffix/param/SeedClim_PFTs_firstexperiment.nc

  done
fi

module purge
