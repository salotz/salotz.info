

## Examol

Formerly Ibeks Technologies.

Cofounder and CTO.

Working on a cloud-native Kubernetes application for computational drug-discovery.

Designed and implemented our entire server backend in fully statically typed
Python code using the Starlette web server.

## Roivant Sciences

I work closely with computational scientists on drug discovery teams
to develop simulation and ML pipelines. This includes bespoke
solutions and general libraries for performing highly scalable
analysis platforms tuned for massive simulation data.

In addition I have worked on various aspects of DevOps, workflow
orchestration, and data engineering in a a cloud-HPC hybrid
organization.

This has included extensive experience with package management,
deployment, and compilation of complex sets of dependencies via the
excellent [Spack](https://spack.io/) package manager.

## PhD Related

### Thesis Project: Drug Unbinding Transition-State Plasticity

My main thesis project is to investigate the plasticity of ligand
unbinding transition states from receptor binding sites.

This is of interest to drug designers which are looking to tailor the
kinetic properties of drugs. Such kinetics oriented design can have
impacts on drug efficacy and practical improvements of drugs by
decreasing the frequency of dosing and avoiding side effects by
improving windows of efficacy.

This project pipeline is multipart.

First, we perform molecular dynamics (MD) simulations of drug molecules
unbinding from their protein targets using supercomputer clusters of
graphics processing units (GPUs).

Because the unbinding process is a slow one (relative to the timescale
of the MD simulations) novel enhanced sampling algorithms must be used
in order to speed up the simulations without disturbing the physical
correctness of the structures we observe.

Primarily this is the `WExplore` algorithm which was implemented in my
*weighted ensemble* simulation library [wepy](https://github.com/ADicksonLab/wepy). 

These methods are similar to Markov State Monte Carlo (MCMC), particle
methods, and other importance sampling techniques and are applicable
outside of biophysics for estimating probabilities of rare events.

Second, a number of machine learning and custom data mining methods
are applied to extract meaning from the "raw" simulation data in a
distributed fashion.

This includes geometric constraint queries using the [mastic](https://github.com/ADicksonLab/mastic) and [geomm](https://github.com/ADicksonLab/geomm)
libaries, as well as custom analyses with `numpy` and `scipy``.

I also perform machine learning analyses using `sckit-learn` for
clustering and PCA as well as a number of libraries specific to the
field for building Markov State Models and calculating stochastic
network properties via Transition Path Theory.

I have leveraged the distributed computing framework [dask](https://github.com/dask/dask) to scale the
analysis of terabytes of simulation data.

The results of this research so far have been published or are still
in progress.

### Results

Thesis:
- [Thesis](link:///resources/thesis.pdf)

Papers:
- [Unbiased Molecular Dynamics of 11 min Timescale Drug Unbinding Reveals Transition State Stabilizing Interactions](https://pubs.acs.org/doi/abs/10.1021/jacs.7b08572)

Data:
- [zenodo](https://zenodo.org/record/1021565)

Posters and Conferences:
- [Unbiased Molecular Dynamics of 11 min Timescale Drug Unbinding Reveals Transition State Stabilizing Residues](https://zenodo.org/record/439376) 


## Demos

- [Godot 2D Creeps](link:///demos/godot-2d-creeps)
