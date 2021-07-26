function plot_result(plot_dictionary, input_data, spatial_data, spatial_data_matrices, optimal_path)
    A = zeros(3, size(plot_dictionary["overlay_image"],1), size(plot_dictionary["overlay_image"],2) )
    look_up_table = [0 255 0; 176 224 230;255 255 255;255 255 0; 218 165 32;255 160 122;255 0 0] ./ 255

    for i in 1:size(plot_dictionary["overlay_image"], 1)
        for j in 1:size(plot_dictionary["overlay_image"], 2)
            A[:, i, j] = look_up_table[Int.(plot_dictionary["overlay_image"][i, j]), :]'
        end
    end
    # xdim = size(input_data["rgb_values"]["grid"], 2)
    # ydim = size(input_data["rgb_values"]["grid"], 1)
    # scale_x = abs(input_data["boundaries"]["xmin"] - input_data["boundaries"]["xmax"]) / xdim
    # scale_y = abs(input_data["boundaries"]["ymin"] - input_data["boundaries"]["ymax"]) / ydim
    # B = A[:, Int.(input_data["boundaries"]["ymin"]) : Int.(input_data["boundaries"]["ymax"]), Int.(input_data["boundaries"]["xmin"]) : Int.(input_data["boundaries"]["xmax"])]
    p = Images.colorview(ColorTypes.RGB, A)
    Plots.plot(p)
    for idx = 1 : size(optimal_path, 1) - 1
        x1 = spatial_data["nodes"][optimal_path[idx], 2]  
        y1 = spatial_data["nodes"][optimal_path[idx], 3] 
        x2 = spatial_data["nodes"][optimal_path[idx + 1], 2] 
        y2 = spatial_data["nodes"][optimal_path[idx + 1], 3]
        ohl_cable = ohl_or_cable(spatial_data, spatial_data_matrices, optimal_path[idx], optimal_path[idx + 1])
        if input_data["technology"] == "dc"
            if ohl_cable == "ugc"
                p = Plots.plot!([x1, x2], [y1, y2], color = :brown, linewidth = 2, label = "")
            else
                p = Plots.plot!([x1, x2], [y1, y2], color = :brown, linestyle = :dot, linewidth = 2, label = "")
            end
        else
            # if ohl_cable == "ugc"
            #     p = Plots.plot!([x1, x2], [y1, y2], color = :black, label = "")
            # else
            #     p = Plots.plot!([x1, x2], [y1, y2], color = :black, marker = :x, label = "")
            # end
        end
    end
    Plots.plot!(xlims=(input_data["boundaries"]["xmin"],input_data["boundaries"]["xmax"]), ylims = (input_data["boundaries"]["ymin"], input_data["boundaries"]["ymax"]))
    plot_file = "plot_test.pdf"
    Plots.savefig(p, plot_file)
 end


 function ohl_or_cable(spatial_data, spatial_data_matrices, node_id1, node_id2)
    index_s1 = findall(node_id1 .== spatial_data["segments"][:, 2])
    index_s2 = findall(node_id2 .== spatial_data["segments"][:, 3])
    index_s = intersect(index_s1, index_s2)
    if isempty(index_s)
        index_s1 = findall(node_id2 .== spatial_data["segments"][:, 2])
        index_s2 = findall(node_id1 .== spatial_data["segments"][:, 3])
        index_s = intersect(index_s1, index_s2)
    end
    if any(index_s[1] .== spatial_data_matrices["ohl"]["segments"][:, 1])
        ohl_cable = "ohl"
    else
        ohl_cable = "ugc"
    end
    return ohl_cable
 end