function runjobs_parallelized( h_rt, h_vmem, workersrange, fnc, outn, args )
%CAUSET_RUNJOBS_PARALLELIZED runs a task (assigning TASKINDEX) in parallel
% mode.
% 
% Arguments:
% H_RT                SGE wallclock time, e.g. '00:30:00'.
% H_VMEM              at least '3G' to allow for JAVA processes.
% WORKERSRANGE        min and max limits for number of workers to run job, 
%                     e.g. [ 8, 16 ]. 
% FNC                 function handle.
% OUTN                number of output arguments.
% ARGS                cell array of arguments passed to the function.
% 
% Copyright 2021, C. Minz. BSD 3-Clause License.

    %% use parallel computing:
    cluster = parallel.cluster.Generic( 'JobStorageLocation', '/scratch/cm1757/outputs' );
    set( cluster, 'HasSharedFilesystem', true );
    set( cluster, 'ClusterMatlabRoot', '/opt/yarcc/applications/Matlab/R2015a/1/default' );
    set( cluster, 'OperatingSystem', 'unix' );
    set( cluster, 'NumWorkers', workersrange( 2 ) );
    set( cluster, 'CommunicatingSubmitFcn', { @communicatingSubmitFcn, h_rt, h_vmem } );
    set( cluster, 'GetJobStateFcn', @getJobStateFcn );
    set( cluster, 'DeleteJobFcn', @deleteJobFcn );
    pjob = createCommunicatingJob( cluster, 'Type', 'pool' );
    pjob.NumWorkersRange = workersrange;
    %% add the task to the job:
    createTask( pjob, fnc, outn, args );
    submit( pjob );
    %% collect error messages:
    wait( pjob, 'finished' );
    messages = get( pjob.Tasks, { 'ErrorMessage' } );
    nonempty = ~cellfun( @isempty, messages );
    celldisp( errmsgs( nonempty ) );
end

