# OptimalTransmissionRouting.jl Documentation

```@meta
CurrentModule = OptimalTransmissionRouting
```

## Overview

OptimalTransmissionRouting.jl is a Julia/JuMP package to determine the optimal transmission system route considering spatial information. The underlying priciple is that spatial information coming from an image file is convertered to an array of installation cost weights (see io/spatial_image_files). To that end spatial infromation from http://www.eea.europa.eu/data-and-maps/data/corine-land-cover-2006-raster-2 is used. The created array represents a weighted graph connecting a number of nodes horizontally, vertiacally and diagonally with graph weights reflecting the installation costs for each region of the map. Using the A-star algorithm, the shortest path in this weighted graph is found, which provides the least cost transmission path.

Developed by:
- Hakan Ergun KU Leuven / EnergyVille

**Installation**
The latest stable release of OptimalTransmissionRouting.jl can be installed using the Julia package manager with

```julia
Pkg.add("OptimalTransmissionRouting")
```

## Usage

The first step is to define the locations of the sending and recieving end buses in latitude and longitude using a dictionary, e.g.,
```julia
bus1 = Dict{String, Any}()
bus1["longitude"] = 16.2487678
bus1["latitude"] = 40.358515
bus2 = Dict{String, Any}()
bus2["longitude"] = 14.1482998
bus2["latitude"] = 37.5900782
```

First using:
```julia
spatial_weights, voltages, resolution = OTR.define_weights_voltages(strategy)
``` 
the spatial weights can be defined, which uses the chosen strategy as input as a string. The possible options are:

```julia
strategy = "all_permitted"
strategy = "OHL_on_existing_corridors"
strategy = "cables_only"
```
Furter the vertices of the graph are created, assinging each vertex to one or more spatial regions, e.g., urban, mountain, sea, ....., using:
```julia
rgb_values, nodes_lp, boundaries, plot_dictionary = OTR.convert_image_files_to_weights(bus1, bus2)  
```

Additional input data is required as a dictionary, which is provided below:
```julia
#define inputs
input_data = Dict{String, Any}()

input_data["resolution_factor"] = 2 # resolution_factor 1,2,3, ... to speed up algorithm
input_data["algorithm_factor"] = 1 # algorithm_factor 1.....1.3 to speed up Astar algorithm, goes at expense of accuracy
input_data["distance"] = 2.5  # do not change: this is the standard resolution of the environmental data
input_data["algorithm"] = "Astar"  # "Astar" or "Dijkstra"
input_data["voltages"] = voltages # transmission voltages
input_data["spatial_weights"] = spatial_weights # spatial weights
input_data["rgb_values"] = rgb_values # Spatial data as RGB values
input_data["boundaries"] = boundaries # VBoundaries of the area (to avoid using full European range)
input_data["overlapping_area_weight"] = "average" # "average" = average weight of the spatial weights; "minimum" = minimum of the overlapping weights
input_data["strategy"] = strategy # or "OHL_on_existing_corridors" or "cables_only"
input_data["losses"] = 0.01 # proxy for losses
input_data["lifetime"] = 30 # lifetime: NOT USED in FLEXPLAN
input_data["interest"] = 0.02 # Interest: NOT USED in FLEXPLAN 
input_data["technology"] = "dc" # or "dc"
input_data["power_rating"] = 2000 # power rating
input_data["start_node"] = Dict{String, Any}()
input_data["start_node"]["x"] = nodes_lp["x1"]
input_data["start_node"]["y"] = nodes_lp["y1"] 
input_data["end_node"] = Dict{String, Any}()
input_data["end_node"]["x"] = nodes_lp["x2"]
input_data["end_node"]["y"] = nodes_lp["y2"] 
```
Finally, the creation of the edges of the graph and the optimisation of the route is carried out using:

```julia
spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab  = OTR.do_optimal_routing(input_data)
```
During the route optimisation, following aspects are considered:
- Maximum offshore length for AC cables
- Costs for switching between overhead lines and underground cables, e.g., transition station costs
- In case of HVDC technology: Costs of the converter stations
- Chosen strategy:
-- OHL can be installed everywhere (depending on the chosen weights)
-- OHL can only be installed in existing infrastructure corridors
-- Only underground cables can be installed
- If certain vertices belong to multiple spatial areas, which weight should be chosen:
-- The average of both weights
-- The minimum of both weights

Also using the function:
```julia
OTR.plot_result(plot_dictionary, input_data, spatial_data, spatial_data_matrices, optimal_path)
```
a PDF of the obtained solution can be created.