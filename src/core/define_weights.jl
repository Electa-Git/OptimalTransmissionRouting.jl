function define_weights_voltages()
# Create dictionary of spatial weights for different equipment types / areas
spatial_weights = Dict{String, Any}()

# Weights for AC OHL
spatial_weights["ac_ohl"] =  Dict{String, Any}()
spatial_weights["ac_ohl"]["hill"] = 2.5
spatial_weights["ac_ohl"]["city"] = 40
spatial_weights["ac_ohl"]["bigcity"] = 40
spatial_weights["ac_ohl"]["mountain"] = 10
spatial_weights["ac_ohl"]["sea"] = 40
spatial_weights["ac_ohl"]["third_country"] = 40
spatial_weights["ac_ohl"]["nature"] = 40
spatial_weights["ac_ohl"]["grid"] = 1
spatial_weights["ac_ohl"]["aggri"] = 1

# Weights for AC UGC
spatial_weights["ac_ugc"] =  Dict{String, Any}()
spatial_weights["ac_ugc"]["hill"] = 1
spatial_weights["ac_ugc"]["city"] = 2.5
spatial_weights["ac_ugc"]["bigcity"] = 2.5
spatial_weights["ac_ugc"]["mountain"] = 4.5
spatial_weights["ac_ugc"]["sea"] = 0.75
spatial_weights["ac_ugc"]["third_country"] = 40
spatial_weights["ac_ugc"]["nature"] = 2.5
spatial_weights["ac_ugc"]["grid"] = 1
spatial_weights["ac_ugc"]["aggri"] = 1

# Weights for DC OHL
spatial_weights["dc_ohl"] =  Dict{String, Any}()
spatial_weights["dc_ohl"]["hill"] = 2.5
spatial_weights["dc_ohl"]["city"] = 40
spatial_weights["dc_ohl"]["bigcity"] = 40
spatial_weights["dc_ohl"]["mountain"] = 10
spatial_weights["dc_ohl"]["sea"] = 40
spatial_weights["dc_ohl"]["third_country"] = 40
spatial_weights["dc_ohl"]["nature"] = 40
spatial_weights["dc_ohl"]["grid"] = 1
spatial_weights["dc_ohl"]["aggri"] = 1

# Weights for AC UGC
spatial_weights["dc_ugc"] =  Dict{String, Any}()
spatial_weights["dc_ugc"]["hill"] = 1
spatial_weights["dc_ugc"]["city"] = 2.5
spatial_weights["dc_ugc"]["bigcity"] = 2.5
spatial_weights["dc_ugc"]["mountain"] = 4.5
spatial_weights["dc_ugc"]["sea"] = 0.75
spatial_weights["dc_ugc"]["third_country"] = 40
spatial_weights["dc_ugc"]["nature"] = 2.5
spatial_weights["dc_ugc"]["grid"] = 1
spatial_weights["dc_ugc"]["aggri"] = 1

# Define transmission voltage levels
voltages = Dict{String, Any}()
voltages["ac_ohl"] = 400
voltages["dc_ohl"] = 400
voltages["ac_ugc"] = 400
voltages["dc_ugc"] = 525

#Minimum resolution
resolution = Dict{Stirng, Any}()
resolution["delta_min"] = 4
resolution["weight_min"] = Dict{String, Any}()
resolution["weight_min"]["ac_ohl"] = 1
resolution["weight_min"]["ac_ugc"] = 1
resolution["weight_min"]["dc_ohl"] = 1
resolution["weight_min"]["dc_ugc"] = 1

export spatial_weights, voltages, resolution
end