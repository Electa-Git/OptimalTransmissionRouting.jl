function determine_impedance_parameters(input_data, spatial_data, spatial_data_matrices, optimal_path, equipment_data)
    r = 0 
    x = 0
    bc = 0
    r_pu = 0
    x_pu = 0
    bc_pu = 0
    km = 0
    km_ohl = 0
    km_ugc = 0
    for idx = 1 : size(optimal_path, 1) - 1
        ohl_cable = ohl_or_cable(spatial_data, spatial_data_matrices, optimal_path[idx], optimal_path[idx + 1])
        r_, x_, bc_, r_pu_, x_pu_, bc_pu_ = get_impedance_data(equipment_data, ohl_cable, input_data)
        km_ = get_segment_distance(spatial_data, spatial_data_matrices, optimal_path[idx], optimal_path[idx + 1])
        
        km = km + km_
        if ohl_cable == "ohl"
            km_ohl = km_ohl + km_
        else
            km_ugc = km_ugc + km_
        end
        r = r + (r_ * km_)
        r_pu = r_pu + (r_pu_ * km_)
        x = x + (x_ * km_)
        x_pu = x_pu +(x_pu_ * km_)

        bc = bc + (bc_ * km_)
        bc_pu = bc_pu + (bc_pu_ * km_)
    end

    route_impedance = Dict{String, Any}()
    route_length = Dict{String, Any}()

    route_length["total_length"] = km
    route_length["ohl_length"] = km_ohl
    route_length["ugc_length"] = km_ugc

    route_impedance["r"] = r
    route_impedance["x"] = x
    route_impedance["bc"] = bc

    route_impedance["r_pu"] = r_pu
    route_impedance["x_pu"] = x_pu
    route_impedance["bc_pu"] = bc_pu

    return route_impedance, route_length
 end


 
 function get_impedance_data(equipment_data::Dict, ohl_cable::String, input_data::Dict)
    technology = input_data["technology"]
    cross_section = equipment_data[ohl_cable]["onshore"]["cross_section"]
    circuits = equipment_data[ohl_cable]["onshore"]["circuits"]
    if ohl_cable == "ohl"
        bundles = input_data[ohl_cable]["onshore"]["bundles"]
    else
        bundles = 1
    end
    r = input_data["impedances"][technology][ohl_cable]["$cross_section"]["r"] / (bundles * circuits)
    x = input_data["impedances"][technology][ohl_cable]["$cross_section"]["x"] / (bundles * circuits)
    bc = input_data["impedances"][technology][ohl_cable]["$cross_section"]["c"] * circuits * 10e-9 * 2 * pi * 50
    
    v_str = join([technology, "_", ohl_cable])
    voltage = input_data["voltages"][v_str]
    Zbase = voltage^2 / 100

    r_pu = r / Zbase
    x_pu = x / Zbase
    bc_pu = bc * Zbase

    return r, x, bc, r_pu, x_pu, bc_pu
 end

 function get_segment_distance(spatial_data::Dict, spatial_data_matrices::Dict, node_id1::Int, node_id2::Int)
    index_s1 = findall(node_id1 .== spatial_data["segments"][:, 2])
    index_s2 = findall(node_id2 .== spatial_data["segments"][:, 3])
    index_s = intersect(index_s1, index_s2)
    if isempty(index_s)
        index_s1 = findall(node_id2 .== spatial_data["segments"][:, 2])
        index_s2 = findall(node_id1 .== spatial_data["segments"][:, 3])
        index_s = intersect(index_s1, index_s2)
    end

    if !isempty(findall(index_s .== spatial_data_matrices["ohl"]["segments"][:, 1]))
        km = spatial_data_matrices["ohl"]["segment_km"][index_s]
    else
        index_ugc = index_s[1] - size(spatial_data_matrices["ohl"]["segments"], 1)
        if !isempty(findall(index_s .== spatial_data_matrices["ugc"]["segments"][:, 1]))
            km = spatial_data_matrices["ugc"]["segment_km"][index_ugc]
        else
            km = 0
        end
    end

    return km
 end