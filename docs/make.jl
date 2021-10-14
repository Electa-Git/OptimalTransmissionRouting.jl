using Documenter, OptimalTransmissionRouting

Documenter.makedocs(
    modules = OptimalTransmissionRouting,
    format = Documenter.HTML(),
    sitename = "OptimalTransmissionRouting",
    authors = "Hakan Ergun",
    pages = [
        "Home" => "index.md"
    ]
)

Documenter.deploydocs(
    repo = "github.com/hakanergun/PowerModelsACDC.jl.git"
)