using Pkg
Pkg.update()
# # Pkg.add("Agents")
# # # Pkg.add("AgentsPlots")
# # # # Pkg.add("Revise")
# Pkg.add("GLMakie")
# # # # Pkg.add("WGLMakie")
# # # # Pkg.add("RPRMakie")
# # Pkg.add("CairoMakie")
# # Pkg.add("Plots")
# # ## Pkg.add("InteractiveDynamics")
# # # Pkg.add("ColorSchemes")
# # # Pkg.add("Colors")
# # Pkg.add("GR")


# using Revise
using Agents
using InteractiveDynamics
using CairoMakie # static plots
# using GLMakie
using Statistics
using Random
# using Plots
# gr()
# Plots.default(show=true)
using GLMakie
using Colors
using ColorSchemes
using Printf
# # using Base
GLMakie.activate!()
# # CairoMakie.activate!()


@agent Farmer4 GridAgent{2} begin
    x::Int64
    y::Int64
    intensity::Float64
    profit_focus::Float64
    sustainability_focus::Float64
    neighbour_focus::Float64
    profit_motivation::Float64
    sustainability_motivation::Float64
    neighbour_motivation::Float64
    neighbours::Vector
end


function setup()
    ## define the space
    ngrid = 50
    space = GridSpace((ngrid, ngrid),periodic=false)
    ## define global properties
    properties = Dict(:profit_margin => 0.5,
                      :neighbour_margin => 0.5,
                      :climate_effect => 0.0,
                      :climate_change_rate => 0.01,
                      :profit_motivation_minimum => -0.5,
                      :profit_motivation_maximum => 0.5,
                      :sustainability_motivation_minimum => -0.5,
                      :sustainability_motivation_maximum => 0.5,
                      :neighbour_motivation_minimum => -0.5,
                      :neighbour_motivation_maximum => 0.5,
                      :intensity_minimum => 0.0,
                      :intensity_maximum => 1,
                      :climate_effect_minimum => 0,
                      :climate_effect_maximum => 2,)
    ## construct model
    model = ABM(Farmer4, space; properties)
    ## construct agents, one at each grid point
    for x in 1:ngrid
        for y in 1:ngrid
            profit_focus = randn()*0.1+0.5
            add_agent_single!(model,
                              x, # x::Int
                              y,  # y::Int
                              0.5 + randn()*0.1, # intensity::Float64
                              profit_focus, # profit_focus
                              1-profit_focus, # sustainability_focus
                              0.5 + randn()*0.1, # neighbour_focus
                              0, # profit_motivation
                              0, # sustainability_motivation
                              0, # neighbour_motivation
                              [], # neighbours
                              )
        end
    end
    ## find agent neighbours
    for (id,agent) in model.agents
        agent.neighbours = [model.agents[neighbour_id]
                            for neighbour_id in nearby_ids(agent,model,1)
                            if neighbour_id != id]
    end
    return model
end

## initialise model
model = setup()

## define a step
function agent_step!(agent,model)
    ## motivate
    mean_neighbour_intensity = mean([neighbour.intensity for neighbour in agent.neighbours])
    agent.profit_motivation = (1-agent.intensity) * model.properties[:profit_margin] * agent.profit_focus
    agent.sustainability_motivation =  agent.intensity* ( 1 + model.properties[:climate_effect] ) * agent.sustainability_focus
    agent.neighbour_motivation = ( mean_neighbour_intensity - agent.intensity) * agent.neighbour_focus * model.properties[:neighbour_margin]
    ## set bounds
    agent.profit_motivation = min(max(agent.profit_motivation,model.profit_motivation_minimum),model.profit_motivation_maximum)
    agent.sustainability_motivation = min(max(agent.sustainability_motivation,model.sustainability_motivation_minimum),model.sustainability_motivation_maximum)
    # agent.neighbour_motivation = min(max(agent.neighbour_motivation,model.neighbour_motivation_minimum),model.neighbour_motivation_maximum)
    ## take action
    agent.intensity += agent.profit_motivation - agent.sustainability_motivation + agent.neighbour_motivation
    # agent.intensity += agent.neighbour_motivation
    # # agent.intensity += agent.profit_motivation
    # # agent.intensity += agent.sustainability_motivation
    agent.intensity = min(max(agent.intensity,model.intensity_minimum),model.intensity_maximum)
end

function model_step!(model)
    model.properties["climate_effect"] += model.properties["climate_change_rate"]
    ## set bounds
    model.climate_effect = min(max(model.climate_effect,model.climate_effect_minimum),model.climate_effect_maximum)
end

## step
# step!(model,agent_step!)

## get data
keys = [
    :intensity,
    :profit_motivation,
    :sustainability_motivation,
    :neighbour_motivation,
]
    
ad,md = run!(model,agent_step!,10;adata=keys)
unique_steps = unique(ad[!,:step])
unique_steps = unique_steps[1:Int(round(length(unique_steps)/9)):end]
for key in names(ad)
    if key in ("step","id")
        continue
    end
    println( key)
    fig = Figure()
    for (istep,step) in enumerate(unique_steps)
        ij = [Int(floor((istep-1)/3)),mod(istep-1,3)]
        println( istep," ",ij)
        data = ad[ad[!,:step].==step,key]
        ax = Axis(
            fig[ij...],
            title=@sprintf("step=%d mean=%0.3f",step,mean(data)),
        )
        hist!(ax,data,bins=100)
        xlims!(-0.5,1)
    end
    text!(fig[0,0],0.05,0.75,text=key,space=:relative)
    display(GLMakie.Screen(),fig)
    # display(fig)
end

## plot output
fig, ax, abmobs = abm_plot(
    model;
    ac = agent -> get(ColorSchemes.inferno,agent.intensity), 
    as = 20,
    am = :circle,
    agent_step! = agent_step!,
    params = Dict(
        :profit_margin => 0:0.1:1,
        :neighbour_margin => 0:0.1:1,
    ),
)
display(fig)
