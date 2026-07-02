---
title: 'SynthEddy: A Python program for generating synthetic turbulent flow fields'
tags:
  - Python
  - fluid dynamics
  - turbulent flow
  - computational fluid dynamics
  - large eddy simulation
  - direct numerical simulation
authors:
  - name: Ange (Phil) Du
    orcid: 0009-0009-1049-268X
    # equal-contrib: true
    affiliation: 1
  - name: Nikita Holyev
    affiliation: 1
  - name: Spencer Smith
    orcid: 0000-0002-0760-0987
    affiliation: 1
affiliations:
 - name: McMaster University, Canada
   index: 1
   ror: 02fa3aq29
date: 1 July 2026
bibliography: paper.bib

# Optional fields if submitting to a AAS journal too, see this blog post:
# https://blog.joss.theoj.org/2018/12/a-new-collaboration-with-aas-publishing
# aas-doi: 10.3847/xxxxx <- update this with the DOI from AAS once you know it.
# aas-journal: Astrophysical Journal <- The name of the AAS journal.
---

# Summary

Turbulent flow is characterized by chaotic fluctuations in velocity and pressure. Today, most turbulent computational fluid dynamic (CFD) simulations are based on simplified models, such as the Reynolds-Averaged Navier-Stokes (RANS) equations. While other approaches can reveal more details in the flow, such as Large Eddy Simulation (LES) and Direct Numerical Simulation (DNS), they are often deemed too computationally expensive and thus see limited use in practice. Part of the computational expense is the amount of simulation time needed for turbulence to properly develop from simple initial conditions (IC) and boundary conditions (BC). `SynthEddy` is a Python program that aims to alleviate the start-up computational cost by generating IC and BC for LES using the synthetic eddy method (SEM).  The synthetic eddies are constructed to have the required turbulence characteristics, so simulation time is not needed for proper turbulence to emerge. `SynthEddy` reduces the required simulation scale both in time and space, making LES more accessible to a wider audience. 

# Statement of need

Compared to widely used RANS models in CFD, LES can capture more intricate details of a turbulent flow, down to individual eddies. This can be desirable in many applications or scenarios, such as gas turbine design, airfoil flow separation, construction airflow, ocean studies, and more [@Kim:1999; @You:2008; @VanMaele:2008; @Chamecki:2019]. However, the adoption of LES has been largely limited by its computational cost, which can be orders of magnitude higher than RANS [@Yang:2015].  Not only the model itself is more computationally expensive, but there exists a compounding issue with the initiation of the simulation.

Unlike RANS, which can be described by a few parameters, utilizing LES in any practical manner requires a realistic turbulent flow field running in the simulation. To reach such a state, either prior simulations with longer time and larger field for the turbulent flow to develop are needed (more expensive), or a suitable inlet condition must be synthesized using turbulence generation methods [@Wu2017].  @PolettoEtAl2013 proposed one such method by generating synthetic eddies to mimic a turbulent flow. Compared to previous proposals, such as random fluctuations, this method is divergence free and closer to actual turbulent flow.

`SynthEddy` is a Python implementation based on Poletto's method. SynthEddy models turbulent flow fields consisting of synthetic eddies of various sizes, orientations and intensities. This physical system is shown in \autoref{fig:PS}. The user can generate a turbulent velocity field and query it for use in both turbulence research and as an IC/BC for CFD simulations.

![Physical system\label{fig:PS}](PS.png)

# State of the field

To obtain the appropriate IC/BC, a CFD practitioner can run an actual experiment or use DNS results, but it may not be feasible for these approaches to match the desired situation.  For instance, this would be the case if one desired a DNS at a Reynolds number of 500, but only datasets for Re = 200 are available online.  While these datasets could be used, they would need to be rescaled and still would not accurately represent the desired flow conditions. Similarly, if one perform an experiment to study turbulence over turbine blades at a specific Reynolds number, it is difficult to generalize those results to different Reynolds numbers or flow conditions.

This is why we resort to filtering methods, Fourier methods, or coherent methods (the coherent method is the one used in SynthEddy). These approaches are advantageous because they can be adapted to virtually any flow condition while remaining much more computationally efficient than DNS. However, they can lack realistic turbulence physics. For example, the Fourier method generates a velocity field using sine and cosine waves. These waves do not interact with or depend on one another in the same way as structures in real turbulence. The lack of accuracy in the initial conditions will likely hurt the accuracy of the simulation. If your initial conditions from a turbulence generation method lacks realism, it can take longer for the DNS that is being fed these conditions to converge to realistic values, or even to converge at all.

The Synthetic Eddy Method [@JarrinEtAl2006] is an attempt to be a more realistic representation of turbulence, but in SEM the generated eddies do not satisfy continuity (i.e. conservation of mass).  The synthetic turbulence can be improved by satisfying continuity.  This motivated @PolettoEtAl2013 to propose a new divergence-free synthetic eddy method (DFSEM). This is what our paper is based on. @HaywoodEtAl2021 is a more recent paper that uses a different type of eddies (named Hill's spherical vortex). These eddies look like donuts and the authors claim that this type of structure satisfies Euler's equations. However, the simpler eddies implemented in SynthEddy seem more representative of what is observed in DNS.

Coherent methods (such as SEM or DFSEM) allow one to modify eddies in ways that better represent real turbulent physics. They can resolve the full energy spectrum, prescribe eddy orientations in specific directions, prescribe eddy shape and stretch them, and/or use different eddy densities to better reproduce the turbulent statistics of a wide range of flows (e.g., inhomogeneous and anisotropic flows). As a starting point, SynthEddy currently focuses only on reproducing homogeneous isotropic turbulence.

# Software design

To ensure `SynthEddy` can adapt to different use cases and be easily maintainable and customizable, the program is designed with the following principles:

## Information preserving

A key design philosophy of `SynthEddy` is to preserve as much information as possible in the generated field, hence the separate query process.

Unlike an actual CFD simulation, `SynthEddy` does not use numerical methods to solve the field. Thus, there is no need to discretize the field at the beginning, which can lead to a loss of information. Instead, the eddies are treated as movable individual entities in continuous space and time. The field (or queried region) is only discretized into a meshgrid when queried.

This allows the user to query the same field multiple times with different parameters, such as varying resolution for specific region of interest, or when performing grid sensitivity analysis. When queried at any point in time, the program first finds the location of each eddy at such time analytically, without having to advance through prior time steps numerically.

This opens up the possibility for "salami slicing" the field to obtain BC (as mentioned above) at any arbitrary feeding rate demanded by the user, without concerning grid resolution or time step size.

  

SynthEddy has been verified following the [Verification and Validation Plan](https://smiths.github.io/turbulent-flow/VnVPlan/VnVPlan.pdf), results of which are show in the [Verification and Validation Report](https://smiths.github.io/turbulent-flow/VnVReport/VnVReport.pdf).

## Document driven development

The design and development of `SynthEddy` is driven by various documents in the repository. These documents guide the development process and served as communication bridge between the developer and domain experts. They are also the entry point for future parties looking to perform any significant modification or extension to the program.

Some of the key documents include:

- [Software Requirements Specification (SRS)](https://smiths.github.io/turbulent-flow/SRS/SRS.pdf)
  - Describes the goals, assumptions and requirements of the program.
  - Documents the mathematical models used to build the program, including their relationships and refinements.
    - One such example for a theoretical model is shown in \autoref{fig:TM}.
- [Module Guide (MG)](https://smiths.github.io/turbulent-flow/Design/SoftArchitecture/MG.pdf)
  - Describes the module architecture of the program.
  - The design of the software is based on the principle of information hiding [@Parnas1972a].  That is, the design is decomposed around likely changes, which become the secrets of the modules.
  - Record key design decisions and rationale.
  - The module guide, which includes the uses relation between modules, is based on Parnas's ideas for documenting the software architecture [@ParnasAndWeiss2001; @ParnasEtAl1984]. 
- [Module Interface Specification](https://smiths.github.io/turbulent-flow/Design/SoftDetailedDes/MIS.pdf) 
  - The interface provided by each module
  - The MIS follows the approach presented by Hoffman and Strooper [@HoffmanAndStrooper1995] and later adapted for scientific computing software [@SmithAndYu2009; @ElSheikhEtAl2004].
- [Verification and Validation Plan (VnV Plan)](https://smiths.github.io/turbulent-flow/VnVPlan/VnVPlan.pdf)
  - Describes the testing strategy and test cases.

![Theoretical model example\label{fig:TM}](TM2.png)

## Continuous integration

`SynthEddy` uses continuous integration by GitHub actions to call `pytest` for unit and system testing for every pull request on the main branch.  This ensures that the program is always in a working state throughout the development process.

These tests can also be run locally with instructions in the [README.md](https://github.com/smiths/turbulent-flow/blob/main/README.md#running-the-test-cases). See [VnV Plan](https://smiths.github.io/turbulent-flow/VnVPlan/VnVPlan.pdf) for more details on the test cases.

# Research impact statement

SynthEddy is being used by Nikita Holyev as he works toward his PhD [@HolyevEtAl2021].  As far as we know, SynthEddy is the only tool that has focused on only the synthetic turbulence.  There are other open source tools, like [Code_Saturne](https://www.code-saturne.org/) and [OpenFOAM](https://www.openfoam.com/), that have built-in implementations of DFSEM to generate realistic turbulent fluctuations at the inlet of an LES simulation. OpenFOAM has options for digital filter method, divergence-free synthetic turbulence, and random Fourier modes.

# Features and usage

- Generate synthetic turbulent flow field consisting of eddies.  Users need to provide an eddy profile with the following parameters of each type of eddy to be included in the field:
  - Size (length-scale)
  - Density (number of eddies per unit volume)
  - Intensity magnitude  
- Query velocity vectors in the generated field as a meshgrid, which can be:
  - The whole field.
  - Any subsection of the field.
  - At any point in time after generation.

A quick start guide is provided in the [README.md](https://github.com/smiths/turbulent-flow?tab=readme-ov-file#quick-start) of the repository.

The generated field is fully wrapped around on all boundaries, ensuring conservation of mass. Details on how wrapping is handled in different flow scenarios can be found in the [Module Guide (MG)](https://smiths.github.io/turbulent-flow/Design/SoftArchitecture/MG.pdf) (see Field Wrap-around section).

The query result is saved as a NumPy array (`.npy` file) representing velocity vectors in a 3D meshgrid, with a shape of `(Nx, Ny, Nz, 3)` where `N` is the number of grid points in each direction, and the last dimension represents $x$, $y$, and $z$ components of the velocity vector.

A velocity magnitude cross-section plot example from a $1000^3$ meshgrid is shown in \autoref{fig:result}.

![Result cross-section example\label{fig:result}](result.png)

## Customization

`SynthEddy` allows the user to easily program certain aspects of the generated field to better suit their specific needs. This includes:

- Non-uniform mean velocity distribution.  
  Instead of inputting a constant mean velocity across the field, the user can provide a function to obtain mean $x$-velocity ($\overline{\mathbf{u}}$) based on $y$- and $z$-coordinates. This is useful for simulation of channel flows and boundary layers.
- Eddy shape function.
  A function that describes the velocity distribution of individual eddies.

  Detailed explanation on editing these functions can be found in the [README.md](https://github.com/smiths/turbulent-flow/blob/main/README.md#customization).

## Typical use case

- Whole field (IC and research)  
  To initiate a CFD simulation, the user can generate a field and query its entirety at $t=0$ to obtain the initial condition. This use case can also be used in turbulent research, such as turbulent energy spectrum analysis. Depending on the size of the field and query meshgrid resolution, this can take significant time and memory.
- Salami slicing (BC)  
  In a continuously running CFD simulation, the user can keep querying a thin subsection of the field with advancing time, and feed the results as inlet boundary conditions to the simulation. Since the region is much smaller than the whole field, this can be done significantly faster.  
  `SynthEddy` allows querying any subsection of the same field at any time, and ensures continuity between different queried space and time. See [Information preserving](#information-preserving) for more details.

## Performance and benchmark

To improve performance on large meshgrid, the grid is divided into chunks for efficient batch processing. This is detailed in the [Module Guide (MG)](https://smiths.github.io/turbulent-flow/Design/SoftArchitecture/MG.pdf) (see Chunking section).
A benchmark test is included in the repository (see [README.md](https://github.com/smiths/turbulent-flow/blob/main/README.md#running-the-test-cases)).
On an Intel i9-13900K CPU, with a $1000^3$ meshgrid and around 10 million eddies, the run time is approximately 1 hour.

# AI Usage Disclosure

AI was not used for coding or documentation.  However, AI was used for brainstorming content for the [CONTRIBUTING.md](https://github.com/smiths/BridgeChlorideExposurePredictor/blob/main/CONTRIBUTING.md) guide, the [CodeOfConduct.md](https://github.com/smiths/BridgeChlorideExposurePredictor/blob/main/CodeOfConduct.md) and the continuous deployment of the documentation via a [GitHub Action](https://github.com/smiths/BridgeChlorideExposurePredictor/blob/main/.github/workflows/latex-pages.yml).  In these cases the tool used was ChatGPT based on GPT-5.5.  In addition, Claude (Sonnet 5) was used to modify the human-written Makefile so that it is operating system agnostic. The human authors have reviewed, verified and edited all AI suggested text and scripts.

# Acknowledgements

We acknowledge the insights and suggestions from Dr. Marilyn Lightstone and Dr. Stephen Tullis during the development of this program and the preparation of this paper.

# References