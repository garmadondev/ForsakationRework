local in_talking_server = {}

local rp = game:GetService("ReplicatedStorage")
local sss = game:GetService("ServerScriptService")
local rems = rp:WaitForChild("rems")

local logic = require(sss.Modules:WaitForChild("Logic Main"))
local documents_module = require(sss.Modules:WaitForChild("DocumentModule"))
local teamLibrary = require(rp.Modules.TeamLibrary)
local questHandler = require(game.ServerStorage.Modules.QuestHandler)

local function endtalk(player)
	in_talking_server[player.UserId] = nil	
	rems.events.client.ClientSynchronization:FireClient(player, 12, nil)
end

local chooses = {
	["kevinshop"] = function(player)
		local cache = questHandler.cache_quest_player[player.UserId]
		local interacts = {
			{
				["Context"] = "[магазин...]", 
				["FunctionTalk"] = function(plr) 
					endtalk(plr)
					shared.sync_player_products(plr, 3)
				end
			},

			{
				["Context"] = "пока!",
				["IndexQuote"] = "endtalk",
			}
		}
		
		if not cache then
			table.insert(interacts,{
				["Context"] = "есть работенка?",
				["FunctionTalk"] = function()
					local interacts = {}
					local cache = questHandler.cache_quest_player[player.UserId]

					if cache then
						return {
							["Messages"] = {
								"Come back, when you won't have a job!",
							},

							["Interactions"] = {
								{
									["Context"] = "у кого мама мобилизована??!?!? а ну сюда иди!!!",
									["IndexQuote"] = "endtalk",
								}	
							}
						}
					end

					if not questHandler.isQuestCompleted(player, "kevinquest1") and not questHandler.isQuestCompleted(player, "kevinquest1no") then
						table.insert(interacts, {
							["Context"] = "задание Кевина #1",
							["FunctionTalk"] = function()
								return {
									["Messages"] = {
										"Короче Меченый, или как тебя там. Рядом с базой СОП Д. Л. открылся новый магазин.",
										"Мне конкуренция не нужна, пригрози отморозку кто там управляет, если ослушается прикончи его, understand?",
									},

									["Interactions"] = {
										{
											["Context"] = "сурово, ну в любом случае, \"Суровость\" - моё второе имя!! Я берусь",
											["FunctionTalk"] = function()
												endtalk(player)
												questHandler.update_quest(player, "kevinquest1")
											end,
										},

										{
											["Context"] = "да ну тебя, я с Пендосами не веду дела!!",
											["IndexQuote"] = "endtalk",
										}
									}
								}
							end,
						})
					elseif not questHandler.isQuestCompleted(player, "kevinquest2") then
						table.insert(interacts, {
							["Context"] = "задание Кевина #2",
							["FunctionTalk"] = function()
								return {
									["Messages"] = {
										"короче, тут рядом с Дуркой иногда шляется один сталкер-новичок. Он мне очень не нравится.",
										"Be a friend убей его и принеси его ПДА.",
									},
									
									["Interactions"] = {
										{
											["Context"] = "я готов!",
											["FunctionTalk"] = function()
												endtalk(player)
												questHandler.update_quest(player, "kevinquest2")
											end
										},
										
										{
											["Context"] = "-уйти, но не в слезах-",
											["IndexQuote"] = "endtalk",
										}
									}
								}
							end,
						})
					end
					
					table.insert(interacts, {
						["Context"] = "-уйти-",
						["IndexQuote"] = "endtalk",
					})

					return {
						["Interactions"] = interacts
					}
				end,
			})
		else
			local val = cache["check"](player)
			
			if val and cache["index"] == "kevinquest1" then
				return {
					["Messages"] = {
						"Well, всё сделал?",
					},

					["Interactions"] = {
						{
							["Context"] = "не понял что первое сказал, ну кароче вот его ПДА",
							["FunctionTalk"] = function(plr)
								questHandler.complete_quest(player)
								return {
									["Messages"] = {
										"Leshiy... Hmmm, so familiar nickname. А кстати держи you deserve this.",
										{["context"] = "Получены деньги", ["icon"] = "rbxassetid://12248904681", ["value"] = 1000},
										{["context"] = "Отобран предмет", ["icon"] = "rbxassetid://12248906744", ["value"] = "ПДА \"Лешего\""},
									},

									["Interactions"] = {
										{
											["Context"] = "спасибо, *шепотом* правда нихрена не понял что он сказал...",
											["IndexQuote"] = "kevinshop",
										}
									}
								}
							end,
						}
					},
				}
			elseif val and cache["index"] == "kevinquest2" then
				return {
					["Messages"] = {
						"Greetings! Убрал его?",
					},
					
					["Interactions"] = {
						{
							["Context"] = "да, теперь он вас не побеспокоит, вот его ПДА",
							["FunctionTalk"] = function()
								questHandler.complete_quest(player)
								
								return {
									["Messages"] = {
										{["context"] = "Отобран предмет:", ["icon"] = "rbxassetid://12248906744", ["value"] = "ПДА \"Сталкера\""},
										{["context"] = "Получены деньги:", ["icon"] = "rbxassetid://12248904681", ["value"] = 1500},
										"Сталкер... Хмм, ладно свободен.",
									},
									
									["Interactions"] = {
										{
											["Context"] = "[далее...]",
											["IndexQuote"] = "kevinshop",
										}
									}
								}
							end,
						}
					}
				}
			end
			
			if cache["index"] == "kevinquest1no" and not val then
				table.insert(interacts, {
					["Context"] = "я по поводу работы...",
					["FunctionTalk"] = function()
						return {
							["Messages"] = {
								"Oh, finally! Well, его больше нету озле ларька?",
							},
							
							["Interactions"] = {
								{
									["Context"] = "я отказываюсь сотрудничать с вами.",
									["FunctionTalk"] = function()
										return {
											["Messages"] = {
												"What?!! ZIG H! Что за, ну ты черт конечно! Если не ты, то кто-нибудь другой разберется! Now, go away!"
											},
											
											["Interactions"] = {
												{
													["Context"] = "*слезы*",
													["FunctionTalk"] = function()
														endtalk(player)
														questHandler.update_quest(player, "kevinquest1no", {
															["check"] = function(player)
																return true, "Вы отказались от задания, идите обратно к тому продавцу"
															end
														})
													end,
												}
											}
										}
									end,
								},
							},
						}
					end,
				})
			end
		end
		
		return {
			["Talker"] = "Кевин",
			
			["Messages"] = {
				"Greetings! Que faites-vous bringt, сюда?",
			},
			
			["Interactions"] = interacts
		}
	end,
	
	["endtalk"] = endtalk
}

return {
	["synchronization"] = function(player, quote, new_messages, ...)
		if quote then
			local GetQuote = (typeof(quote) == "string" and chooses[quote]) or quote

			if GetQuote and typeof(GetQuote) == "function" then
				local callbackValue = GetQuote(player, ...)

				if callbackValue and type(callbackValue) == "table" then			
					in_talking_server[player.UserId] = callbackValue.Interactions

					if new_messages then
						if not callbackValue["Messages"] then
							callbackValue["Messages"] = {}
						end

						local newListMessages = {}

						for i=1, #new_messages do
							table.insert(newListMessages, new_messages[i])
						end

						for i=1, #callbackValue.Messages do
							table.insert(newListMessages, callbackValue.Messages[i])
						end

						callbackValue.Messages = newListMessages
					end
					
					rems.events.client.ClientSynchronization:FireClient(player, 12, "sync", callbackValue)
				end
			end
		end
	end,
	["server_talk"] = in_talking_server,
	["quotes"] = chooses,
}