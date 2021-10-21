# OptimalTransmissionRouting.jl

Status:
[![CI](https://github.com/Electa-Git/OptimalTransmissionRouting.jl/workflows/CI/badge.svg)](https://github.com/Electa-Git/OptimalTransmissionRouting.jl/actions?query=workflow%3ACI)
<a href="https://codecov.io/gh/Electa-Git/OptimalTransmissionRouting.jl"><img src="https://img.shields.io/codecov/c/github/Electa-Git/OptimalTransmissionRouting.jl?logo=Codecov"></img></a>
<a href="https://electa-git.github.io/OptimalTransmissionRouting.jl/stable/"><img src="https://github.com/Electa-Git/OptimalTransmissionRouting.jl/workflows/Documentation/badge.svg"></img></a>


OptimalTransmissionRouting.jl is a Julia/JuMP package to determine the optimal transmission system route considering spatial information. The underlying priciple is that spatial information coming from an image file is convertered to an array of installation cost weights (see io/spatial_image_files). To that end spatial infromation from http://www.eea.europa.eu/data-and-maps/data/corine-land-cover-2006-raster-2 is used. The created array represents a weighted graph connecting a number of nodes horizontally, vertiacally and diagonally with graph weights reflecting the installation costs for each region of the map. Using the A-star algorithm, the shortest path in this weighted graph is found, which provides the least cost transmission path.

**Installation**
The latest stable release of OptimalTransmissionRouting.jl can be installed using the Julia package manager with

```julia
Pkg.add("OptimalTransmissionRouting")
```
The current version of OptimalTransmissionRouting.jl is 0.1..

## Citing OptimalTransmissionRouting.jl

If you find OptimalTransmissionRouting.jl useful in your work, we kindly request that you cite the following publications:
[Detailed description of the mathematical model](https://ieeexplore.ieee.org/abstract/document/6746189):
```
@ARTICLE{6746189,
  author={Ergun, Hakan and Rawn, Barry and Belmans, Ronnie and Van Hertem, Dirk},
  journal={IEEE Transactions on Power Systems}, 
  title={Technology and Topology Optimization for Multizonal Transmission Systems}, 
  year={2014},
  volume={29},
  number={5},
  pages={2469-2477},
  doi={10.1109/TPWRS.2014.2305174}}
```
and 
```
@ARTICLE{7293709,
  author={Ergun, Hakan and Rawn, Barry and Belmans, Ronnie and Van Hertem, Dirk},
  journal={IEEE Transactions on Power Systems}, 
  title={Stepwise Investment Plan Optimization for Large Scale and Multi-Zonal Transmission System Expansion}, 
  year={2016},
  volume={31},
  number={4},
  pages={2726-2739},
  doi={10.1109/TPWRS.2015.2480751}}
```

## Acknowledgement
This software implementation is conducted within the European Union’s Horizon  2020 research and innovation programme under the FlexPlan project (grantagreement no. 863819).

## License

This code is provided under a BSD license.
