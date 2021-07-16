import OptimalTransmissionRouting; const OTR = OptimalTransmissionRouting
import Images

# Some branch in Italy

bus1 = Dict{String, Any}()
bus1["longitude"] = 16.2487678
bus1["latitude"] = 40.358515
bus2 = Dict{String, Any}()
bus2["longitude"] = 14.1482998
bus2["latitude"] = 37.5900782

spatial_weights, voltages, resolution = OTR.define_weights_voltages()

rgb_values, nodes_lp, boundaries, plot_dictionary = OTR.convert_image_files_to_weights(bus1, bus2)