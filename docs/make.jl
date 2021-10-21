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
    target = "build",
    repo = "https://github.com/Electa-Git/OptimalTransmissionRouting.jl.git",
    branch = "gh-pages",
    devbranch = "main",
    versions = ["stable" => "v^", "v#.#"],
    push_preview = false
)


