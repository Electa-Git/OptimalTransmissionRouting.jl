function do_optimal_routing(input_data)
    
    spatial_data = prepare_spatial_data(input_data)
    return spatial_data

end



function prepare_spatial_data(input_data)
   
    # OHL
    nodes, node_weights, onshore_nodes, segments, segment_weights, segment_km, onshore_flag = make_spatial_matrices(input_data; equipment = "ohl")
    


#    nodes, segments, node_weights, segment_weights, segment_distance, onshore_flag, onshore_nodes = 

    spatial_data_matrices = Dict{String, Any}()
    spatial_data_matrices["nodes"] = nodes
    spatial_data_matrices["node_weights"] = node_weights
    spatial_data_matrices["segments"] = segments
    spatial_data_matrices["segment_weights"] = segment_weights
    spatial_data_matrices["segment_km"] = segment_km
    spatial_data_matrices["onshore_flag"] = onshore_flag
    spatial_data_matrices["onshore_nodes"] = onshore_nodes

    return spatial_data_matrices
end


function make_spatial_matrices(input_data; equipment = "ohl")
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


    return nodes, node_weights, onshore_nodes, segments, segment_weights, segment_km, onshore_flag
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

    onshore_flag[end-size(X,1)+2:end] =minimum(onshore_nodes[end-size(X,1)+1:end-1],onshore_nodes[Int.(segments[end-size(X,1)+2:end,2] .+ 1)])
    segment_km[end-size(X,1)+2:end] = delta_y

    return segments, segment_weights, segment_km, onshore_flag
end