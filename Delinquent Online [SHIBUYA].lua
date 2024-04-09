-- To stop the Autofarm or rerun the script you have to run "_G.AutoFarm = false" first
-- Para detener el Autofarm o volver a ejecutar el script tienen que ejecutar "_G.AutoFarm = false" primero

if _G.AutoFarm then return end
_G.AutoFarm = true

local Player = game.Players.LocalPlayer
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

-- AutoFarm function
function AutoFarm()
    if not _G.AutoFarm then return end

    if not workspace.NPCS:FindFirstChild('DeliveryQuest') or not workspace.QuestPlaces:FindFirstChild('DelieveryQuest') then
        -- Wait for instances
        print('Waiting for instances...')
        repeat task.wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-33, 3.89600039, -105)
        until workspace.NPCS:FindFirstChild('DeliveryQuest') and workspace.QuestPlaces:FindFirstChild('DelieveryQuest')
        print('Instances loaded')
    end

    -- TP to NPC mission
    print('TP to NPC mission')
    if not workspace.QuestPlaces.DelieveryQuest.Attachment:FindFirstChild('QuestPing') then
        spawn(function()
            repeat task.wait()
                Player.Character.HumanoidRootPart.CFrame = workspace.NPCS.DeliveryQuest.HumanoidRootPart.CFrame
            until not _G.AutoFarm or (Player.Character.HumanoidRootPart.Position - workspace.NPCS.DeliveryQuest.HumanoidRootPart.Position).Magnitude <= 8 and (workspace.QuestPlaces:FindFirstChild('DelieveryQuest') and workspace.QuestPlaces.DelieveryQuest:FindFirstChild('TouchInterest'))
        end)
    end

    -- Get Mission
    print('Get Mission')
    repeat
        fireproximityprompt(workspace.NPCS.DeliveryQuest.Torso.ProximityPrompt)
        task.wait(0.2)
    until not _G.AutoFarm or Player.PlayerGui.HUD.Dialogue.Visible

    -- Accept Mission
    print('Accept Mission')
    repeat task.wait(0.2)
        VirtualUser:CaptureController()
        VirtualUser:ClickButton1(Vector2.new(0, 0))
        if Player.PlayerGui.HUD.Dialogue.Accept.Visible then
            firesignal(Player.PlayerGui.HUD.Dialogue.Accept.Activated)
        end
    until not _G.AutoFarm or not Player.PlayerGui.HUD.Dialogue.Visible

    if not workspace.NPCS:FindFirstChild('DeliveryQuest') or not workspace.QuestPlaces:FindFirstChild('DelieveryQuest') then
        -- Wait for instances
        print('Waiting for instances...')
        repeat task.wait()
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-33, 3.89600039, -105)
        until workspace.NPCS:FindFirstChild('DeliveryQuest') and workspace.QuestPlaces:FindFirstChild('DelieveryQuest')
        print('Instances loaded')
    end

    -- Complete Mission
    print('Complete Mission')
    repeat task.wait()
        pcall(function()
            Player.Character.HumanoidRootPart.CFrame = workspace.QuestPlaces.DelieveryQuest.CFrame
        end)
    until not _G.AutoFarm or not workspace.QuestPlaces.DelieveryQuest.Attachment:FindFirstChild('QuestPing')

    -- Repeat Function
    AutoFarm()
end

AutoFarm()
