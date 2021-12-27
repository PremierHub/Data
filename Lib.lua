repeat
	wait()
until game:IsLoaded() and game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")

if not game:GetService("UserInputService").MouseIconEnabled then
	game:GetService("UserInputService").MouseIconEnabled = true
end

local player = game:GetService("Players").LocalPlayer
local mouse = player:GetMouse()
local input = game:GetService("UserInputService")

local library = { Enabled = true }
local page = {}
local section = {}
local BindedKeys = {}
local objects = {}
local utility = {}

local theme = {
	Background = Color3.fromRGB(25, 25, 25),
	DarkContrast = Color3.fromRGB(15, 15, 15),
	LightContrast = Color3.fromRGB(152, 152, 152),
	Accent = Color3.fromRGB(35, 35, 35),
	Glow = Color3.fromRGB(0, 0, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
	CloseBtn = Color3.fromRGB(224, 34, 34),
}
local DarkTheme = {
	Background = Color3.fromRGB(25, 25, 25),
	DarkContrast = Color3.fromRGB(15, 15, 15),
	LightContrast = Color3.fromRGB(152, 152, 152),
	Accent = Color3.fromRGB(35, 35, 35),
	Glow = Color3.fromRGB(0, 0, 0),
	TextColor = Color3.fromRGB(255, 255, 255),
}
local LightTheme = {
	Background = Color3.fromRGB(255, 255, 255),
	DarkContrast = Color3.fromRGB(220, 220, 220),
	LightContrast = Color3.fromRGB(80, 80, 80),
	Accent = Color3.fromRGB(205, 205, 205),
	Glow = Color3.fromRGB(0, 0, 0),
	TextColor = Color3.fromRGB(1, 1, 1),
}

do
	library.__index = library
	page.__index = page
	section.__index = section

	function newInstance(instance, properties, children)
		local object = Instance.new(instance)

		for i, v in pairs(properties or {}) do
			object[i] = v

			if typeof(v) == "Color3" then
				local theme = TableFind(theme, v)

				if theme then
					objects[theme] = objects[theme] or {}
					objects[theme][i] = objects[theme][i] or setmetatable({}, { _mode = "k" })

					table.insert(objects[theme][i], object)
				end
			end
		end

		for i, module in pairs(children or {}) do
			module.Parent = object
		end

		return object
	end
	function TableFind(table, value)
		if typeof(table) ~= "table" then
			return
		end
		for i, v in pairs(table) do
			if v == value then
				return i
			end
		end
	end
	function BetterWait()
		game:GetService("RunService").RenderStepped:Wait()
		return true
	end
	function utility:DraggingEnabled(frame, parent)
		parent = parent or frame

		-- stolen from wally or kiriot, kek
		local dragging = false
		local dragInput, mousePos, framePos

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				mousePos = input.Position
				framePos = parent.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)

		frame.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement then
				dragInput = input
			end
		end)

		input.InputChanged:Connect(function(input)
			if input == dragInput and dragging then
				local delta = input.Position - mousePos
				parent.Position = UDim2.new(
					framePos.X.Scale,
					framePos.X.Offset + delta.X,
					framePos.Y.Scale,
					framePos.Y.Offset + delta.Y
				)
			end
		end)
	end
	function utility:DraggingEnded(callback)
		table.insert(self.ended, callback)
	end
	function BetterTween(instance, properties, duration, ...)
		game:GetService("TweenService"):Create(instance, TweenInfo.new(duration, ...), properties):Play()
	end
	function PopAnim(object, shrink)
		local clone = object:Clone()

		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.Size = clone.Size - UDim2.new(0, shrink, 0, shrink)
		clone.Position = UDim2.new(0.5, 0, 0.5, 0)

		clone.Parent = object
		for i, v in pairs(clone:getChildren()) do
			if v.ClassName ~= "UICorner" then
				v:Destroy()
			end
		end
		--clone:ClearAllChildren()

		BetterTween(clone, { Size = object.Size }, 0.2)

		spawn(function()
			wait(0.2)

			clone:Destroy()
		end)

		return clone
	end
	function setTheme(Theme, Color)
		for property, objects in pairs(objects[Theme]) do
			for i, object in pairs(objects) do
				if not object.Parent or (object.Name == "Button" and object.Parent.Name == "ColorPicker") then
					objects[i] = nil
				else
					object[property] = Color
				end
			end
		end
		theme[Theme] = Color
	end
	function InitializeKeybind()
		utility.BindedKeys = {}
		utility.ended = {}

		local connection
		connection = input.InputBegan:Connect(function(key, proc)
			if not library.Enabled then
				connection:Disconnect()
			end
			if utility.BindedKeys[key.KeyCode] and not proc then
				for i, bind in pairs(utility.BindedKeys[key.KeyCode]) do
					bind()
				end
			end
		end)
	end
	function BindToKey(key, callback)
		utility.BindedKeys[key] = utility.BindedKeys[key] or {}

		table.insert(utility.BindedKeys[key], callback)

		return {
			UnBind = function()
				for i, bind in pairs(utility.BindedKeys[key]) do
					if bind == callback then
						table.remove(utility.BindedKeys[key], i)
					end
				end
			end,
		}
	end
	function KeyPressed()
		local key = input.InputBegan:Wait()

		while key.UserInputType ~= Enum.UserInputType.Keyboard do
			wait()
			key = input.InputBegan:Wait()
		end

		wait() -- overlapping connection

		return key
	end
	function getIndex(table, value)
		for i, v in pairs(table) do
			if tostring(i):lower() == value:lower() then
				return v
			end
		end
	end

	function library.new(config)
		if game.CoreGui:FindFirstChild("PremierHub") then
			game.CoreGui:FindFirstChild("PremierHub"):Destroy()
		end
		repeat
			wait()
		until not game.CoreGui:FindFirstChild("PremierHub")

		local AntiAFK
		AntiAFK = player.Idled:connect(function()
			if not library.Enabled then
				AntiAFK:Disconnect()
			end
			game:service("VirtualUser"):ClickButton2(Vector2.new())
		end)
		config = config or {}

		local Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:sub(1, 18)
		if game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:len() > 18 then
			Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name:sub(1, 15) .. "..."
		end

		local container = newInstance("ScreenGui", {
			Name = "PremierHub",
			Parent = game.CoreGui,
		}, {
			newInstance("Frame", {
				Name = "notifiContainer",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				newInstance("UIPadding", {
					PaddingBottom = UDim.new(0, 10),
					PaddingLeft = UDim.new(0, 10),
					PaddingRight = UDim.new(0, 10),
					PaddingTop = UDim.new(0, 10),
				}),
				newInstance("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 2),
					VerticalAlignment = Enum.VerticalAlignment.Bottom,
				}),
			}),
			newInstance("Frame", {
				BackgroundColor3 = theme.DarkContrast,
				ClipsDescendants = true,
				BorderSizePixel = 0,
				Position = UDim2.new(0.5, -270, 0.5, -170),
				Size = UDim2.new(0, 540, 0, 340),
			}, {
				newInstance("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				newInstance("Frame", {
					Name = "Pages_Container",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(0, 50, 1, -30),
				}, {
					newInstance("UIPadding", {
						PaddingBottom = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
						PaddingTop = UDim.new(0, 4),
					}),
					newInstance("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 2),
					}),
				}),
				newInstance("Frame", {
					Name = "Pages_Container_Bottom",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0, 30),
					Size = UDim2.new(0, 50, 1, -30),
				}, {
					newInstance("UIPadding", {
						PaddingBottom = UDim.new(0, 4),
						PaddingLeft = UDim.new(0, 4),
						PaddingRight = UDim.new(0, 4),
						PaddingTop = UDim.new(0, 4),
					}),
					newInstance("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Bottom,
						Padding = UDim.new(0, 2),
					}),
				}),
				newInstance("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 30),
				}, {
					newInstance("ImageButton", {
						Name = "Close",
						AutoButtonColor = false,
						BackgroundColor3 = theme.CloseBtn,
						Position = UDim2.new(1, -42, 0, 0),
						Size = UDim2.new(1.39999998, 0, 1, 0),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
					}, {
						newInstance("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
						newInstance("Frame", {
							Name = "Extra",
							BackgroundColor3 = theme.CloseBtn,
							BorderSizePixel = 0,
							Size = UDim2.new(0, 5, 1, 0),
						}),
						newInstance("Frame", {
							Name = "Extra",
							BackgroundColor3 = theme.CloseBtn,
							BorderSizePixel = 0,
							Position = UDim2.new(0, 0, 1, -5),
							Size = UDim2.new(1, 0, 0, 5),
						}),
						newInstance("ImageLabel", {
							BackgroundColor3 = theme.TextColor,
							BackgroundTransparency = 1,
							Position = UDim2.new(0.5, -7, 0.5, -7),
							Size = UDim2.new(0, 13, 0, 13),
							Image = "rbxassetid://7737475194",
							ImageColor3 = theme.TextColor,
							ScaleType = Enum.ScaleType.Slice,
						}),
					}),
					newInstance("ImageLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 5, 0.5, 0),
						Size = UDim2.new(0, 20, 0, 20),
						Image = "rbxassetid://7618136617",
						ImageColor3 = theme.TextColor,
					}),
					newInstance("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 30, 0, 1),
						Size = UDim2.new(0, 100, 1, 0),
						Font = Enum.Font.Gotham,
						Text = "<b>" .. Title .. "</b>",
						RichText = true,
						TextColor3 = theme.TextColor,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
					newInstance("Frame", {
						Name = "ChangeTheme",
						BackgroundColor3 = theme.Background,
						BorderSizePixel = 0,
						Position = UDim2.new(1, -70, 0.1, 0),
						Size = UDim2.new(0, 24, 0, 24),
					}, {
						newInstance("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
						newInstance("ImageButton", {
							BackgroundTransparency = 1,
							Position = UDim2.new(0.15, 0, 0.15, 0),
							Size = UDim2.new(0, 16, 0, 16),
							ImageColor3 = theme.TextColor,
							Image = "rbxassetid://7072719446",
						}),
					}),
					newInstance("TextBox", {
						BackgroundColor3 = theme.Background,
						TextColor3 = theme.TextColor,
						Text = "",
						PlaceholderText = "Search",
						TextXAlignment = Enum.TextXAlignment.Left,
						PlaceholderColor3 = theme.LightContrast,
						MaxVisibleGraphemes = 38,
						Position = UDim2.new(1, -375, 0.1, 0),
						Size = UDim2.new(0, 280, 0.8, 0),
					}, {
						newInstance("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
						newInstance("UIPadding", {
							PaddingLeft = UDim.new(0, 5),
							PaddingTop = UDim.new(0, 1),
						}),
					}),
					newInstance("Frame", {
						BackgroundColor3 = theme.Background,
						BorderSizePixel = 0,
						Position = UDim2.new(1, -100, 0.1, 0),
						Size = UDim2.new(0, 24, 0, 24),
					}, {
						newInstance("UICorner", {
							CornerRadius = UDim.new(0, 5),
						}),
						newInstance("ImageButton", {
							BackgroundTransparency = 1,
							Position = UDim2.new(0.15, 0, 0.15, 0),
							Size = UDim2.new(0, 16, 0, 16),
							Image = "rbxassetid://7072721559",
							ImageColor3 = theme.TextColor,
						}),
					}),
				}),
				newInstance("ImageLabel", {
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 50, 0, 30),
					Size = UDim2.new(1, -50, 1, -30),
					Image = "rbxassetid://7445691283",
					ImageColor3 = theme.Background,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(5, 5, 25, 25),
				}),
				newInstance("ImageLabel", {
					Name = "Shadow",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -15, 0, -15),
					Size = UDim2.new(1, 30, 1, 30),
					Image = "rbxassetid://5554236805",
					ImageColor3 = theme.Glow,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(23, 23, 277, 277),
				}),
			}),
		})

		local SearchTextBox = container.Frame.Frame.TextBox
		local SearchButton = container.Frame.Frame.Frame.ImageButton
		local ChangeTheme = container.Frame.Frame.ChangeTheme.ImageButton
		local Theme = "Dark"
		SearchTextBox.Changed:Connect(function()
			SearchTextBox.Text = SearchTextBox.Text:sub(1, 38)
		end)
		SearchButton.MouseButton1Click:Connect(function()
			PopAnim(SearchButton, 10)
		end)
		ChangeTheme.MouseButton1Click:Connect(function()
			PopAnim(ChangeTheme, 10)
			BetterTween(ChangeTheme.Parent, { BackgroundColor3 = theme.Accent }, 0.25)
			wait(0.25)
			ChangeTheme.Parent.BackgroundColor3 = theme.Background
			if Theme == "Dark" then
				ChangeTheme.Image = "rbxassetid://7072723105"
				Theme = "Light"

				setTheme("Background", LightTheme.Background)
				setTheme("DarkContrast", LightTheme.DarkContrast)
				setTheme("LightContrast", LightTheme.LightContrast)
				setTheme("Accent", LightTheme.Accent)
				setTheme("Glow", LightTheme.Glow)
				setTheme("TextColor", LightTheme.TextColor)
			elseif Theme == "Light" then
				ChangeTheme.Image = "rbxassetid://7072719446"
				Theme = "Dark"

				setTheme("Background", DarkTheme.Background)
				setTheme("DarkContrast", DarkTheme.DarkContrast)
				setTheme("LightContrast", DarkTheme.LightContrast)
				setTheme("Accent", DarkTheme.Accent)
				setTheme("Glow", DarkTheme.Glow)
				setTheme("TextColor", DarkTheme.TextColor)
			end
			library.focusedPage.button.BottomPart.ImageColor3 = theme.TextColor
		end)

		container.Frame.Frame.Close.MouseButton1Click:Connect(function()
			BetterTween(container.Frame, { Size = UDim2.new(0, 540, 0, 0) }, 0.2)
			wait(0.2)
			container:Destroy()
		end)

		InitializeKeybind()
		utility:DraggingEnabled(container.Frame, container.Frame)

		container.Parent.ChildRemoved:connect(function(Obj)
			if Obj == container then
				library.Enabled = false
			end
		end)

		return setmetatable({
			container = container,
			notifiContainer = container.notifiContainer,
			pagesContainer = container.Frame.Pages_Container,
			pagesContainerBottom = container.Frame.Pages_Container_Bottom,
			pages = {},
		}, library)
	end
	function page.new(config)
		config = config or {}

		local Position = getIndex(config, "library").pagesContainer
		if getIndex(config, "Position") == 1 then
			Position = getIndex(config, "library").pagesContainerBottom
		end

		local Button = newInstance("Frame", {
			Parent = Position,
			BackgroundColor3 = theme.Accent,
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
		}, {
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, 4),
			}),
			newInstance("Frame", {
				Name = "Toggle",
				AnchorPoint = Vector2.new(0, 0.5),
				BorderSizePixel = 0,
				BackgroundColor3 = theme.TextColor,
				Position = UDim2.new(0, 0, 0.5, 0),
				Size = UDim2.new(0, 2, 0.5, 0),
				Visible = false,
			}, {
				newInstance("UICorner", {
					CornerRadius = UDim.new(1, 2),
				}),
			}),
			newInstance("ImageButton", {
				Name = "BottomPart",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.25, 0, 0.3, 0),
				Size = UDim2.new(0, 18, 0, 18),
				Image = "rbxassetid://" .. (getIndex(config, "icon") or "7618136617"),
				ImageColor3 = theme.LightContrast,
			}),
		})

		local container = newInstance("ScrollingFrame", {
			Parent = getIndex(config, "library").container.Frame.ImageLabel,
			Active = true,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -10, 1, -10),
			Position = UDim2.new(0, 5, 0, 5),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ClipsDescendants = true,
			ScrollBarThickness = 0,
			ScrollBarImageColor3 = theme.TextColor,
			Visible = false,
		}, {
			newInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
			}),
		})

		return setmetatable({
			library = library,
			container = container,
			button = Button,
			sections = {},
		}, page)
	end
	function section.home(config)
		local config = config or {}
		local container = newInstance("Frame", {
			Parent = getIndex(config, "page").container,
			Size = UDim2.new(1, 0, 0, 280),
			BackgroundColor3 = theme.DarkContrast,
			BorderSizePixel = 0,
		}, {
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			newInstance("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),
			newInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),
			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				TextColor3 = theme.TextColor,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				RichText = true,
				TextSize = 16,
				Size = UDim2.new(0, 200, 0, 17),
			}),
			newInstance("TextLabel", {
				Name = "TextLabel2",
				BackgroundTransparency = 1,
				Font = Enum.Font.Gotham,
				TextColor3 = theme.LightContrast,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextSize = 12,
				Size = UDim2.new(0, 200, 0, 14),
			}),
			newInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(0, 0, 0, 10),
			}),
			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				TextColor3 = theme.LightContrast,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "SHORTCUTS",
				TextSize = 13,
				Size = UDim2.new(0, 200, 0, 17),
			}),
			newInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
			}, {
				newInstance("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 150, 0, 30),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 150, 0, 30),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
			}),
			newInstance("TextLabel", {
				BackgroundTransparency = 1,
				TextColor3 = theme.LightContrast,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = "PAGES",
				TextSize = 13,
				Size = UDim2.new(0, 200, 0, 17),
			}),
			newInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 30),
			}, {
				newInstance("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = UDim.new(0, 4),
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 150, 0, 30),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 150, 0, 30),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.Background,
					BorderSizePixel = 0,
					Size = UDim2.new(0, 150, 0, 30),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
			}),
		})

		spawn(function()
			while true do
				wait()
				wait()
				pcall(function()
					container.TextLabel.Text = "<b>" .. os.date("%X") .. " " .. os.date("%p") .. "</b>"
					container.TextLabel2.Text = os.date("%A") .. ", " .. os.date("%d") .. " " .. os.date("%b")
				end)
			end
		end)

		return setmetatable({
			page = getIndex(config, "page"),
			container = container,
			colorpickers = {},
			modules = { container },
			binds = {},
			lists = {},
		}, section)
	end
	function section.new(config)
		local config = config or {}
		local container = newInstance("Frame", {
			Parent = getIndex(config, "page").container,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundColor3 = theme.DarkContrast,
		}, {
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			newInstance("UIPadding", {
				PaddingTop = UDim.new(0, 10),
				PaddingLeft = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
			}),
			newInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),
		})

		return setmetatable({
			page = getIndex(config, "page"),
			container = container,
			colorpickers = {},
			modules = {},
			binds = {},
			lists = {},
		}, section)
	end

	function library:addPage(config)
		config = config or {}
		config.library = self
		local page = page.new(config)
		local button = page.button.BottomPart

		button.MouseButton1Click:Connect(function()
			PopAnim(button, 10)
			self:SelectPage(page, true)
		end)

		return page
	end
	function page:addSection(config)
		local config = config or {}
		config.page = self
		local section = section.new(config)

		table.insert(self.sections, section)

		return section
	end
	function page:addSectionHome(config)
		local config = config or {}
		config.page = self
		local section = section.home(config)

		table.insert(self.sections, section)

		return section
	end
	function library:Notify(config)
		local config = config or {}

		-- standard create
		local notification = newInstance("Frame", {
			Name = "Notification",
			Parent = self.notifiContainer,
			BackgroundColor3 = theme.Background,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			BackgroundTransparency = 0.5,
			Size = UDim2.new(0, 0, 0, 50),
		}, {
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			newInstance("ImageLabel", {
				Name = "Shadow",
				BackgroundTransparency = 1,
				Position = UDim2.new(0, -15, 0, -15),
				Size = UDim2.new(1, 30, 1, 30),
				Image = "rbxassetid://5554236805",
				ImageColor3 = theme.Glow,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(23, 23, 277, 277),
			}),
			newInstance("Frame", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
			}, {
				newInstance("UIPadding", {
					PaddingLeft = UDim.new(0, 5),
				}),
				newInstance("UIListLayout"),
				newInstance("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.5, 0),
				}, {
					newInstance("UIListLayout", {
						Padding = UDim.new(0, 5),
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					newInstance("ImageLabel", {
						BackgroundTransparency = 1,
						Size = UDim2.new(0, 16, 0, 16),
						Image = "rbxassetid://" .. (getIndex(config, "icon") or "7618136617"),
						ImageColor3 = theme.TextColor,
					}),
					newInstance("TextLabel", {
						Name = "Title",
						Text = getIndex(config, "Title") or "Notification",
						BackgroundTransparency = 1,
						Size = UDim2.new(0.9, 0, 1, 0),
						Font = Enum.Font.GothamSemibold,
						TextColor3 = theme.TextColor,
						TextSize = 14,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				}),
				newInstance("TextLabel", {
					Name = "Text",
					Text = getIndex(config, "Text") or "Text of Notification",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0.5, 0),
					Font = Enum.Font.Gotham,
					TextColor3 = theme.LightContrast,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
			}),
		})

		BetterTween(notification, { Size = UDim2.new(0, 250, 0, 50) }, 0.2)
		-- dragging
		utility:DraggingEnabled(notification)

		local active = true
		local close = function()
			if not active then
				return
			end

			active = false
			notification.ClipsDescendants = true

			library.lastNotification = notification.Position

			BetterTween(notification, { Size = UDim2.new(0, 0, 0, 50) }, 0.2)

			wait(0.2)
			notification:Destroy()
		end
		spawn(function()
			if
				getIndex(config, "Time") and typeof(getIndex(config, "Time")) == "number"
				or not getIndex(config, "Time")
			then
				wait(getIndex(config, "Time") or 5)
				close()
			end
		end)
	end

	function library:SelectPage(page, toggle)
		if toggle and self.focusedPage == page then -- already selected
			return
		end

		local button = page.button.BottomPart

		if toggle then
			-- page button
			button.ImageColor3 = theme.TextColor
			page.button.Toggle.Visible = true
			BetterTween(page.button, { BackgroundTransparency = 0 }, 0.2)

			-- update selected page
			local focusedPage = self.focusedPage
			self.focusedPage = page
			library.focusedPage = page

			if focusedPage then
				self:SelectPage(focusedPage)
			end

			wait(0.1)

			page.container.Visible = true

			if focusedPage then
				focusedPage.container.Visible = false
			end

			for i, section in pairs(page.sections) do
				section:Resize()
			end
			wait()
			page:Resize()
			spawn(function()
				wait(0.2)
				page:Resize()
			end)
		else
			-- page button
			page.button.Toggle.Visible = false
			button.ImageColor3 = theme.LightContrast
			BetterTween(page.button, { BackgroundTransparency = 1 }, 0.2)
			page:Resize()
		end
	end
	function library:toggle()
		if self.toggling then
			return
		end

		self.toggling = true

		local container = self.container:FindFirstChild("Frame")
		if not container then
			return
		end

		if self.position then
			BetterTween(container, {
				Size = UDim2.new(0, 540, 0, 340),
				Position = self.position,
			}, 0.2)

			wait(0.2)

			self.position = nil
		else
			self.position = container.Position

			BetterTween(container, { Size = UDim2.new(0, 540, 0, 0) }, 0.2)
			wait(0.2)
		end

		self.toggling = false
	end
	function page:Resize()
		local size = 0

		for i, section in pairs(self.sections) do
			size = size + section.container.AbsoluteSize.Y
		end

		self.container.CanvasSize = UDim2.new(0, 0, 0, size)
	end
	function section:Resize()
		-- if self.page.library.focusedPage ~= self.page then
		-- 	return
		-- end
		local Padding = 10
		local ListPadding = 4
		local size = (Padding * 2) - ListPadding

		for i, module in pairs(self.modules) do
			size = size + module.AbsoluteSize.Y + ListPadding
		end

		BetterTween(self.container, { Size = UDim2.new(1, 0, 0, size) }, 0.05)
	end
	function section:getModule(info)
		if table.find(self.modules, info) then
			return info
		end

		for i, module in pairs(self.modules) do
			if (module:FindFirstChild("Title") or module:FindFirstChild("TextBox", true)).Text == info then
				return module
			end
		end

		error("No module found under " .. tostring(info))
	end

	--#region Modules
	function section:addButton(config)
		config = config or {}
		local button = newInstance("ImageButton", {
			Name = "Button_Element",
			Parent = self.container,
			BackgroundColor3 = theme.Background,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 0, 25),
		}, {
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, getIndex(config, "Corner") or 5),
			}),
			newInstance("TextLabel", {
				Name = "Title",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.GothamBold,
				Text = getIndex(config, "Title") or "Button",
				TextColor3 = theme.TextColor,
				TextSize = 12,
			}),
		})

		table.insert(self.modules, button)

		local text = button.Title
		local debounce

		button.MouseButton1Click:Connect(function()
			if debounce then
				return
			end

			-- animation
			button.BackgroundColor3 = theme.Accent
			PopAnim(button, 10)
			button.BackgroundColor3 = theme.Background

			debounce = true
			BetterTween(text, { TextSize = 14 }, 0.2)
			wait(0.2)
			BetterTween(text, { TextSize = 12 }, 0.2)

			if getIndex(config, "CallBack") then
				getIndex(config, "CallBack")(function(...)
					self:updateButton(button, { ... })
				end)
			end

			debounce = false
		end)
		return button
	end
	function section:addLabel(config)
		config = config or {}
		local label = newInstance("TextLabel", {
			Name = "Label",
			Parent = self.container,
			BackgroundTransparency = getIndex(config, "BackgroundTransparency") or 1,
			TextSize = getIndex(config, "TextSize") or 12,
			TextXAlignment = getIndex(config, "TextXAlignment") or Enum.TextXAlignment.Left,
			Size = getIndex(config, "Size") or UDim2.new(1, 0, 0, 12),
			Font = getIndex(config, "Font") or Enum.Font.Gotham,
			TextColor3 = theme.TextColor,
			TextWrapped = true,
			RichText = true,
			TextYAlignment = 0,
		})

		for i = 1, (getIndex(config, "Text") or "Text Label"):len() do
			label.Text = (getIndex(config, "Text") or "Text Label"):sub(1, i)
			label.Size = UDim2.new(1, 0, 0, label.TextBounds.Y)
		end

		label:GetPropertyChangedSignal("Size"):Connect(function()
			self:Resize()
		end)

		table.insert(self.modules, label)
		return label
	end
	function section:addSlider(config)
		config = config or {}
		local slider

		if getIndex(config, "Style") and getIndex(config, "Style") >= 2 then
			slider = newInstance("ImageButton", {
				Name = "Slider_Element",
				BackgroundTransparency = 1,
				Parent = self.container,
				Size = UDim2.new(1, 0, 0, 30),
			}, {
				newInstance("UIListLayout", {
					Padding = UDim.new(0, 15),
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					FillDirection = Enum.FillDirection.Horizontal,
				}),
				newInstance("TextLabel", {
					Name = "Title",
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					TextColor3 = theme.TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				newInstance("Frame", {
					Name = "Slider",
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
				}, {
					newInstance("UIListLayout", {
						VerticalAlignment = Enum.VerticalAlignment.Center,
					}),
					newInstance("Frame", {
						Name = "Bar",
						Size = UDim2.new(1, 0, 0, 4),
						BorderSizePixel = 0,
						BackgroundColor3 = theme.LightContrast,
					}, {
						newInstance("UICorner"),
						newInstance("Frame", {
							Name = "Fill",
							Size = UDim2.new(0.8, 0, 1, 0),
							BorderSizePixel = 0,
							BackgroundColor3 = theme.TextColor,
						}, {
							newInstance("UIListLayout", {
								VerticalAlignment = Enum.VerticalAlignment.Center,
								HorizontalAlignment = Enum.HorizontalAlignment.Right,
							}),
							newInstance("UICorner"),
							newInstance("Frame", {
								Name = "Circle",
								Size = UDim2.new(0, 10, 0, 10),
								BackgroundColor3 = theme.TextColor,
								BorderSizePixel = 0,
								BackgroundTransparency = 1,
							}, {
								newInstance("UICorner"),
								newInstance("Frame", {
									Name = "Value",
									ClipsDescendants = true,
									Size = UDim2.new(0, 40, 0, 15),
									Position = UDim2.new(0, -15, 0, -18),
									BackgroundColor3 = theme.TextColor,
									BorderSizePixel = 0,
									BackgroundTransparency = 1,
								}, {
									newInstance("UICorner"),
									newInstance("UIListLayout", {
										VerticalAlignment = Enum.VerticalAlignment.Center,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
									}),
									newInstance("TextLabel", {
										BackgroundTransparency = 1,
										Font = Enum.Font.GothamSemibold,
										RichText = true,
										TextColor3 = theme.DarkContrast,
										TextSize = 12,
										TextXAlignment = Enum.TextXAlignment.Center,
										TextTransparency = 1,
									}),
								}),
							}),
						}),
					}),
				}),
			})
		else
			slider = newInstance("ImageButton", {
				Name = "Slider_Element",
				BackgroundTransparency = 1,
				Parent = self.container,
				Size = UDim2.new(1, 0, 0, 40),
			}, {
				newInstance("UIListLayout", {
					Padding = UDim.new(0, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Vertical,
					VerticalAlignment = Enum.VerticalAlignment.Center,
				}),
				newInstance("TextLabel", {
					Name = "Title",
					LayoutOrder = 1,
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamBold,
					TextColor3 = theme.TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				newInstance("Frame", {
					BackgroundTransparency = 1,
					LayoutOrder = 2,
					Size = UDim2.new(1, 0, 0, 20),
				}, {
					newInstance("UIListLayout", {
						Padding = UDim.new(0, 0),
						SortOrder = Enum.SortOrder.LayoutOrder,
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					}),
					newInstance("Frame", {
						Name = "Slider",
						LayoutOrder = 1,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, -86, 1, 0),
					}, {
						newInstance("UIListLayout", {
							VerticalAlignment = Enum.VerticalAlignment.Center,
						}),
						newInstance("Frame", {
							Name = "Bar",
							Size = UDim2.new(1, 0, 0, 4),
							BorderSizePixel = 0,
							BackgroundColor3 = theme.LightContrast,
						}, {
							newInstance("UICorner"),
							newInstance("Frame", {
								Name = "Fill",
								Size = UDim2.new(0.8, 0, 1, 0),
								BorderSizePixel = 0,
								BackgroundColor3 = theme.TextColor,
							}, {
								newInstance("UIListLayout", {
									VerticalAlignment = Enum.VerticalAlignment.Center,
									HorizontalAlignment = Enum.HorizontalAlignment.Right,
								}),
								newInstance("UICorner"),
								newInstance("Frame", {
									Name = "Circle",
									Size = UDim2.new(0, 10, 0, 10),
									BackgroundColor3 = theme.TextColor,
									BorderSizePixel = 0,
									BackgroundTransparency = 1,
								}, {
									newInstance("UICorner"),
								}),
							}),
						}),
					}),
					newInstance("Frame", {
						BackgroundTransparency = 1,
						LayoutOrder = 2,
						Size = UDim2.new(0, 5, 0, 0),
					}),
					newInstance("ImageButton", {
						Name = "plus",
						LayoutOrder = 3,
						BackgroundTransparency = 1,
						ImageColor3 = theme.TextColor,
						Image = "rbxassetid://7072720870",
						Size = UDim2.new(0, 18, 0, 18),
					}),
					newInstance("TextBox", {
						Name = "TextBox",
						LayoutOrder = 4,
						BackgroundColor3 = theme.Background,
						BorderSizePixel = 0,
						Size = UDim2.new(0, 40, 0, 18),
						ZIndex = 3,
						Font = Enum.Font.GothamSemibold,
						Text = getIndex(config, "Default") or getIndex(config, "Min") or 0,
						TextColor3 = theme.TextColor,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Right,
					}, {
						newInstance("UICorner"),
						newInstance("UIPadding", {
							PaddingRight = UDim.new(0, 5),
						}),
					}),
					newInstance("ImageButton", {
						Name = "minus",
						LayoutOrder = 5,
						BackgroundTransparency = 1,
						ImageColor3 = theme.TextColor,
						Image = "rbxassetid://7072719338",
						Size = UDim2.new(0, 18, 0, 18),
					}),
				}),
			})
		end

		table.insert(self.modules, slider)

		local allowed = {
			[""] = true,
			["-"] = true,
		}

		local title = slider.Title
		local textbox = slider:FindFirstChild("Frame") and slider:FindFirstChild("Frame").TextBox
		local circle = slider:FindFirstChild("Frame") and slider.Frame:FindFirstChild("Slider").Bar.Fill.Circle
			or slider:FindFirstChild("Slider") and slider:FindFirstChild("Slider").Bar.Fill.Circle

		for i = 1, (getIndex(config, "Title") or "Slider"):len() do
			title.Text = (getIndex(config, "Title") or "Slider"):sub(1, i)
			title.Size = UDim2.new(0, title.TextBounds.X, 0, title.TextBounds.Y)
		end
		if slider:FindFirstChild("Slider") then
			slider:FindFirstChild("Slider").Size = UDim2.new(1, -title.AbsoluteSize.X - 20, 0, title.AbsoluteSize.Y)
		end

		local value = getIndex(config, "Default") or getIndex(config, "Min") or 0
		local dragging, last

		local callback = function(value)
			if getIndex(config, "CallBack") then
				getIndex(config, "CallBack")(value, function(...)
					self:updateSlider(slider, { ... })
				end)
			end
		end

		self:updateSlider(
			slider,
			{ Title = nil, Value = value, Min = getIndex(config, "Min") or 0, Max = getIndex(config, "Max") or 0 }
		)

		if slider:FindFirstChild("Frame") and slider.Frame:FindFirstChild("plus") then
			slider.Frame:FindFirstChild("plus").MouseButton1Click:Connect(function()
				if tonumber(textbox.Text) < getIndex(config, "Max") then
					PopAnim(slider.Frame:FindFirstChild("plus"), 10)
					textbox.Text = tonumber(textbox.Text) + 1
				end
			end)
		end
		if slider:FindFirstChild("Frame") and slider.Frame:FindFirstChild("minus") then
			slider.Frame:FindFirstChild("minus").MouseButton1Click:Connect(function()
				if tonumber(textbox.Text) > (getIndex(config, "Min") or 0) then
					PopAnim(slider.Frame:FindFirstChild("minus"), 10)
					textbox.Text = tonumber(textbox.Text) - 1
				end
			end)
		end

		slider.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)

				while dragging do
					wait()
					BetterTween(circle, { BackgroundTransparency = 0 }, 0.1)
					if circle:FindFirstChild("Value") then
						BetterTween(circle.Value, { BackgroundTransparency = 0 }, 0.1)
						BetterTween(circle.Value.TextLabel, { TextTransparency = 0 }, 0.1)
					end

					value = self:updateSlider(
						slider,
						{
							Title = nil,
							Value = nil,
							Min = getIndex(config, "Min") or 0,
							Max = getIndex(config, "Max") or 0,
							LastValue = value,
						}
					)
					callback(value)
					if circle:FindFirstChild("Value") then
						circle.Value.TextLabel.Text = value
					end

					BetterWait()
				end

				wait(0.5)
				BetterTween(circle, { BackgroundTransparency = 1 }, 0.2)
				if circle:FindFirstChild("Value") then
					BetterTween(circle.Value, { BackgroundTransparency = 1 }, 0.2)
					BetterTween(circle.Value.TextLabel, { TextTransparency = 1 }, 0.2)
				end
			end
		end)

		if textbox then
			textbox.FocusLost:Connect(function()
				if not tonumber(textbox.Text) then
					value = self:updateSlider(
						slider,
						{
							Title = nil,
							Value = value,
							Min = getIndex(config, "Min") or 0,
							Max = getIndex(config, "Max") or 0,
						}
					)
					callback(value)
				elseif tonumber(textbox.Text) > (getIndex(config, "Max") or 0) then
					textbox.Text = getIndex(config, "Max") or 0
				end
			end)
			textbox:GetPropertyChangedSignal("Text"):Connect(function()
				local text = textbox.Text

				if not allowed[text] and not tonumber(text) then
					textbox.Text = text:sub(1, #text - 1)
				elseif not allowed[text] then
					value = self:updateSlider(
						slider,
						{
							Title = nil,
							Value = tonumber(text) or value,
							Min = getIndex(config, "Min") or 0,
							Max = getIndex(config, "Max") or 0,
						}
					)
					callback(value)
				end
				textbox.Text = textbox.Text:sub(
					1,
					getIndex(config, "Max") and (tostring(getIndex(config, "Max"))):len() or 0
				)
			end)
		end

		return slider
	end
	function section:addToggle(config)
		config = config or {}
		local toggle
		if getIndex(config, "Style") and getIndex(config, "Style") ~= 1 then
			if getIndex(config, "Style") >= 2 then
				toggle = newInstance("ImageButton", {
					Name = "Toggle_Element",
					BackgroundTransparency = 1,
					Parent = self.container,
					Size = UDim2.new(1, 0, 0, 25),
				}, {
					newInstance("UIListLayout", {
						Padding = UDim.new(0, 10),
						VerticalAlignment = Enum.VerticalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal,
					}),
					newInstance("Frame", {
						BackgroundColor3 = theme.Background,
						BorderSizePixel = 0,
						Position = UDim2.new(1, -50, 0.5, -8),
						Size = UDim2.new(0, 40, 0, 16),
					}, {
						newInstance("UICorner", {
							CornerRadius = UDim.new(100, 100),
						}),
						newInstance("Frame", {
							Name = "Button",
							BackgroundColor3 = theme.TextColor,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(0, 16, 0, 16),
						}, {
							newInstance("UICorner", {
								CornerRadius = UDim.new(100, 100),
							}),
						}),
					}),
					newInstance("TextLabel", {
						Name = "Title",
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 10, 0.5, 1),
						Size = UDim2.new(0.5, 0, 1, 0),
						Font = Enum.Font.GothamBold,
						Text = getIndex(config, "Title") or "Toggle",
						TextColor3 = theme.TextColor,
						TextSize = 12,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				})
			end
		else
			toggle = newInstance("ImageButton", {
				Name = "Toggle_Element",
				Parent = self.container,
				AutoButtonColor = false,
				BackgroundColor3 = theme.Background,
				Size = UDim2.new(1, 0, 0, 25),
			}, {
				newInstance("UICorner", {
					CornerRadius = UDim.new(0, getIndex(config, "Corner") or 5),
				}),
				newInstance("TextLabel", {
					Name = "Title",
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0.5, 1),
					Size = UDim2.new(0.5, 0, 1, 0),
					Font = Enum.Font.GothamBold,
					Text = getIndex(config, "Title") or "Toggle",
					TextColor3 = theme.TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.DarkContrast,
					BorderSizePixel = 0,
					Position = UDim2.new(1, -50, 0.5, -8),
					Size = UDim2.new(0, 40, 0, 16),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(100, 100),
					}),
					newInstance("Frame", {
						Name = "Button",
						BackgroundColor3 = theme.TextColor,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(0, 16, 0, 16),
					}, {
						newInstance("UICorner", {
							CornerRadius = UDim.new(100, 100),
						}),
					}),
				}),
			})
		end
		local button = toggle.Frame.Button

		table.insert(self.modules, toggle)
		--self:Resize()

		local active = getIndex(config, "Default") or false
		self:updateToggle(toggle, { Default = active })

		toggle.MouseButton1Click:Connect(function()
			active = not active
			self:updateToggle(toggle, { Default = active })

			if getIndex(config, "CallBack") then
				getIndex(config, "CallBack")(active, function(...)
					self:updateToggle(toggle, { ... })
				end)
			end
		end)

		return toggle
	end
	function section:addCheckbox(config)
		config = config or {}
		local checkbox = newInstance("ImageButton", {
			Name = "Checkbox_Element",
			BackgroundTransparency = 1,
			Parent = self.container,
			Size = UDim2.new(1, 0, 0, 25),
		}, {
			newInstance("UIListLayout", {
				Padding = UDim.new(0, 10),
				VerticalAlignment = Enum.VerticalAlignment.Center,
				FillDirection = Enum.FillDirection.Horizontal,
			}),
			newInstance("ImageButton", {
				BackgroundColor3 = theme.TextColor,
				Size = UDim2.new(0, 20, 0, 20),
				AutoButtonColor = false,
			}, {
				newInstance("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				newInstance("Frame", {
					BackgroundColor3 = theme.DarkContrast,
					Size = UDim2.new(0, 18, 0, 18),
					Position = UDim2.new(0, 1, 0, 1),
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
				}),
				newInstance("ImageLabel", {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 16, 0, 16),
					Position = UDim2.new(0, 2, 0, 2),
					Image = "rbxassetid://7072706620",
					ImageColor3 = theme.DarkContrast,
					ImageTransparency = 1,
				}),
			}),
			newInstance("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(0.5, 0, 1, 0),
				Font = Enum.Font.GothamBold,
				Text = getIndex(config, "Title") or "Checkbox",
				TextColor3 = theme.TextColor,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
		})

		local active = getIndex(config, "Default") or false

		checkbox.MouseButton1Click:Connect(function()
			active = not active
			PopAnim(checkbox.ImageButton, 10)
			self:updateCheckbox(checkbox, { Default = active })

			if getIndex(config, "CallBack") then
				getIndex(config, "CallBack")(active, function(...)
					self:updateCheckbox(checkbox, { ... })
				end)
			end
		end)

		table.insert(self.modules, checkbox)
		--self:Resize()

		return checkbox
	end
	function section:addDropdown(config)
		config = config or {}
		local dropdown = newInstance("Frame", {
			Name = "Dropdown_Element",
			Parent = self.container,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 30),
			ClipsDescendants = true,
		}, {
			newInstance("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 4),
			}),
			newInstance("Frame", {
				BackgroundColor3 = theme.Background,
				Size = UDim2.new(1, 0, 0, 30),
			}, {
				newInstance("UIPadding", {
					PaddingBottom = UDim.new(0, 5),
					PaddingLeft = UDim.new(0, 5),
					PaddingRight = UDim.new(0, 5),
					PaddingTop = UDim.new(0, 5),
				}),
				newInstance("UIListLayout", {
					Padding = UDim.new(0, 0),
					SortOrder = Enum.SortOrder.LayoutOrder,
					FillDirection = Enum.FillDirection.Horizontal,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
				}),
				newInstance("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				newInstance("TextBox", {
					LayoutOrder = 1,
					AnchorPoint = Vector2.new(0, 0.5),
					BackgroundTransparency = 1,
					TextTruncate = Enum.TextTruncate.AtEnd,
					Size = UDim2.new(1, -18, 1, 0),
					Font = Enum.Font.GothamBold,
					PlaceholderText = getIndex(config, "Title") or "DropDown",
					PlaceholderColor3 = theme.LightContrast,
					Text = "",
					TextColor3 = theme.TextColor,
					TextSize = 12,
					TextXAlignment = Enum.TextXAlignment.Left,
				}),
				newInstance("Frame", {
					LayoutOrder = 2,
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 18, 0, 18),
				}, {
					newInstance("ImageButton", {
						LayoutOrder = 2,
						BackgroundTransparency = 1,
						Size = UDim2.new(1, 0, 1, 0),
						Image = "rbxassetid://5012539403",
						ImageColor3 = theme.TextColor,
					}),
				}),
			}),
			newInstance("ImageLabel", {
				Name = "List",
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 1, -34),
				ZIndex = 2,
				Image = "rbxassetid://5028857472",
				ImageColor3 = theme.Background,
				ImageTransparency = theme.Transparency,
				ScaleType = Enum.ScaleType.Slice,
				SliceCenter = Rect.new(2, 2, 298, 298),
			}, {
				newInstance("ScrollingFrame", {
					Active = true,
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					Position = UDim2.new(0, 4, 0, 4),
					Size = UDim2.new(1, -8, 1, -8),
					CanvasPosition = Vector2.new(0, 28),
					CanvasSize = UDim2.new(0, 0, 0, 120),
					ZIndex = 2,
					ScrollBarThickness = 3,
					ScrollBarImageColor3 = theme.TextColor,
				}, {
					newInstance("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 4),
					}),
				}),
			}),
		})

		table.insert(self.modules, dropdown)
		--self:Resize()

		local search = dropdown.Frame
		local focused

		local list = getIndex(config, "List") or {}
		local multiList = {}

		search.Frame.ImageButton.MouseButton1Click:Connect(function()
			if search.Frame.ImageButton.Rotation == 0 then
				-- BetterTween(search.Frame.ImageButton, {Rotation = 180}, 0.3)
				self:updateDropdown(
					dropdown,
					{
						Multi = false,
						Default = getIndex(config, "Default"),
						List = list,
						CallBack = getIndex(config, "CallBack"),
						MultiList = multiList,
					}
				)
			else
				-- BetterTween(search.Frame.ImageButton, {Rotation = 0}, 0.3)
				self:updateDropdown(
					dropdown,
					{
						Multi = false,
						Default = getIndex(config, "Default"),
						CallBack = getIndex(config, "CallBack"),
						MultiList = multiList,
					}
				)
			end
		end)

		search.TextBox.Focused:Connect(function()
			if search.Frame.ImageButton.Rotation == 0 then
				BetterTween(search.Frame.ImageButton, { Rotation = 180 }, 0.3)
				self:updateDropdown(
					dropdown,
					{
						Multi = false,
						Default = getIndex(config, "Default"),
						List = list,
						CallBack = getIndex(config, "CallBack"),
						MultiList = multiList,
					}
				)
			end

			focused = true
		end)

		search.TextBox.FocusLost:Connect(function()
			focused = false
		end)

		search.TextBox:GetPropertyChangedSignal("Text"):Connect(function()
			if focused then
				local list = utility:Sort(search.TextBox.Text, list)
				list = #list ~= 0 and list

				self:updateDropdown(
					dropdown,
					{
						Multi = false,
						Default = getIndex(config, "Default"),
						List = list,
						CallBack = getIndex(config, "CallBack"),
						MultiList = multiList,
					}
				)
			end
		end)

		dropdown:GetPropertyChangedSignal("Size"):Connect(function()
			self:Resize()
			self.page:Resize()
		end)

		return dropdown
	end
	function section:addKeybind(config)
		config = config or {}
		local keybind = newInstance("ImageButton", {
			Name = "Keybind_Element",
			Parent = self.container,
			BackgroundColor3 = theme.Background,
			Size = UDim2.new(1, 0, 0, 30),
		}, {
			newInstance("UICorner", {
				CornerRadius = UDim.new(0, 5),
			}),
			newInstance("TextLabel", {
				Name = "Title",
				AnchorPoint = Vector2.new(0, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 10, 0.5, 1),
				Size = UDim2.new(1, 0, 1, 0),
				ZIndex = 3,
				Font = Enum.Font.GothamBold,
				Text = getIndex(config, "Title") or "KeyBind",
				TextColor3 = theme.TextColor,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			}),
			newInstance("ImageLabel", {
				Name = "Button",
				BackgroundColor3 = theme.DarkContrast,
				Position = UDim2.new(1, -110, 0.5, -8),
				Size = UDim2.new(0, 100, 0, 16),
			}, {
				newInstance("UICorner", {
					CornerRadius = UDim.new(0, 5),
				}),
				newInstance("TextLabel", {
					Name = "Text",
					BackgroundTransparency = 1,
					ClipsDescendants = true,
					Size = UDim2.new(1, 0, 1, 0),
					ZIndex = 3,
					Font = Enum.Font.GothamSemibold,
					Text = getIndex(config, "default") and getIndex(config, "default").Name or "None",
					TextColor3 = theme.TextColor,
					TextSize = 11,
				}),
			}),
		})

		table.insert(self.modules, keybind)
		--self:Resize()

		local text = keybind.Button.Text
		local button = keybind.Button

		local animate = function()
			if button.ImageTransparency == theme.Transparency then
				utility:Pop(button, 10)
			end
		end

		self.binds[keybind] = {
			callback = function()
				animate()

				if getIndex(config, "callback") then
					getIndex(config, "callback")(function(...)
						self:updateKeybind(keybind, { ... })
					end)
				end
			end,
		}

		if getIndex(config, "default") and getIndex(config, "callback") then
			self:updateKeybind(keybind, { key = getIndex(config, "default") })
		end

		keybind.MouseButton1Click:Connect(function()
			animate()

			if self.binds[keybind].connection then -- unbind
				return self:updateKeybind(keybind)
			end

			if text.Text == "None" then -- new bind
				text.Text = "..."

				local key = KeyPressed()

				self:updateKeybind(keybind, { key = key.KeyCode })
				animate()

				if getIndex(config, "changedCallback") then
					getIndex(config, "changedCallback")(key, function(...)
						self:updateKeybind(keybind, { ... })
					end)
				end
			end
		end)

		return keybind
	end
	--#endregion
	--#region Update Modules
	function section:updateButton(button, config)
		config = config or {}
		button = self:getModule(button)

		button.Title.Text = getIndex(config, "Title")
	end
	function section:updateLabel(label, config)
		config = config or {}
		label = self:getModule(label)

		local sizeY = 0
		for i = 1, getIndex(config, "Text"):len() do
			label.Text = getIndex(config, "Text"):sub(1, i)
			label.Size = UDim2.new(1, 0, 0, label.TextBounds.Y)
		end
	end
	function section:updateSlider(slider, config)
		config = config or {}
		slider = self:getModule(slider)

		if getIndex(config, "Title") then
			for i = 1, getIndex(config, "Title"):len() do
				slider.Title.Text = getIndex(config, "Title"):sub(1, i)
				slider.Title.Size = UDim2.new(0, slider.Title.TextBounds.X, 0, slider.Title.TextBounds.Y)
			end
			if slider:FindFirstChild("Slider") then
				slider:FindFirstChild("Slider").Size = UDim2.new(
					1,
					-slider.Title.AbsoluteSize.X - 20,
					0,
					slider.Title.AbsoluteSize.Y
				)
			end
		end

		local bar = slider:FindFirstChild("Frame") and slider.Frame:FindFirstChild("Slider").Bar
			or slider:FindFirstChild("Slider") and slider:FindFirstChild("Slider").Bar

		local percent = (mouse.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X

		if getIndex(config, "Value") then -- support negative ranges
			percent = (getIndex(config, "Value") - getIndex(config, "Min"))
				/ (getIndex(config, "Max") - getIndex(config, "Min"))
		end

		percent = math.clamp(percent, 0, 1)
		config.Value = getIndex(config, "Value")
			or math.floor(getIndex(config, "Min") + (getIndex(config, "Max") - getIndex(config, "Min")) * percent)

		if slider:FindFirstChild("Frame") then
			slider:FindFirstChild("Frame").TextBox.Text = getIndex(config, "Value")
		end
		BetterTween(bar.Fill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.1)

		return getIndex(config, "Value")
	end
	function section:updateToggle(toggle, config)
		config = config or {}
		toggle = self:getModule(toggle)

		local position = {
			In = UDim2.new(0, 0, 0, 0),
			Out = UDim2.new(1, -15, 0, 0),
		}

		local Button = toggle.Frame.Button
		config.Default = getIndex(config, "Default") and "Out" or "In"

		if getIndex(config, "Title") then
			toggle.Title.Text = getIndex(config, "Title")
		end

		if getIndex(config, "Default") == "In" then
			BetterTween(Button, { Position = position[getIndex(config, "Default")] }, 0.2)
		end
		BetterTween(Button, { Size = UDim2.new(0, 32, 0, 16) }, 0.2)
		wait(0.1)
		BetterTween(Button, { Size = UDim2.new(0, 16, 0, 16) }, 0.1)
		BetterTween(Button, { Position = position[getIndex(config, "Default")] }, 0.2)
	end
	function section:updateCheckbox(checkbox, config)
		config = config or {}
		checkbox = self:getModule(checkbox)

		if getIndex(config, "Title") then
			checkbox.Title.Text = getIndex(config, "Title")
		end

		wait(0.2)
		checkbox.ImageButton.Frame.Visible = not getIndex(config, "Default")
		if getIndex(config, "Default") then
			BetterTween(checkbox.ImageButton.ImageLabel, { ImageTransparency = 0 }, 0.3)
		else
			BetterTween(checkbox.ImageButton.ImageLabel, { ImageTransparency = 1 }, 0.2)
		end
	end
	function section:updateDropdown(dropdown, config)
		config = config or {}
		dropdown = self:getModule(dropdown)

		if getIndex(config, "Title") then
			dropdown.Frame.TextBox.Text = getIndex(config, "Title")
		end

		local entries = 0

		-- PopAnim(dropdown.Frame, 10)

		for i, button in pairs(dropdown.List.ScrollingFrame:GetChildren()) do
			if button:IsA("ImageButton") then
				button:Destroy()
			end
		end

		for i, value in pairs(getIndex(config, "List") or {}) do
			if not table.find(getIndex(config, "MultiList"), value) then
				local button = newInstance("ImageButton", {
					Parent = dropdown.List.ScrollingFrame,
					BorderSizePixel = 0,
					Size = UDim2.new(1, 0, 0, 30),
					BackgroundColor3 = theme.DarkContrast,
					ZIndex = 2,
					AutoButtonColor = false,
				}, {
					newInstance("UICorner", {
						CornerRadius = UDim.new(0, 5),
					}),
					newInstance("TextLabel", {
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 10, 0, 0),
						Size = UDim2.new(1, -10, 1, 0),
						Font = Enum.Font.GothamSemibold,
						Text = value,
						TextColor3 = theme.TextColor,
						TextSize = 12,
						ZIndex = 2,
						TextXAlignment = Enum.TextXAlignment.Left,
					}),
				})

				button.MouseButton1Click:Connect(function()
					if getIndex(config, "CallBack") then
						getIndex(config, "CallBack")(value, function(...)
							self:updateDropdown(dropdown, ...)
						end)
					end
					if getIndex(config, "Multi") then
						if table.find(getIndex(config, "MultiList"), value) then
							table.remove(
								getIndex(config, "MultiList"),
								table.find(getIndex(config, "MultiList"), value)
							)

							self:updateDropdown(
								dropdown,
								{
									Title = getIndex(config, "Default")
											and getIndex(config, "Default") .. " | " .. table.concat(
												getIndex(config, "MultiList"),
												", "
											)
										or table.concat(getIndex(config, "MultiList"), ", "),
									Multi = getIndex(config, "Multi"),
									Default = getIndex(config, "Default"),
									CallBack = getIndex(config, "CallBack"),
								}
							)
						else
							table.insert(getIndex(config, "MultiList"), value)

							self:updateDropdown(
								dropdown,
								{
									Title = getIndex(config, "Default")
											and getIndex(config, "Default") .. " | " .. table.concat(
												getIndex(config, "MultiList"),
												", "
											)
										or table.concat(getIndex(config, "MultiList"), ", "),
									Multi = getIndex(config, "Multi"),
									Default = getIndex(config, "Default"),
									CallBack = getIndex(config, "CallBack"),
								}
							)
						end
					else
						table.clear(getIndex(config, "MultiList"))
						table.insert(getIndex(config, "MultiList"), value)
						self:updateDropdown(
							dropdown,
							{
								Title = getIndex(config, "Default") and getIndex(config, "Default") .. " | " .. value
									or value,
								Multi = getIndex(config, "Multi"),
								Default = getIndex(config, "Default"),
								CallBack = getIndex(config, "CallBack"),
							}
						)
					end
				end)

				entries = entries + 1
			end
		end

		local frame = dropdown.List.ScrollingFrame

		BetterTween(
			dropdown,
			{ Size = UDim2.new(1, 0, 0, (entries == 0 and 30) or math.clamp(entries, 0, 3) * 34 + 38) },
			0.3
		)
		BetterTween(dropdown.Frame.Frame.ImageButton, { Rotation = getIndex(config, "List") and 180 or 0 }, 0.3)

		if entries > 3 then
			for i, button in pairs(dropdown.List.ScrollingFrame:GetChildren()) do
				if button:IsA("ImageButton") then
					button.Size = UDim2.new(1, -6, 0, 30)
				end
			end

			frame.CanvasSize = UDim2.new(0, 0, 0, (entries * 34) - 4)
			frame.ScrollBarImageTransparency = 0
		else
			frame.CanvasSize = UDim2.new(0, 0, 0, 0)
			frame.ScrollBarImageTransparency = 1
		end
	end
	function section:updateKeybind(keybind, config)
		config = config or {}
		keybind = self:getModule(keybind)

		local text = keybind.Button.Text
		local bind = self.binds[keybind]

		if getIndex(config, "title") then
			keybind.Title.Text = getIndex(config, "title")
		end

		if bind.connection then
			bind.connection = bind.connection:UnBind()
		end

		if getIndex(config, "key") then
			self.binds[keybind].connection = BindToKey(getIndex(config, "key"), bind.callback)
			text.Text = getIndex(config, "key").Name
		else
			text.Text = "None"
		end
	end
	--#endregion
end

return library
