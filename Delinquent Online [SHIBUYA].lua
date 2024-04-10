local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Blood Demons",
    SubTitle = "by S_xnw",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options

do
    local Player = game.Players.LocalPlayer
    local Mouse = Player:GetMouse()
    local VirtualUser = game:GetService("VirtualUser")

    -- Anti-TP Bypass
    local gt = getrawmetatable(game)
    local old = gt.__newindex
    setreadonly(gt, false)
    gt.__newindex = function(self ,key, value)
        if key == 'CFrame' and self.Name == 'HumanoidRootPart' and self.Parent.Name == Player.Name and not checkcaller() then
            return old(self, key, self.CFrame)
        end
        old(self, key, value)
    end

    local Toggle = Tabs.Main:AddToggle("AFToggle", {
        Title = "AutoFarm",
        Default = false
    })

    Toggle:OnChanged(function()
        print("AutoFarm changed:", Options.AFToggle.Value)
      
        if not Options.AFToggle.Value then return end

        local QuestPlaces = {
            DeliveryQuest = {
                'DelieveryQuest',
                NPC = CFrame.new(-554.193481, 4.18258381, 53.6560211, -0.342042685, 0, -0.939684391, 0, 1, 0, 0.939684391, 0, -0.342042685),
                QPlace = CFrame.new(112.349998, 4.88687992, -150.858994, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            },
            BikeQuest = {
                'BikeQuest',
                NPC = CFrame.new(520.997437, 3.89599991, 357.441162, 0.642763317, -0, -0.766064942, 0, 1, -0, 0.766064942, 0, 0.642763317),
                QPlace = CFrame.new(-572.49939, 4.88687944, 90.7142868, 1, 0, 0, 0, 1, 0, 0, 0, 1)
            }
        }

        function WaitForInstances(Quest)
            if not workspace.NPCS:FindFirstChild(Quest) then
                print('Waiting for "NPCS/' .. Quest .. '" instance...')
                repeat task.wait()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = QuestPlaces[Quest].NPC
                until not Options.AFToggle.Value or workspace.NPCS:FindFirstChild(Quest)
                print('Instance loaded')
            end
            if not workspace.QuestPlaces:FindFirstChild(QuestPlaces[Quest][1]) then
                print('Waiting for "QuestPlaces/' .. QuestPlaces[Quest][1] .. '" instance...')
                repeat task.wait()
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = QuestPlaces[Quest].QPlace
                until not Options.AFToggle.Value or workspace.QuestPlaces:FindFirstChild(QuestPlaces[Quest][1])
                print('Instance loaded')
            end
        end

        function AutoFarm()
            if not Options.AFToggle.Value then return end

            pcall(function()
                WaitForInstances(Options.QuestsDropdown.Value)

                -- TP to NPC mission
                print('TP to NPC mission')
                if not workspace.QuestPlaces[QuestPlaces[Options.QuestsDropdown.Value][1]].Attachment:FindFirstChild('QuestPing') then
                    spawn(function()
                        repeat task.wait()
                            Player.Character.HumanoidRootPart.CFrame = QuestPlaces[Options.QuestsDropdown.Value].NPC
                        until not Options.AFToggle.Value or Player.PlayerGui.HUD.Dialogue.Visible --(Player.Character.HumanoidRootPart.Position - QuestPlaces[Options.QuestsDropdown.Value].NPC.Position).Magnitude <= 8
                    end)
                else
                    -- Complete Mission
                    print('Complete Mission')
                    repeat task.wait()
                        pcall(function()
                            Player.Character.HumanoidRootPart.CFrame = QuestPlaces[Options.QuestsDropdown.Value].QPlace
                        end)
                    until not Options.AFToggle.Value or not workspace.QuestPlaces[QuestPlaces[Options.QuestsDropdown.Value][1]].Attachment:FindFirstChild('QuestPing')

                    if not Options.AFToggle.Value then return end

                    AutoFarm()
                end

                -- Get Mission
                if not Player.PlayerGui.HUD.Dialogue.Visible then
                    print('Get Mission')
                    repeat
                        fireproximityprompt(workspace.NPCS[Options.QuestsDropdown.Value].Torso.ProximityPrompt)
                        task.wait(0.2)
                    until not Options.AFToggle.Value or Player.PlayerGui.HUD.Dialogue.Visible
    
                    if not Options.AFToggle.Value then return end
                end

                -- Accept Mission
                print('Accept Mission')
                local Accepted
                repeat task.wait(0.2)
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton1(Vector2.new(0, 0))
                    if Player.PlayerGui.HUD.Dialogue.Accept.Visible and not Accepted then
                        getconnections(game.Players.LocalPlayer.PlayerGui.HUD.Dialogue.Accept.Activated)[1].Function()
                        Accepted = true
                    end
                until not Options.AFToggle.Value or not Player.PlayerGui.HUD.Dialogue.Visible

                if not Options.AFToggle.Value then return end
                
                WaitForInstances(Options.QuestsDropdown.Value)

                -- Complete Mission
                print('Complete Mission')
                repeat task.wait()
                    pcall(function()
                        Player.Character.HumanoidRootPart.CFrame = QuestPlaces[Options.QuestsDropdown.Value].QPlace
                    end)
                until not Options.AFToggle.Value or not workspace.QuestPlaces[QuestPlaces[Options.QuestsDropdown.Value][1]].Attachment:FindFirstChild('QuestPing')

                if not Options.AFToggle.Value then return end
            end)

            -- Repeat Function
            AutoFarm()
        end

        AutoFarm()
    end)

    local Dropdown = Tabs.Main:AddDropdown("QuestsDropdown", {
        Title = "Quest",
        Values = {"DeliveryQuest", "BikeQuest"},
        Multi = false,
        Default = 2,
    })

    Dropdown:OnChanged(function(Value)
        print("Quest changed:", Value, Options.QuestsDropdown.Value)
    end)
    
    local Toggle2 = Tabs.Main:AddToggle("AimToggle", {
        Title = "Aim Assist",
        Default = false
    })

    Toggle2:OnChanged(function()
        print("Aim Assist changed:", Options.AimToggle.Value)
    end)

    local Slider = Tabs.Main:AddSlider("DistSlider", {
        Title = "Distance",
        Default = 20,
        Min = 10,
        Max = 50,
        Rounding = 1
    })

    if _G.Targets then
        _G.Targets:Destroy()
        task.wait()
    end
    _G.Targets = Instance.new('Folder')
    local ib_a = game:GetService("UserInputService").InputBegan:Connect(function(input, _gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton3 then
            local Target = Mouse.Target and game.Players:FindFirstChild(Mouse.Target:GetFullName():split(".")[3])
            if Target then
                if _G.Targets:FindFirstChild(Target.Name) then
                    _G.Targets[Target.Name]:Destroy()
                else
                    local newTarget = Instance.new('StringValue')
                    newTarget.Name = Target.Name
                    newTarget.Parent = _G.Targets
                end
            end
        end
    end)
    local Highlight = Instance.new("Highlight")
    Highlight.Name = 'AssistESP'
    Highlight.FillTransparency = 0.9
    
    local function Tween(instance: Instance, properties, duration: number, ...)
        local tween = game:GetService("TweenService"):Create(instance, TweenInfo.new(duration, ...), properties)
        tween:Play()
        return tween
    end

    _G.Targets.ChildAdded:Connect(function(child)
        local plr = game.Players[child.Name]
        local function addESP()
            plr.Character:WaitForChild('Humanoid')
            plr.Character:WaitForChild('HumanoidRootPart')

            local Highlight_Clone = Highlight:Clone()
            Highlight_Clone.Adornee = plr.Character
            Highlight_Clone.Parent = plr.Character.HumanoidRootPart
            Highlight_Clone.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

            local a = game:GetService("RunService").RenderStepped:Connect(function()
                if Options.AimToggle.Value and (Player.Character.HumanoidRootPart.Position - plr.Character.HumanoidRootPart.Position).Magnitude < tonumber(Options.DistSlider.Value) then
                    workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, plr.Character.HumanoidRootPart.Position)
                end
            end)
            plr.Character.Humanoid.Died:Connect(function()
                pcall(function()
                    a:Disconnect()
                end)
            end)
            _G.Targets.ChildRemoved:Connect(function(child_removed)
                if child == child_removed then
                    pcall(function()
                        if plr.Character.HumanoidRootPart:FindFirstChild('AssistESP') then
                            plr.Character.HumanoidRootPart:FindFirstChild('AssistESP'):Destroy()
                        end
                        a:Disconnect()
                    end)
                end
            end)
        end
        if plr.Character then
            addESP()
        end
        local a = plr.CharacterAdded:Connect(function()
            addESP()
        end)
        _G.Targets.ChildRemoved:Connect(function(child_removed)
            if child == child_removed then
                pcall(function()
                    if plr.Character.HumanoidRootPart:FindFirstChild('AssistESP') then
                        plr.Character.HumanoidRootPart:FindFirstChild('AssistESP'):Destroy()
                    end
                    a:Disconnect()
                end)
            end
        end)
    end)

    _G.Targets.Destroying:Connect(function()
        ib_a:Disconnect()
        _G.Targets:ClearAllChildren()
        _G.Targets = nil
    end)

end

InterfaceManager.Settings.Theme = "Darker"
InterfaceManager.Settings.MenuKeybind = "Delete" -- Used when theres no MinimizeKeybind

InterfaceManager:SetLibrary(Fluent)

InterfaceManager:SetFolder('BD_Settings')

InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(1)
