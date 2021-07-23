function prepare_spatial_data(input_data)
    # OHL
    spatial_data_ohl, costs_ohl, equipment_data_ohl = build_spatial_matrices_and_cost_data(input_data; equipment = "ohl")
    spatial_data_ugc, costs_ugc, equipment_data_ugc = build_spatial_matrices_and_cost_data(input_data; equipment = "ugc")

    spatial_data = merge_maps(spatial_data_ohl, costs_ohl, spatial_data_ugc, costs_ugc, input_data)

    spatial_data_matrices = Dict{String, Any}()
    cost_data = Dict{String, Any}()
    equipment_data = Dict{String, Any}()
    spatial_data_matrices["ohl"] = spatial_data_ohl
    spatial_data_matrices["ugc"] = spatial_data_ugc
    cost_data["ohl"] = costs_ohl
    cost_data["ugc"] = costs_ugc
    equipment_data["ohl"] = equipment_data_ohl
    equipment_data["ugc"] = equipment_data_ugc

    return spatial_data, spatial_data_matrices, cost_data, equipment_data
end


function build_spatial_matrices_and_cost_data(input_data; equipment = "ohl")
    # prepare boundaries
    xmax = size(input_data["rgb_values"]["sea"], 2) + 1
    ymax = size(input_data["rgb_values"]["sea"], 1) + 1

    x_border_min = Int(input_data["boundaries"]["xmin"])
    x_border_max = Int(input_data["boundaries"]["xmax"])
    y_border_min = Int(input_data["boundaries"]["ymin"])
    y_border_max = Int(input_data["boundaries"]["ymax"])

    x_node_min = Int(min(input_data["start_node"]["x"], input_data["end_node"]["x"]))
    x_node_max = Int(max(input_data["start_node"]["x"], input_data["end_node"]["x"]))
    y_node_min = Int(min(input_data["start_node"]["y"], input_data["end_node"]["y"]))
    y_node_max = Int(max(input_data["start_node"]["y"], input_data["end_node"]["y"]))

    delta_x = Int(max(input_data["resolution_factor"],(x_node_max-x_node_min)/xmax))
    delta_y = Int(max(input_data["resolution_factor"],(y_node_max-y_node_min)/ymax))

    # make grid
    x = x_border_min : delta_x : x_border_max
    y = y_border_min : delta_y : y_border_max  

    X = x' .* ones(size(y, 1))
    Y = (ones(size(x, 1)))' .*  y


    node_weights = Dict{String, Any}()
    for (area_idx, area) in input_data["rgb_values"]
        node_weights[area_idx] = assign_rgb_values(X, Y, x, y, input_data, area_idx)
    end

    onshore_nodes = ones(size(node_weights["sea"],1),1)
    onshore_nodes = 1 .- node_weights["sea"][:,4]

    nodes = node_weights["sea"][:, 1:3]

    equipment_ = join([input_data["technology"],"_",equipment])    
    node_weights = assign_node_weights(node_weights, input_data, equipment_)

    segments, segment_weights, segment_km, onshore_flag = create_segments_and_segment_weights(nodes, node_weights, onshore_nodes, input_data, X, Y, x, y, delta_x, delta_y)

    costs, equipment_details = calculate_costs_and_losses(input_data; equipment)

    spatial_data = Dict{String, Any}()
    spatial_data["nodes"] = nodes
    spatial_data["node_weights"] = node_weights
    spatial_data["onshore_nodes"] = onshore_nodes
    spatial_data["segments"] = segments
    spatial_data["segment_weights"] = segment_weights
    spatial_data["segment_km"] = segment_km
    spatial_data["onshore_flag"] = onshore_flag
    return spatial_data, costs, equipment_details
end


function assign_rgb_values(X, Y, x, y, input_data, area)
    nodes_w = zeros(size(x, 1) * size(y, 1), 4)
    for idx = 1 : size(X, 2)
        nodes_w[((idx-1) * size(X,1)+1) : idx * size(X,1) ,1] = ((idx-1) * size(X,1)+1) :idx * size(X,1)
        nodes_w[((idx-1) * size(X,1)+1) : idx * size(X,1), 2] = X[:, idx]
        nodes_w[((idx-1) * size(X,1)+1) : idx * size(X,1), 3] = Y[:, idx]
        nodes_w[((idx-1) * size(X,1)+1) : idx * size(X,1), 4] = input_data["rgb_values"][area][x[idx], y]
    end
    return nodes_w
end

function assign_node_weights(node_weights, input_data, equipment)

    for (area, value) in input_data["spatial_weights"][equipment]
        node_weights[area][:, 4] = node_weights[area][:, 4] * input_data["spatial_weights"][equipment][area]
    end

    node_weights_ = zeros(size(node_weights["sea"]))
    node_weights_[:, 1:3] = node_weights["sea"][:, 1:3]
    for idx = 1:size(node_weights_, 1)
        for (area, value) in node_weights
            if node_weights_[idx, 4] == 0 && node_weights[area][idx, 4] !=0
                node_weights_[idx, 4] = node_weights[area][idx, 4]
            end
            if node_weights_[idx, 4] != 0 && node_weights[area][idx, 4] !=0
                if input_data["overlapping_area_weight"] == "minimum"
                    node_weights_[idx, 4] = min(node_weights[area][idx, 4], node_weights_[idx, 4])
                else 
                    node_weights_[idx, 4] = (node_weights[area][idx, 4] + node_weights_[idx, 4]) / 2
                end
            end
        end
        node_weights_[idx, 4] = max(1, node_weights_[idx, 4])
    end

    return node_weights_
end


function create_segments_and_segment_weights(nodes, node_weights, onshore_nodes, input_data, X, Y, x, y, delta_x, delta_y)

    segments = zeros((length(x)-1)*length(y)+(length(y)-1)*length(x)+2*((length(x)-1)*(length(y)-1)),3);
    segments[:,1]=(1:size(segments,1))'
    segment_weights=ones(size(segments,1),1)
    onshore_flag=ones(size(segments,1),1)
    segment_km=ones(size(segment_weights))

    # Construct all segments: Up, to the side, and diagonal up.
    for idx = 1 : size(X, 2) - 1
        # PART1 
        segments[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] = nodes[((idx-1)*size(X,1)+1):idx*size(X,1),1]
        segments[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx,3] = segments[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ 1
        if input_data["overlapping_area_weight"] == "minimum"
            segment_weights[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum(node_weights[((idx-1)*size(X,1)+1):idx*size(X,1), 4],node_weights[segments[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2+1],4])
        elseif input_data["overlapping_area_weight"] == "average"
            w1 = node_weights[((idx-1)*size(X,1)+1):idx*size(X,1),4]
            w2 = node_weights[Int.(segments[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ 1), 4]
            segment_weights[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = (w1 + w2) ./ 2
        else
            print("Overlapping area weight must be average or minimum")
        end
        idx_ = Int.(segments[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2].+1)
        idx__ = ((idx-1)*size(X,1)+1):idx*size(X,1)
        onshore_flag[(4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum([onshore_nodes[idx__],onshore_nodes[idx_]])
        segments[4*idx*size(X,1)-3*idx,3] = segments[4*idx*size(X,1)-3*idx,2]+size(X,1)
        idx1 = (4*(idx-1)*size(X,1)+1-3*(idx-1)):4:4*idx*size(X,1)-3*idx
        segment_km[idx1] = sqrt.((nodes[Int.(segments[idx1,2]),2]-nodes[Int.(segments[idx1,3]),2]).^2+(nodes[Int.(segments[idx1,2]),3]-nodes[Int.(segments[idx1,3]),3]).^2)
        # PART 2
        segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] = nodes[((idx-1)*size(X,1)+1):idx*size(X,1)-1,1]
        segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,3] = segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1)
        if input_data["overlapping_area_weight"] == "minimum"
            segment_weights[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = mininimum(node_weights[((idx-1)*size(X,1)+1):idx*size(X,1)-1, 4],node_weights[segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2]+size(X,1), 4])
        elseif input_data["overlapping_area_weight"] == "average"
            w1 = node_weights[((idx-1)*size(X,1)+1):idx*size(X,1)-1, 4]
            w2 = node_weights[Int.(segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1)), 4]
            segment_weights[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = (w1 + w2) ./ 2
        else
            print("Overlapping area weight must be average or minimum")
        end
        idx__ = Int.(((idx-1)*size(X,1)+1):idx*size(X,1) .- 1)
        idx_ = Int.(segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1))
        onshore_flag[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum([onshore_nodes[idx__],onshore_nodes[idx_]])
        idx1 = Int.((4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx)
        segment_km[idx1] = sqrt.((nodes[Int.(segments[idx1,2]),2]-nodes[Int.(segments[idx1,3]),2]).^2+(nodes[Int.(segments[idx1,2]),3]-nodes[Int.(segments[idx1,3]),3]).^2)
        #PART 3
        segments[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] = nodes[((idx-1)*size(X,1)+1):idx*size(X,1)-1,1]
        segments[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx,3] = segments[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1) .+ 1
        if input_data["overlapping_area_weight"] == "minimum"
            segment_weights[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum(node_weights[((idx-1)*size(X,1)+1):idx*size(X,1)-1, 4], node_weights[segments[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] + size(X,1)+1, 4])
        elseif input_data["overlapping_area_weight"] == "average"
            w1 = node_weights[((idx-1)*size(X,1)+1):idx*size(X,1)-1, 4]
            w2 = node_weights[Int.(segments[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1) .+ 1), 4]
            segment_weights[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = (w1 + w2) ./ 2
        else
            print("Overlapping area weight must be average or minimum")
        end
        idx__ = Int.(((idx-1)*size(X,1)+1):idx*size(X,1)-1)
        idx_ = Int.(segments[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1) .+ 1)
        onshore_flag[(4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum([onshore_nodes[idx__],onshore_nodes[idx_]])
        idx1 = Int.((4*(idx-1)*size(X,1)+3-3*(idx-1)):4:4*idx*size(X,1)-3*idx)
        segment_km[idx1]=sqrt.((nodes[Int.(segments[idx1,2]),2]-nodes[Int.(segments[idx1,3]),2]).^2+(nodes[Int.(segments[idx1,2]),3]-nodes[Int.(segments[idx1,3]),3]).^2)
        #PART 4
        segments[(4*(idx-1)*size(X,1)+4-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] = nodes[((idx-1)*size(X,1)+1)+1:idx*size(X,1),1]
        segments[(4*(idx-1)*size(X,1)+4-3*(idx-1)):4:4*idx*size(X,1)-3*idx,3] = segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1)
        if input_data["overlapping_area_weight"] == "minimum"
            segment_weights[(4*(idx-1)*size(X,1)+4-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum(node_weights[((idx-1)*size(X,1)+1)+1:idx*size(X,1), 4],node_weights[segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2]+size(X,1), 4])
        elseif input_data["overlapping_area_weight"] == "average"
            w1 = node_weights[((idx-1)*size(X,1)+1)+1:idx*size(X,1), 4]
            w2 = node_weights[Int.(segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1)), 4]
            segment_weights[(4*(idx-1)*size(X,1)+4-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = (w1 + w2) ./ 2
        else
            print("Overlapping area weight must be average or minimum")
        end
        idx__ = ((idx-1)*size(X,1)+1)+1:idx*size(X,1)
        idx_ = Int.(segments[(4*(idx-1)*size(X,1)+2-3*(idx-1)):4:4*idx*size(X,1)-3*idx,2] .+ size(X,1))
        onshore_flag[(4*(idx-1)*size(X,1)+4-3*(idx-1)):4:4*idx*size(X,1)-3*idx] = minimum([onshore_nodes[idx__],onshore_nodes[idx_]])
        idx1 = Int.((4*(idx-1)*size(X,1)+4-3*(idx-1)):4:4*idx*size(X,1)-3*idx)
        segment_km[idx1]=sqrt.((nodes[Int.(segments[idx1,2]),2]-nodes[Int.(segments[idx1,3]),2]).^2+(nodes[Int.(segments[idx1,2]),3]-nodes[Int.(segments[idx1,3]),3]).^2)
    end

    segments[end-size(X,1)+2:end,2] = nodes[end-size(X,1)+1:end-1,1]
    segments[end-size(X,1)+2:end,3] = segments[end-size(X,1)+2:end,2] .+ 1
    if input_data["overlapping_area_weight"] == "minimum"
        segment_weights[end-size(X,1)+2:end] = minimum(node_weights[end-size(X,1)+1:end-1, 4], node_weights[Int.(segments[end-size(X,1)+2:end, 2] .+ 1) , 4])
    elseif input_data["overlapping_area_weight"] == "average"
        w1 = node_weights[end-size(X,1)+1:end-1, 4]
        w2 = node_weights[Int.(segments[end-size(X,1)+2:end,2] .+ 1), 4]
        segment_weights[end-size(X,1)+2:end] = (w1 + w2) ./ 2
    else
        print("Overlapping area weight must be average or minimum")
    end

    onshore_flag[end-size(X,1)+2:end] = onshore_nodes[Int.(segments[end-size(X,1)+2:end,2] .+ 1)] .* onshore_nodes[end - size(X,1) + 1 : end-1]
    segment_km[end - size(X,1) + 2 : end] .= delta_y * input_data["resolution_factor"]

    return segments, segment_weights, segment_km, onshore_flag
end

function merge_maps(spatial_data_ohl, costs_ohl, spatial_data_ugc, costs_ugc, input_data)
    costs_ohl["ohl_km"] = spatial_data_ohl["segment_km"] .* (spatial_data_ohl["segment_weights"] .* costs_ohl["installation"] .+ costs_ohl["investment"]) ./ input_data["resolution_factor"]
    costs_ugc["ugc_km"] = spatial_data_ugc["segment_km"] .* ((spatial_data_ugc["segment_weights"] .* ((costs_ugc["onshore"]["installation"] .* spatial_data_ugc["onshore_flag"]) .+ (costs_ugc["offshore"]["installation"] .* (1 .- spatial_data_ugc["onshore_flag"])))) .+ ((costs_ugc["onshore"]["investment"] .* spatial_data_ugc["onshore_flag"]) .+ (costs_ugc["offshore"]["investment"] .* (1 .- spatial_data_ugc["onshore_flag"])))) ./ input_data["resolution_factor"]

    # Update segment weights based on costs
    spatial_data_ohl["segment_weights"] = (spatial_data_ohl["segment_weights"] .* costs_ohl["installation"] .+ costs_ohl["investment"]) .* input_data["resolution_factor"]
    spatial_data_ugc["segment_weights"] = ((spatial_data_ugc["segment_weights"] .* ((costs_ugc["onshore"]["installation"] .* spatial_data_ugc["onshore_flag"]) .+ (costs_ugc["offshore"]["installation"] .* (1 .- spatial_data_ugc["onshore_flag"])))) .+ ((costs_ugc["onshore"]["investment"] .* spatial_data_ugc["onshore_flag"]) .+ (costs_ugc["offshore"]["investment"] .* (1 .- spatial_data_ugc["onshore_flag"])))) .* input_data["resolution_factor"]

    # # Connect OHL and UGC maps 
    # # Step 1) Shift node indexes for the UGC map with the number of nodes for OHL
    spatial_data_ugc["segments"][:, 1] = spatial_data_ugc["segments"][:, 1] .+ size(spatial_data_ohl["segments"], 1)
    spatial_data_ugc["segments"][:, 2:3] = spatial_data_ugc["segments"][:, 2:3] .+ size(spatial_data_ohl["nodes"], 1)
    spatial_data_ugc["nodes"][:, 1] = spatial_data_ohl["nodes"][:,1] .+ size(spatial_data_ohl["nodes"], 1)

    spatial_data = Dict{String, Any}()
    spatial_data["segments"] = [spatial_data_ohl["segments"]; spatial_data_ugc["segments"]]
    spatial_data["nodes"] = [spatial_data_ohl["nodes"]; spatial_data_ugc["nodes"]]
    spatial_data["onshore_nodes"] = [spatial_data_ohl["onshore_nodes"]; spatial_data_ugc["onshore_nodes"]]
    spatial_data["segment_weights"] = [spatial_data_ohl["segment_weights"]; spatial_data_ugc["segment_weights"]]
    spatial_data["onshore_flag"] = [spatial_data_ohl["onshore_flag"]; spatial_data_ugc["onshore_flag"]]

    # # Step 2) Connect OHL and UGC maps at each X, Y point (node) via a new segment
    number_of_additional_segments = size(spatial_data_ohl["nodes"], 1)

    segment_idx = 1 : (spatial_data["segments"][end, 1] + number_of_additional_segments)
    segment_from_node =  [spatial_data["segments"][:, 2]; spatial_data_ohl["nodes"][:, 1]]
    segment_to_node = [spatial_data["segments"][:, 3]; spatial_data_ugc["nodes"][:, 1]]

    spatial_data["segments"] = [segment_idx segment_from_node segment_to_node]
    spatial_data["segment_weights"] = [spatial_data["segment_weights"]; zeros(number_of_additional_segments, 1)]
    spatial_data["onshore_flag"] = [spatial_data["onshore_flag"]; ones(number_of_additional_segments, 1)]
    spatial_data["ohl_ugc_transition"] = [zeros(2 * size(spatial_data["segments"], 1)); ones(number_of_additional_segments, 1)]

    return spatial_data
end