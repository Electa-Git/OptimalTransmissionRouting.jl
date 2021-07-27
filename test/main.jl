import OptimalTransmissionRouting; const OTR = OptimalTransmissionRouting
import Images
using ColorTypes
using Plots

# Some branch in Italy

bus1 = Dict{String, Any}()
bus1["longitude"] = 16.2487678
bus1["latitude"] = 40.358515
bus2 = Dict{String, Any}()
bus2["longitude"] = 14.1482998
bus2["latitude"] = 37.5900782

# strategy = "all_permitted"
# strategy = "OHL_on_existing_corridors"
strategy = "cables_only"

spatial_weights, voltages, resolution = OTR.define_weights_voltages(strategy)

rgb_values, nodes_lp, boundaries, plot_dictionary = OTR.convert_image_files_to_weights(bus1, bus2)  

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

@time spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab  = OTR.do_optimal_routing(input_data)
OTR.plot_result(plot_dictionary, input_data, spatial_data, spatial_data_matrices, optimal_path)