isdefined(Base, :__precompile__) && __precompile__()

module OptimalTransmissionRouting

# import Compat
import JuMP
import Memento
import Images
import FileIO
import ImagesInTerminal; const IIT = ImagesInTerminal


# Create our module level logger (this will get precompiled)
const _LOGGER = Memento.getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `getlogger(PowerModels)`
# NOTE: If this line is not included then the precompiled `_PM._LOGGER` won't be registered at runtime.
__init__() = Memento.register(_LOGGER)

include("core/define_weights.jl")
include("core/image2weight.jl")
include("core/optimal_routing.jl")
include("core/costs_and_equipment_details.jl")
include("core/a_star.jl")
include("core/spatial_data_preparation.jl")
include("io/plot_optimal_path.jl")


# Spatial image files
# include("spatial_image_files/clc_agricultural.tif")
# include("spatial_image_files/clc_mountains.tif")
# include("spatial_image_files/clc_natural.tif")
# include("spatial_image_files/clc_urban.tif")
# include("spatial_image_files/clc_graph_Europe.tif")
# include("spatial_image_files/clc_grid_225kv_400kv.tif")
# include("spatial_image_files/natura2000.tif")
# include("spatial_image_files/clc_railroads.tif")
# include("spatial_image_files/clc_roads.tif")
# include("spatial_image_files/sea.tif")

end
