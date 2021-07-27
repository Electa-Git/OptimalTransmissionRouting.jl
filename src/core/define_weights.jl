function define_weights_voltages(strategy)
    # Create dictionary of spatial weights for different equipment types / areas
    spatial_weights = Dict{String, Any}()

    # Weights for AC OHL
    spatial_weights["ac_ohl"] =  Dict{String, Any}()
    spatial_weights["ac_ohl"]["nature"] = 2.5
    spatial_weights["ac_ohl"]["urban"] = 40
    spatial_weights["ac_ohl"]["mountain"] = 10
    spatial_weights["ac_ohl"]["sea"] = 40
    spatial_weights["ac_ohl"]["Natura2000"] = 40
    spatial_weights["ac_ohl"]["grid"] = 1
    spatial_weights["ac_ohl"]["agricultural"] = 1
    spatial_weights["ac_ohl"]["roads"] = 1
    spatial_weights["ac_ohl"]["railroads"] = 1

    if strategy == "OHL_on_existing_corridors"
        spatial_weights["ac_ohl"]["agricultural"] = 40
        spatial_weights["ac_ohl"]["nature"] = 40
        spatial_weights["ac_ohl"]["mountain"] = 40
    end

    if strategy == "cables_only"
        spatial_weights["ac_ohl"]["agricultural"] = 40
        spatial_weights["ac_ohl"]["nature"] = 40
        spatial_weights["ac_ohl"]["mountain"] = 40
        spatial_weights["ac_ohl"]["grid"] = 40
        spatial_weights["ac_ohl"]["roads"] = 40
        spatial_weights["ac_ohl"]["railroads"] = 40
    end

    # Weights for AC UGC
    spatial_weights["ac_ugc"] =  Dict{String, Any}()
    spatial_weights["ac_ugc"]["nature"] = 1.5
    spatial_weights["ac_ugc"]["urban"] = 2.5
    spatial_weights["ac_ugc"]["mountain"] = 4.5
    spatial_weights["ac_ugc"]["sea"] = 0.75
    spatial_weights["ac_ugc"]["Natura2000"] = 40
    spatial_weights["ac_ugc"]["grid"] = 1
    spatial_weights["ac_ugc"]["agricultural"] = 1
    spatial_weights["ac_ugc"]["roads"] = 1
    spatial_weights["ac_ugc"]["railroads"] = 1

    # Weights for DC OHL
    spatial_weights["dc_ohl"] =  Dict{String, Any}()
    spatial_weights["dc_ohl"]["nature"] = 2.5
    spatial_weights["dc_ohl"]["urban"] = 40
    spatial_weights["dc_ohl"]["mountain"] = 10
    spatial_weights["dc_ohl"]["sea"] = 40
    spatial_weights["dc_ohl"]["Natura2000"] = 10
    spatial_weights["dc_ohl"]["grid"] = 1
    spatial_weights["dc_ohl"]["agricultural"] = 1
    spatial_weights["dc_ohl"]["roads"] = 1
    spatial_weights["dc_ohl"]["railroads"] = 1

    if strategy == "OHL_on_existing_corridors"
        spatial_weights["dc_ohl"]["agricultural"] = 40
        spatial_weights["dc_ohl"]["nature"] = 40
        spatial_weights["dc_ohl"]["mountain"] = 40
    end

    if strategy == "cables_only"
        spatial_weights["dc_ohl"]["agricultural"] = 40
        spatial_weights["dc_ohl"]["nature"] = 40
        spatial_weights["dc_ohl"]["mountain"] = 40
        spatial_weights["dc_ohl"]["grid"] = 40
        spatial_weights["dc_ohl"]["roads"] = 40
        spatial_weights["dc_ohl"]["railroads"] = 40
    end


    # Weights for AC UGC
    spatial_weights["dc_ugc"] =  Dict{String, Any}()
    spatial_weights["dc_ugc"]["nature"] = 1.5
    spatial_weights["dc_ugc"]["urban"] = 2.5
    spatial_weights["dc_ugc"]["mountain"] = 4.5
    spatial_weights["dc_ugc"]["sea"] = 0.75
    spatial_weights["dc_ugc"]["Natura2000"] = 10
    spatial_weights["dc_ugc"]["grid"] = 1
    spatial_weights["dc_ugc"]["agricultural"] = 1
    spatial_weights["dc_ugc"]["roads"] = 1
    spatial_weights["dc_ugc"]["railroads"] = 1

    # Define transmission voltage levels
    voltages = Dict{String, Any}()
    voltages["ac_ohl"] = 400
    voltages["dc_ohl"] = 400
    voltages["ac_ugc"] = 400
    voltages["dc_ugc"] = 320

    #Minimum resolution
    resolution = Dict{String, Any}()
    resolution["delta_min"] = 4
    resolution["weight_min"] = Dict{String, Any}()
    resolution["weight_min"]["ac_ohl"] = 1
    resolution["weight_min"]["ac_ugc"] = 1
    resolution["weight_min"]["dc_ohl"] = 1
    resolution["weight_min"]["dc_ugc"] = 1

    return spatial_weights, voltages, resolution
end