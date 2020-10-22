### Create control run case to ensure comparability

# Unload modules
module purge
#source activate cesm

# Create control run case, BOR1 from SeedClim
#cd ~/ctsm/cime/scripts
#./create_newcase --case ~/ctsm_cases/BOR1_controlrun_1.1.1 --compset 2000_DATM%1PTGSWP3_CLM50%FATES_SICE_SOCN_MOSART_SGLC_SWAV --res 1x1_BOR1 --machine saga --run-unsupported --project nn2806k

# Go to directory and build case
cd  ~/ctsm_cases/BOR1_controlrun_1.1.1
#./case.setup
#./case.build

################################ Change model run parametrization ###############

### Load relevant modules to manipulate input files
#module load netCDF-Fortran/4.4.4-intel-2018b
#module load Python/3.6.6-intel-2018b

# Change run parameters in case
./xmlchange --file env_run.xml --id RUN_STARTDATE --val 0001-01-01      # set up the starting date of your simulation 
./xmlchange --file env_run.xml --id STOP_OPTION --val nyears            # set the simulation periods to "years"
./xmlchange --file env_run.xml --id STOP_N --val 500                     # set the length of simulation, i.e, how many years
./xmlchange --file env_run.xml --id CONTINUE_RUN --val FALSE             # if you want to continue your simulation from restart file, set it to TRUE
./xmlchange --file env_run.xml --id RESUBMIT --val 3                   # set up how many times you want to resubmit your simulation.
                                                                        # e.g, STOP_N=5, RESUBMIT=10, you will have simulation for 5+5*10=55 
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_START --val 1901    # set up the start year of the atmospheric forcing 
./xmlchange --file env_run.xml --id DATM_CLMNCEP_YR_END --val 1930      # set up the end year of the atmospheric forcing
./xmlchange --file env_workflow.xml --id JOB_WALLCLOCK_TIME --val 95:00:00   # set up longer time for runing the simulation 
./xmlchange DOUT_S=TRUE


################################## Run case! ####################################

#./case.submit
