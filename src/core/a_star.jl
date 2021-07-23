function optimize_route(spatial_data, spatial_data_matrices, cost_data, equipment_data, input_data)

    # weights_ac = snw.weights_ac_cable;
    # snw.meanweight_ac=alg_fac*min(weighy_ac(weighy_ac~=0));
    # weighy_dc=snw.weights_dc_cable;
    # snw.meanweight_dc=alg_fac*min(weighy_dc(weighy_dc~=0));

    # snw.meanweight_dc=alg_fac*min([snw.weights]);
    # snw.meanweight_dc=1;
    # snw.meanweight_ac=snw.meanweight_dc;

    start_position, finish_position = determine_start_and_end_node(spatial_data_matrices, input_data)

    average_weight = sum(spatial_data["segment_weights"]) / size(spatial_data["segment_weights"] ,1)
    
    from_node = start_position
    to_node = finish_position
    OPEN_COUNT = 1
    path_cost = 0
    offshore_distance = 0
    target_distance = estimate_initial_distance(start_position, finish_position, spatial_data, average_weight)
    hn = path_cost
    gn = target_distance
    fn = target_distance
    wn = target_distance
    ac_cable = 0
    dc_cable = 0
    ac_dc_transition = 0
    OPEN = my_insert_open(from_node, to_node, hn, gn, fn, wn, ac_dc_transition, ac_cable, dc_cable, offshore_distance, spatial_data)
    OPEN[OPEN_COUNT, 1] = 0
    CLOSED_COUNT = 1
    CLOSED = [from_node]
    NoPath = 1

    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    # START ALGORITHM
    #%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    while (from_node != finish_position) && (NoPath == 1)
        exp_array = my_expand_array(from_node, path_cost, start_position, finish_position, CLOSED, spatial_data, offshore_distance, input_data, average_weight, equipment_data) 
        exp_count = size(exp_array, 1)
        # UPDATE LIST OPEN WITH THE SUCCESSOR NODES
        # OPEN LIST FORMAT
        #--------------------------------------------------------------------------
        #IS ON LIST 1/0 |X val |Y val |Parent X val |Parent Y val |h(n) |g(n)|f(n)|
        #--------------------------------------------------------------------------
        #EXPANDED ARRAY FORMAT
        #--------------------------------
        #|X val |Y val ||h(n) |g(n)|f(n)|
        #--------------------------------
        for i = 1 : exp_count
            flag = 0
            if any(OPEN[1 : OPEN_COUNT, 2] .== exp_array[i, 1])
                j = findfirst(OPEN[1 : OPEN_COUNT, 2] .== exp_array[i, 1])
                if exp_array[i,4] <= OPEN[j, 10]
                    OPEN[j, 3] = from_node
                    OPEN[j, 4] = spatial_data["nodes"][from_node, 2]
                    OPEN[j, 5] = spatial_data["nodes"][from_node, 3]
                    OPEN[j, 8] = exp_array[i, 2]
                    OPEN[j, 9] = exp_array[i, 3]
                    OPEN[j, 10] = exp_array[i, 4]
                    OPEN[j, 11] = exp_array[i, 5]
                    OPEN[j, 12] = exp_array[i, 6]
                    OPEN[j, 13] = exp_array[i, 7]
                    OPEN[j, 14] = exp_array[i, 8]
                    OPEN[j, 15] = exp_array[i, 9]
                end
            else
                OPEN_COUNT = OPEN_COUNT + 1
                new_line = my_insert_open(exp_array[i, 1], from_node, exp_array[i, 2], exp_array[i, 3], exp_array[i,4], exp_array[i,5], exp_array[i,6], exp_array[i,7], exp_array[i,8], exp_array[i,9], spatial_data)
                OPEN = [OPEN; new_line]
            end
        end

        index_min_node = my_min_fn(OPEN, OPEN_COUNT, finish_position)
        if index_min_node != -1
            from_node = Int.(OPEN[index_min_node, 2])
            path_cost = OPEN[index_min_node, 8]
            offshore_distance = OPEN[index_min_node, 15]
            CLOSED_COUNT = CLOSED_COUNT + 1
            CLOSED = [CLOSED; from_node]
            OPEN[index_min_node, 1] = 0
        else
            NoPath = 0
        end
        print(CLOSED_COUNT,"\n")
    end
    print(start_position, "\n")
    print(finish_position, "\n")
    i = size(CLOSED, 1)
    print(CLOSED, "\n")
    nodeval = CLOSED[i]
    print(nodeval, "\n")
    i = 1
    optimal_path = nodeval
    ac_dc = OPEN[OPEN[:, 2] .== nodeval, 12]
    ac_cab = OPEN[OPEN[:, 2] .== nodeval, 13]
    dc_cab = OPEN[OPEN[:, 2] .== nodeval, 14]
    i = i + 1 
    c_tot = 0
    if nodeval == finish_position
        parent_node = Int.(OPEN[OPEN[:, 2] .== nodeval, 3][1])
        c_tot = c_tot + OPEN[OPEN[:,2] .== nodeval, 11][1]
        while parent_node != start_position
            optimal_path = [optimal_path; parent_node]
            ac_dc = [ac_dc; OPEN[OPEN[:, 2] .== parent_node, 12][1]]
            ac_cab = [ac_cab; OPEN[OPEN[:, 2] .== parent_node, 13[1]]]
            dc_cab = [dc_cab; OPEN[OPEN[:, 2] .== parent_node, 14][1]]
            c_tot = c_tot + OPEN[OPEN[:, 2] .== parent_node, 11][1]
            parent_node = Int.(OPEN[OPEN[:, 2] .== parent_node, 3][1])
            i = i + 1
        end
        optimal_path = [optimal_path; start_position]  
    end

    return c_tot, optimal_path, ac_dc, ac_cab, dc_cab
end

function determine_start_and_end_node(spatial_data_matrices, input_data)
        idx1 = findall(spatial_data_matrices["ohl"]["nodes"][:, 2] .== input_data["start_node"]["x"])
        idx2 = findall(spatial_data_matrices["ohl"]["nodes"][:, 3] .== input_data["start_node"]["y"])
        start_position = intersect(idx1, idx2)

        idx1 = findall(spatial_data_matrices["ohl"]["nodes"][:, 2] .== input_data["end_node"]["x"])
        idx2 = findall(spatial_data_matrices["ohl"]["nodes"][:, 3] .== input_data["end_node"]["y"])
        finish_position = intersect(idx1, idx2)

        sp = start_position[1]
        fp = finish_position[1]

        return sp, fp
end

function estimate_initial_distance(start_position, finish_position, spatial_data, average_weight)
    distance = sqrt.((spatial_data["nodes"][start_position, 2] - spatial_data["nodes"][finish_position, 2]).^2 + spatial_data["nodes"][start_position, 3] - spatial_data["nodes"][finish_position, 3]).^2 * average_weight

    d = distance[1]
    return d
end


function my_insert_open(from_node, to_node, hn, gn, fn, wn, ac_dc, ac_cab, dc_cab, offshore_distance, spatial_data)
    new_row = zeros(1, 15)
    new_row[1,1] = 1
    new_row[1,2] = Int.(from_node)
    new_row[1,3] = Int.(to_node)
    new_row[1,4] = spatial_data["nodes"][Int.(from_node) ,2]
    new_row[1,5] = spatial_data["nodes"][Int.(from_node) ,3]
    new_row[1,6] = spatial_data["nodes"][Int.(to_node) ,2]
    new_row[1,7] = spatial_data["nodes"][Int.(to_node) ,3]
    new_row[1,8] = hn
    new_row[1,9] = gn 
    new_row[1,10] = fn
    new_row[1,11] = wn
    new_row[1,12] = ac_dc
    new_row[1,13] = ac_cab
    new_row[1,14] = dc_cab
    new_row[1,15] = offshore_distance

    return new_row
end


function my_expand_array(from_node, hn, start_node, finish_node, CLOSED, spatial_data, offshore_distance, input_data, average_weight, equipment_data) 
        seg_index1 = findall(spatial_data["segments"][:, 2] .== from_node)
        seg_index2 = findall(spatial_data["segments"][:, 3] .== from_node)
        
        exp_array = Array{Float64, 2}(undef, 0, 9)
        for idx = 1:length(seg_index1)
            current_node = Int.(spatial_data["segments"][seg_index1[idx], 3])
            if !any(CLOSED .== current_node)
                seg_index = seg_index1[idx]
                new_line = zeros(1, 9) 
                new_line[1, 1] = current_node
                distance = sqrt((spatial_data["nodes"][from_node, 2] - spatial_data["nodes"][current_node, 2])^2 + (spatial_data["nodes"][from_node, 3] - spatial_data["nodes"][current_node, 3])^2)
                d_off = input_data["resolution_factor"] * distance * (1 - spatial_data["onshore_flag"][seg_index]) * (1 - spatial_data["onshore_nodes"][from_node]) * (1 - spatial_data["onshore_nodes"][current_node])
                w_off = 1 
                if (offshore_distance + d_off) > equipment_data["ugc"]["offshore"]["maximum_distance"]
                    w_off = 1e9          
                end
                new_line[1, 2] = hn + distance_w(from_node, current_node, spatial_data, seg_index, w_off)
                if d_off == 0
                    new_line[1, 9] = 0
                else
                    new_line[1, 9] = offshore_distance + d_off
                end
                od = distance_off(finish_node, current_node, spatial_data, seg_index, input_data)
                new_line[1, 3] = distance_est(finish_node, current_node, spatial_data, average_weight)

                new_line[1, 4] = new_line[1, 2] + new_line[1, 3]
                new_line[1, 5] = new_line[1, 2] - hn 
                new_line[1, 6] = 0 #nw.ac_dc(seg_index)
                new_line[1, 7] = spatial_data["ohl_ugc_transition"][seg_index1[idx]]
                new_line[1, 8] = spatial_data["ohl_ugc_transition"][seg_index1[idx]]
                exp_array = [exp_array; new_line]
            end
        end
        
        
        for idx = 1:length(seg_index2)
            current_node = Int.(spatial_data["segments"][seg_index2[idx], 2])
            if !any(CLOSED .== current_node)
                seg_index = seg_index2[idx]
                new_line = zeros(1, 9) 
                new_line[1, 1] = current_node
                distance = sqrt((spatial_data["nodes"][from_node, 2] - spatial_data["nodes"][current_node, 2])^2 + (spatial_data["nodes"][from_node, 3] - spatial_data["nodes"][current_node, 3])^2)
                d_off = input_data["resolution_factor"] * distance * (1 - spatial_data["onshore_flag"][seg_index]) * (1 - spatial_data["onshore_nodes"][from_node]) * (1 - spatial_data["onshore_nodes"][current_node])
                w_off = 1  
                if (offshore_distance + d_off ) > equipment_data["ugc"]["offshore"]["maximum_distance"]
                    w_off = 1e9          
                end
                new_line[1, 2] = hn + distance_w(from_node, current_node, spatial_data, seg_index, w_off)
                if d_off == 0
                    new_line[1, 9] = 0
                else
                    new_line[1, 9] = offshore_distance + d_off
                end
                od = distance_off(finish_node, current_node, spatial_data, seg_index, input_data)
                new_line[1, 3] = distance_est(finish_node, current_node, spatial_data, average_weight)


                new_line[1, 4] = new_line[1, 2] + new_line[1, 3]
                new_line[1, 5] = new_line[1, 2] - hn 
                new_line[1, 6] = 0 #nw.ac_dc(seg_index)
                new_line[1, 7] = spatial_data["ohl_ugc_transition"][seg_index2[idx]]
                new_line[1, 8] = spatial_data["ohl_ugc_transition"][seg_index2[idx]]
                exp_array = [exp_array; new_line]
            end
        end
        return exp_array
end

function distance_w(from_node, to_node, spatial_data, index, w_off)

    distance = sqrt((spatial_data["nodes"][from_node, 2] - spatial_data["nodes"][to_node, 2])^2 + (spatial_data["nodes"][from_node, 3] - spatial_data["nodes"][to_node, 3])^2) * spatial_data["segment_weights"][index] * w_off
    d = distance[1]
   return d
end

function distance_est(from_node, to_node, spatial_data, average_weight)
    
    distance = sqrt((spatial_data["nodes"][from_node, 2] - spatial_data["nodes"][to_node, 2])^2 + (spatial_data["nodes"][from_node, 3] - spatial_data["nodes"][to_node, 3])^2) * average_weight
    d = distance[1]
    return d
end

function distance_off(from_node, to_node, spatial_data, index, input_data)
    distance = sqrt((spatial_data["nodes"][from_node, 2] - spatial_data["nodes"][to_node, 2])^2 + (spatial_data["nodes"][from_node, 3] - spatial_data["nodes"][to_node, 3])^2) * (1-spatial_data["onshore_flag"][index]) * input_data["resolution_factor"]
    d = distance[1]
    return d
end


function my_min_fn(OPEN, OPEN_COUNT, finish_node)

    index = (1:OPEN_COUNT)'
    
    temp_array = [OPEN[OPEN[1:OPEN_COUNT, 1] .== 1, :] index[OPEN[1:OPEN_COUNT, 1] .==1]]
    goal_index = findall(OPEN[:, 1] .== finish_node)
    
    if !isempty(goal_index)
        i_min = goal_index
    end
    
    if size(temp_array, 1) != 0
        temp_min = Int.(findfirst(temp_array[:, 10] .== minimum(temp_array[:, 10])))
        i_min = Int.(temp_array[temp_min[1], end])   
    else
        i_min = -1
    end
    return i_min
end