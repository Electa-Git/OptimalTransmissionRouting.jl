# Some branch in Italy

bus1 = Dict{String, Any}()
bus1["longitude"] = 16.2487678
bus1["latitude"] = 40.358515
bus2 = Dict{String, Any}()
bus2["longitude"] = 14.1482998
bus2["latitude"] = 37.5900782

# strategy = "all_permitted"
# strategy = "OHL_on_existing_corridors"
strategy = "cables_only"

spatial_weights, voltages, resolution, impedances = OTR.define_weights_voltages(strategy)

rgb_values, nodes_lp, boundaries, plot_dictionary = OTR.convert_image_files_to_weights(bus1, bus2)  

#define inputs
input_data = Dict{String, Any}()

input_data["resolution_factor"] = 2 # resolution_factor 1,2,3, ... to speed up algorithm
input_data["algorithm_factor"] = 1 # algorithm_factor 1.....1.3 to speed up Astar algorithm, goes at expense of accuracy
input_data["distance"] = 2.5  # do not change: this is the standard resolution of the environmental data
input_data["algorithm"] = "Astar"  # "Astar" or "Dijkstra"
input_data["voltages"] = voltages # transmission voltages
input_data["spatial_weights"] = spatial_weights # spatial weights
input_data["rgb_values"] = rgb_values # Spatial data as RGB values
input_data["boundaries"] = boundaries # VBoundaries of the area (to avoid using full European range)
input_data["overlapping_area_weight"] = "average" # "average" = average weight of the spatial weights; "minimum" = minimum of the overlapping weights
input_data["strategy"] = strategy # or "OHL_on_existing_corridors" or "cables_only"
input_data["losses"] = 0.01 # proxy for losses
input_data["lifetime"] = 30 # lifetime: NOT USED in FLEXPLAN
input_data["interest"] = 0.02 # Interest: NOT USED in FLEXPLAN 
input_data["technology"] = "dc" # or "dc"
input_data["power_rating"] = 2000 # power rating
input_data["start_node"] = Dict{String, Any}()
input_data["start_node"]["x"] = nodes_lp["x1"]
input_data["start_node"]["y"] = nodes_lp["y1"] 
input_data["end_node"] = Dict{String, Any}()
input_data["end_node"]["x"] = nodes_lp["x2"]
input_data["end_node"]["y"] = nodes_lp["y2"]
input_data["impedances"] = impedances # Provide look-up table for OHL & OGC impedances

@testset "DC cables only" begin
    strategy = "cables_only"
    input_data["technology"] = "dc" # or "dc"
    input_data["strategy"] = strategy 
    @time spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab, route_impedance, route_length  = OTR.do_optimal_routing(input_data)

    @testset "cost data" begin
        @test isapprox(cost_data["ohl"]["ohl_km"][1], 1.24362898072976e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][17], 1.5231374779172337e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][9639], 2.1540416786293026e7; atol = 1e0)
    end
    @testset "total cost" begin
        @test isapprox(c_tot, 9.807293638249868e8; atol = 1e0)
    end
    @testset "optimal path" begin
        @test isapprox(optimal_path[52], 13019)
        @test isapprox(optimal_path[15], 10790)
    end
    @testset "impedance_data" begin
        @test isapprox(route_impedance["r_pu"], 0.001619311421391319, atol = 1e-5)
        @test isapprox(route_impedance["x_pu"], 0.0, atol = 1e-3)
        @test isapprox(route_impedance["bc_pu"], 0.0, atol = 1e-3)
    end

    @testset "route_length" begin
        @test isapprox(route_length["total_length"], 174.544725, atol = 1e-1)
        @test isapprox(route_length["ohl_length"], 0.0, atol = 1e-3)
        @test isapprox(route_length["ugc_length"], 174.54472, atol = 1e-3)
    end
end
@testset "DC all permitted" begin
    strategy = "all_permitted"
    input_data["technology"] = "dc" # or "dc"
    input_data["strategy"] = strategy 
    @time spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab, route_impedance, route_length  = OTR.do_optimal_routing(input_data)

    @testset "cost data" begin
        @test isapprox(cost_data["ohl"]["ohl_km"][1], 1.24362898072976e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][17], 1.5231374779172337e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][9639], 2.1540416786293026e7; atol = 1e0)
    end
    @testset "total cost" begin
        @test isapprox(c_tot, 9.807293638249868e8; atol = 1e0)
    end
    @testset "optimal path" begin
        @test isapprox(optimal_path[52], 13019)
        @test isapprox(optimal_path[15], 10790)
    end

    @testset "impedance_data" begin
        @test isapprox(route_impedance["r"], 1.6581748955047106, atol = 1e-3)
        @test isapprox(route_impedance["x_pu"], 0.0, atol = 1e-3)
        @test isapprox(route_impedance["bc_pu"], 0.0, atol = 1e-3)
    end

    @testset "route_length" begin
        @test isapprox(route_length["total_length"], 174.544725, atol = 1e-1)
        @test isapprox(route_length["ohl_length"], 0.0, atol = 1e-3)
        @test isapprox(route_length["ugc_length"], 174.54472, atol = 1e-3)
    end
end

@testset "AC cables only" begin
    strategy = "cables_only"
    input_data["technology"] = "ac" # or "dc"
    input_data["strategy"] = strategy 
    @time spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab, route_impedance, route_length  = OTR.do_optimal_routing(input_data)

    @testset "cost data" begin
        @test isapprox(cost_data["ohl"]["ohl_km"][1], 4.072540970760065e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][17], 4.072540970760065e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][9639], 5.759442674168975e7; atol = 1e0)
    end
    @testset "total cost" begin
        @test isapprox(c_tot, 2.0405224791992671e9; atol = 1e0)
    end
    @testset "optimal path" begin
        @test isapprox(optimal_path[52], 13027)
        @test isapprox(optimal_path[15], 10790)
    end

    @testset "impedance_data" begin
        @test isapprox(route_impedance["r_pu"], 0.0005509232966856801, atol = 1e-6)
        @test isapprox(route_impedance["x"], 9.09313399161207, atol = 1e-3)
        @test isapprox(route_impedance["bc_pu"], 485.0546916571823, atol = 1e-3)
    end

    @testset "route_length" begin
        @test isapprox(route_length["total_length"], 185.57416, atol = 1e-1)
        @test isapprox(route_length["ohl_length"], 0.0, atol = 1e-3)
        @test isapprox(route_length["ugc_length"], 185.57416, atol = 1e-3)
    end
end

@testset "AC all permitted" begin
    strategy = "all_permitted"
    input_data["technology"] = "ac" # or "dc"
    input_data["strategy"] = strategy 
    @time spatial_data, spatial_data_matrices, cost_data, equipment_data, c_tot, optimal_path, ac_dc, ac_cab, dc_cab, route_impedance, route_length  = OTR.do_optimal_routing(input_data)

    @testset "cost data" begin
        @test isapprox(cost_data["ohl"]["ohl_km"][1], 4.072540970760065e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][17], 4.072540970760065e7; atol = 1e0)
        @test isapprox(cost_data["ohl"]["ohl_km"][9639], 5.759442674168975e7; atol = 1e0)
    end
    @testset "total cost" begin
        @test isapprox(c_tot, 2.0405224791992671e9; atol = 1e0)
    end
    @testset "optimal path" begin
        @test isapprox(optimal_path[52], 13027)
        @test isapprox(optimal_path[15], 10790)
    end

    @testset "impedance_data" begin
        @test isapprox(route_impedance["r_pu"], 0.0005509232966856801, atol = 1e-6)
        @test isapprox(route_impedance["x"], 9.09313399161207, atol = 1e-3)
        @test isapprox(route_impedance["bc_pu"], 485.0546916571823, atol = 1e-3)
    end

    @testset "route_length" begin
        @test isapprox(route_length["total_length"], 185.57416, atol = 1e-1)
        @test isapprox(route_length["ohl_length"], 0.0, atol = 1e-3)
        @test isapprox(route_length["ugc_length"], 185.57416, atol = 1e-3)
    end
end

# For plotting the pdf of the result
# OTR.plot_result(plot_dictionary, input_data, spatial_data, spatial_data_matrices, optimal_path)
#