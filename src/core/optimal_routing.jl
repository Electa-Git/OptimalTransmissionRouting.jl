function do_optimal_routing(input_data)
    
    spatial_data, spatial_data_matrices, cost_data, equipment_data = prepare_spatial_data(input_data)
    c_tot, optimal_path, ac_dc, ac_cab, dc_cab = optimize_route(spatial_data, spatial_data_matrices, cost_data, equipment_data, input_data)
    route_impedance = determine_impedance_parameters(input_data, spatial_data, spatial_data_matrices, optimal_path, equipment_data)
    return spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab, route_impedance 
end