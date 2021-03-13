-- Spirit Panel for MJ & iakona's Spirit Island Mod --
useProgression = false
useAspect = 2

function onLoad(saved_data)
    Color.Add("SoftBlue", Color.new(0.45,0.6,0.7))
    sourceSpirit = getObjectFromGUID("SourceSpirit")
    sourceSpirit.call("load", {obj = self, saved_data = saved_data})
end

function RandomAspect()
    return sourceSpirit.call("randomAspect", {obj = self})
end
function PickSpirit(params)
    if params.aspect then
        if params.aspect == "Random" then
            useAspect = 1
        elseif params.aspect == "" then
            useAspect = 0
        else
            useAspect = 3
            aspect = params.aspect
        end
    end
    SetupSpirit(nil, params.color)
end
function SetupSpirit(_, player_color)
    sourceSpirit.call("setupSpirit", {obj = self, color = player_color})
end
function ToggleProgression()
    sourceSpirit.call("toggleProgression", {obj = self})
end
function ToggleAspect(_, _, alt_click)
    sourceSpirit.call("toggleAspect", {obj = self, alt_click = alt_click})
end
