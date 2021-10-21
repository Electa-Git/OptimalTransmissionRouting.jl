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
    root   = "<current-directory>",
    target = "build",
    repo = "https://github.com/Electa-Git/OptimalTransmissionRouting.jl.git",
    branch = "gh-pages",
    devbranch = "main",
    devurl = "dev",
    versions = ["stable" => "v^", "v#.#", devurl => devurl],
    push_preview = false
)


