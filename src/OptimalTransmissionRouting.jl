isdefined(Base, :__precompile__) && __precompile__()

module OptimalTransmissionRouting

# import Compat
import JuMP
import Memento


# Create our module level logger (this will get precompiled)
const _LOGGER = Memento.getlogger(@__MODULE__)

# Register the module level logger at runtime so that folks can access the logger via `getlogger(PowerModels)`
# NOTE: If this line is not included then the precompiled `_PM._LOGGER` won't be registered at runtime.
__init__() = Memento.register(_LOGGER)

include("core/define_weights.jl")


# Spatial image files
include("spatial_image_files/clc_agricultural.tiff")
include("spatial_image_files/clc_mountains.tiff")
include("spatial_image_files/clc_natural.tiff")
include("spatial_image_files/clc_urban.tiff")
include("spatial_image_files/clc_graph_Europe.tiff")
include("spatial_image_files/clc_grid_225kv_400kv.tiff")
include("spatial_image_files/natura2000.tiff")
include("spatial_image_files/clc_railroads.tiff")
include("spatial_image_files/clc_roads.tiff")
include("spatial_image_files/sea.tiff")

end
