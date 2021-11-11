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

    impedances = Dict{String,Any}()
    impedances["ac"] = Dict{String,Any}()
    impedances["ac"]["ohl"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["16"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["16"]["r"] = 1.874
    impedances["ac"]["ohl"]["16"]["x"] = 0.347
    impedances["ac"]["ohl"]["16"]["c"] = 13.06

    impedances["ac"]["ohl"]["25"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["25"]["r"] = 1.118
    impedances["ac"]["ohl"]["25"]["x"] = 0.334
    impedances["ac"]["ohl"]["25"]["c"] = 13.06

    impedances["ac"]["ohl"]["50"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["50"]["r"] = 0.574
    impedances["ac"]["ohl"]["50"]["x"] = 0.312
    impedances["ac"]["ohl"]["50"]["c"] = 13.06

    impedances["ac"]["ohl"]["70"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["70"]["r"] = 0.404
    impedances["ac"]["ohl"]["70"]["x"] = 0.302
    impedances["ac"]["ohl"]["70"]["c"] = 13.06

    impedances["ac"]["ohl"]["95"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["95"]["r"] = 0.300
    impedances["ac"]["ohl"]["95"]["x"] = 0.291
    impedances["ac"]["ohl"]["95"]["c"] = 13.06

    impedances["ac"]["ohl"]["120"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["120"]["r"] = 0.252
    impedances["ac"]["ohl"]["120"]["x"] = 0.284
    impedances["ac"]["ohl"]["120"]["c"] = 13.06

    impedances["ac"]["ohl"]["150"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["150"]["r"] = 0.190
    impedances["ac"]["ohl"]["150"]["x"] = 0.279
    impedances["ac"]["ohl"]["150"]["c"] = 13.06

    impedances["ac"]["ohl"]["170"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["170"]["r"] = 0.165
    impedances["ac"]["ohl"]["170"]["x"] = 0.276
    impedances["ac"]["ohl"]["170"]["c"] = 13.06

    impedances["ac"]["ohl"]["185"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["185"]["r"] = 0.154
    impedances["ac"]["ohl"]["185"]["x"] = 0.274
    impedances["ac"]["ohl"]["185"]["c"] = 13.06

    impedances["ac"]["ohl"]["210"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["210"]["r"] = 0.133
    impedances["ac"]["ohl"]["210"]["x"] = 0.270
    impedances["ac"]["ohl"]["210"]["c"] = 13.06

    impedances["ac"]["ohl"]["230"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["230"]["r"] = 0.122
    impedances["ac"]["ohl"]["230"]["x"] = 0.268
    impedances["ac"]["ohl"]["230"]["c"] = 13.06

    impedances["ac"]["ohl"]["240"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["240"]["r"] = 0.116
    impedances["ac"]["ohl"]["240"]["x"] = 0.267
    impedances["ac"]["ohl"]["240"]["c"] = 13.06

    impedances["ac"]["ohl"]["265"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["265"]["r"] = 0.107
    impedances["ac"]["ohl"]["265"]["x"] = 0.264
    impedances["ac"]["ohl"]["265"]["c"] = 13.06

    impedances["ac"]["ohl"]["300"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["300"]["r"] = 0.093
    impedances["ac"]["ohl"]["300"]["x"] = 0.261
    impedances["ac"]["ohl"]["300"]["c"] = 13.06
    
    impedances["ac"]["ohl"]["340"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["340"]["r"] = 0.083
    impedances["ac"]["ohl"]["340"]["x"] = 0.258
    impedances["ac"]["ohl"]["340"]["c"] = 13.06

    impedances["ac"]["ohl"]["380"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["380"]["r"] = 0.074
    impedances["ac"]["ohl"]["380"]["x"] = 0.255
    impedances["ac"]["ohl"]["380"]["c"] = 13.06

    impedances["ac"]["ohl"]["435"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["435"]["r"] = 0.065
    impedances["ac"]["ohl"]["435"]["x"] = 0.252
    impedances["ac"]["ohl"]["435"]["c"] = 13.06

    impedances["ac"]["ohl"]["450"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["450"]["r"] = 0.063
    impedances["ac"]["ohl"]["450"]["x"] = 0.251
    impedances["ac"]["ohl"]["450"]["c"] = 13.06

    impedances["ac"]["ohl"]["490"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["490"]["r"] = 0.058
    impedances["ac"]["ohl"]["490"]["x"] = 0.249
    impedances["ac"]["ohl"]["490"]["c"] = 13.06

    impedances["ac"]["ohl"]["550"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["550"]["r"] = 0.051
    impedances["ac"]["ohl"]["550"]["x"] = 0.246
    impedances["ac"]["ohl"]["550"]["c"] = 13.06

    impedances["ac"]["ohl"]["560"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["560"]["r"] = 0.050
    impedances["ac"]["ohl"]["560"]["x"] = 0.26
    impedances["ac"]["ohl"]["560"]["c"] = 13.06

    impedances["ac"]["ohl"]["680"] = Dict{String,Any}()
    impedances["ac"]["ohl"]["680"]["r"] = 0.042
    impedances["ac"]["ohl"]["680"]["x"] = 0.241
    impedances["ac"]["ohl"]["680"]["c"] = 13.06

    impedances["ac"]["ugc"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["300"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["300"]["r"] = 0.069
    impedances["ac"]["ugc"]["300"]["x"] = 0.110
    impedances["ac"]["ugc"]["300"]["c"] = 375

    impedances["ac"]["ugc"]["400"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["400"]["r"] = 0.057
    impedances["ac"]["ugc"]["400"]["x"] = 0.130
    impedances["ac"]["ugc"]["400"]["c"] = 170

    impedances["ac"]["ugc"]["500"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["500"]["r"] = 0.047
    impedances["ac"]["ugc"]["500"]["x"] = 0.125
    impedances["ac"]["ugc"]["500"]["c"] = 180

    impedances["ac"]["ugc"]["630"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["630"]["r"] = 0.038
    impedances["ac"]["ugc"]["630"]["x"] = 0.122
    impedances["ac"]["ugc"]["630"]["c"] = 200

    impedances["ac"]["ugc"]["800"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["800"]["r"] = 0.027
    impedances["ac"]["ugc"]["800"]["x"] = 0.102
    impedances["ac"]["ugc"]["800"]["c"] = 402

    impedances["ac"]["ugc"]["1200"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["1200"]["r"] = 0.0151
    impedances["ac"]["ugc"]["1200"]["x"] = 0.116
    impedances["ac"]["ugc"]["1200"]["c"] = 210

    impedances["ac"]["ugc"]["1600"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["1600"]["r"] = 0.0113
    impedances["ac"]["ugc"]["1600"]["x"] = 0.111
    impedances["ac"]["ugc"]["1600"]["c"] = 231

    impedances["ac"]["ugc"]["2000"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["2000"]["r"] = 0.010
    impedances["ac"]["ugc"]["2000"]["x"] = 0.1099
    impedances["ac"]["ugc"]["2000"]["c"] = 240

    impedances["ac"]["ugc"]["2500"] = Dict{String,Any}()
    impedances["ac"]["ugc"]["2500"]["r"] = 0.0095
    impedances["ac"]["ugc"]["2500"]["x"] = 0.098
    impedances["ac"]["ugc"]["2500"]["c"] = 260


    impedances["dc"] = Dict{String,Any}()
    impedances["dc"]["ohl"] = Dict{String,Any}()
    for (cross_section, cs) in impedances["ac"]["ohl"]
        impedances["dc"]["ohl"][cross_section] = Dict{String,Any}()
        impedances["dc"]["ohl"][cross_section]["r"] = cs["r"]
        impedances["dc"]["ohl"][cross_section]["x"] = 0
        impedances["dc"]["ohl"][cross_section]["c"] = 0
    end

    impedances["dc"]["ugc"] = Dict{String,Any}()
    impedances["dc"]["ugc"]["95"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["95"]["r"] = 0.247
    impedances["dc"]["ugc"]["95"]["x"] = 0
    impedances["dc"]["ugc"]["95"]["c"] = 0

    impedances["dc"]["ugc"]["120"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["120"]["r"] = 0.196
    impedances["dc"]["ugc"]["120"]["x"] = 0
    impedances["dc"]["ugc"]["120"]["c"] = 0

    impedances["dc"]["ugc"]["150"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["150"]["r"] = 0.16
    impedances["dc"]["ugc"]["150"]["x"] = 0
    impedances["dc"]["ugc"]["150"]["c"] = 0

    impedances["dc"]["ugc"]["185"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["185"]["r"] = 0.128
    impedances["dc"]["ugc"]["185"]["x"] = 0
    impedances["dc"]["ugc"]["185"]["c"] = 0

    impedances["dc"]["ugc"]["240"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["240"]["r"] = 0.097
    impedances["dc"]["ugc"]["240"]["x"] = 0
    impedances["dc"]["ugc"]["240"]["c"] = 0

    impedances["dc"]["ugc"]["300"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["300"]["r"] = 0.08
    impedances["dc"]["ugc"]["300"]["x"] = 0
    impedances["dc"]["ugc"]["300"]["c"] = 0

    impedances["dc"]["ugc"]["400"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["400"]["r"] = 0.062
    impedances["dc"]["ugc"]["400"]["x"] = 0
    impedances["dc"]["ugc"]["400"]["c"] = 0

    impedances["dc"]["ugc"]["500"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["500"]["r"] = 0.0508
    impedances["dc"]["ugc"]["500"]["x"] = 0
    impedances["dc"]["ugc"]["500"]["c"] = 0

    impedances["dc"]["ugc"]["630"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["630"]["r"] = 0.039
    impedances["dc"]["ugc"]["630"]["x"] = 0
    impedances["dc"]["ugc"]["630"]["c"] = 0

    impedances["dc"]["ugc"]["800"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["800"]["r"] = 0.032
    impedances["dc"]["ugc"]["800"]["x"] = 0
    impedances["dc"]["ugc"]["800"]["c"] = 0

    impedances["dc"]["ugc"]["1000"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["1000"]["r"] = 0.024
    impedances["dc"]["ugc"]["1000"]["x"] = 0
    impedances["dc"]["ugc"]["1000"]["c"] = 0

    impedances["dc"]["ugc"]["1200"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["1200"]["r"] = 0.021
    impedances["dc"]["ugc"]["1200"]["x"] = 0
    impedances["dc"]["ugc"]["1200"]["c"] = 0

    impedances["dc"]["ugc"]["1400"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["1400"]["r"] = 0.019
    impedances["dc"]["ugc"]["1400"]["x"] = 0
    impedances["dc"]["ugc"]["1400"]["c"] = 0

    impedances["dc"]["ugc"]["1600"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["1600"]["r"] = 0.017
    impedances["dc"]["ugc"]["1600"]["x"] = 0
    impedances["dc"]["ugc"]["1600"]["c"] = 0

    impedances["dc"]["ugc"]["1800"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["1800"]["r"] = 0.0155
    impedances["dc"]["ugc"]["1800"]["x"] = 0
    impedances["dc"]["ugc"]["1800"]["c"] = 0

    impedances["dc"]["ugc"]["2000"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["2000"]["r"] = 0.014
    impedances["dc"]["ugc"]["2000"]["x"] = 0
    impedances["dc"]["ugc"]["2000"]["c"] = 0

    impedances["dc"]["ugc"]["2200"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["2200"]["r"] = 0.013
    impedances["dc"]["ugc"]["2200"]["x"] = 0
    impedances["dc"]["ugc"]["2200"]["c"] = 0

    impedances["dc"]["ugc"]["2400"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["2400"]["r"] = 0.012
    impedances["dc"]["ugc"]["2400"]["x"] = 0
    impedances["dc"]["ugc"]["2400"]["c"] = 0

    impedances["dc"]["ugc"]["2600"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["2600"]["r"] = 0.010
    impedances["dc"]["ugc"]["2600"]["x"] = 0
    impedances["dc"]["ugc"]["2600"]["c"] = 0

    impedances["dc"]["ugc"]["2800"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["2800"]["r"] = 0.09
    impedances["dc"]["ugc"]["2800"]["x"] = 0
    impedances["dc"]["ugc"]["2800"]["c"] = 0

    impedances["dc"]["ugc"]["3000"] = Dict{String, Any}()
    impedances["dc"]["ugc"]["3000"]["r"] = 0.075
    impedances["dc"]["ugc"]["3000"]["x"] = 0
    impedances["dc"]["ugc"]["3000"]["c"] = 0

    return spatial_weights, voltages, resolution, impedances
end