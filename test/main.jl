import OptimalTransmissionRouting; const OTR = OptimalTransmissionRouting

spatial_weights, voltages, resolution = OTR.define_weights_voltages()

rgb_values, nodes_lp, id, boundaries, plot_dictionary = OTR.convert_image_files_to_weights()