-- Use this script for code directly to the Players

PLAYER = Epiar.player()
player_credits = 1000

playerCommands = {
	-- Each command should be a table
	-- { KEY, TITLE, SCRIPT }
	{'up', "Accelerate", "PLAYER:Accelerate()",KEYPRESSED},
	{'left', "Turn Left", "PLAYER:Rotate(30)",KEYPRESSED},
	{'right', "Turn Right", "PLAYER:Rotate(-30)",KEYPRESSED},
	{'down', "Reverse", "PLAYER:Rotate(PLAYER:directionTowards(PLAYER:GetMomentumAngle() + 180 ))",KEYPRESSED},
	{'c', "Center", "PLAYER:Rotate(PLAYER:directionTowards(0,0))",KEYPRESSED},
	{'rshift', "Change Weapon 1", "PLAYER:ChangeWeapon()",KEYTYPED},
	{'lshift', "Change Weapon 2", "PLAYER:ChangeWeapon()",KEYTYPED},
	{'tab', "Target Ship", "targetClosestShip()",KEYTYPED},
	{'L', "Land on Planet", "attemptLanding()",KEYTYPED},
	{'w', "Focus on the Target", "Epiar.focusCamera(HUD.getTarget())",KEYTYPED},
	{'q', "Focus on the Player", "Epiar.focusCamera(PLAYER:GetID())",KEYTYPED},
	{'space', "Fire", "PLAYER:Fire()",KEYPRESSED},
}
registerCommands(playerCommands)

function targetClosestShip()
	x,y = PLAYER:GetPosition()
	nearby = Epiar.ships(x,y,4096)
	if #nearby==0 then return end
	
	nextTarget = 1
	currentTarget = HUD.getTarget()
	for s =1,#nearby-1 do
		if nearby[s]:GetID() == currentTarget then
			nextTarget = s+1
		end
	end
	
	HUD.newAlert("Targeting "..nearby[nextTarget]:GetModelName().." #"..nearby[nextTarget]:GetID())
	HUD.setTarget(nearby[nextTarget]:GetID()) -- First ID in the list
	TargetName:setStatus(nearby[nextTarget]:GetModelName() )
end

function attemptLanding()
	if landingWin ~= nil then return end
	x,y = PLAYER:GetPosition()
	planet = Epiar.nearestPlanet(PLAYER,4096)
	px,py = planet:GetPosition()
	distance = distfrom( px,py, x,y)
	message=""
	if HUD.getTarget() ~= planet:GetID() then -- Add this text before the first message.
		message = string.format("This is %s Landing Control. ",planet:GetName())
	end
	
	-- Check if the ship is close enough and moving slowly enough to land on the planet.
	HUD.setTarget(planet:GetID())
	TargetName:setStatus(planet:GetName() )
	-- TODO make this distance check based off of the planet size.
	if distance > 200 then
		if message~="" then
			message=message.."Begin your approach."
		else
			message="Continue your approach."
		end
		HUD.newAlert(message)
	else
		velocity = PLAYER:GetMomentumSpeed()
		if velocity > 2 then
			HUD.newAlert(message.."Please slow your approach.")
		else
			HUD.newAlert(string.format("Welcome to %s.",planet:GetName()))
			landOnPlanet( planet:GetID() )
		end
	end
end

function landOnPlanet(id)
	-- Create the Planet Landing Screen
	if landingWin ~= nil then return end
	Epiar.pause()
	planet = Epiar.getSprite(id)
	
	landingWin = UI.newWindow( 200,100,400,300, string.format("%s Landing Screen",planet:GetName()))
	landingWin:add(UI.newButton( 40,40,100,30,"Shipyard",string.format("shipyard(%d)",id) ))
	landingWin:add(UI.newButton( 40,80,100,30,"Armory",string.format("armory(%d)",id) ))
	landingWin:add(UI.newButton( 40,120,100,30,"Repair","PLAYER:Repair(10000)" ))
	landingWin:add(UI.newButton( 290,260,100,30,string.format("Leave %s ",planet:GetName()), "Epiar.unpause();landingWin:close();landingWin=nil" ))
end

-- Register the player functions
function radarZoomKeys()
	for k =1,9 do
		kn = string.byte(k)
		ks = string.format("%d",1000*math.pow(2,k-1))
		Epiar.RegisterKey(kn, KEYPRESSED, "HUD.setVisibity("..ks..")")
	end
end
registerInit(radarZoomKeys)

function coordinateToQuadrant(x,y)
	qsize = 4096
	function c2q(z)
		return math.floor( (z+qsize)/(2*qsize))
	end
	return c2q(x),c2q(y)
end

function createHUD()
	-- Location Status Bars
	x,y = PLAYER:GetPosition()
	qx,qy = coordinateToQuadrant(x,y)
	pos = HUD.newStatus("Coordinate:",130,1,string.format("( %d , %d )",x,y))
	quad = HUD.newStatus("Quadrant:",130,1,string.format("( %d , %d )",qx,qy))
	creditBar = HUD.newStatus("Credits:",130,1,string.format("$%d",player_credits))

	-- Weapon and Armor Status Bars
	myhull = HUD.newStatus("HULL:",100,0,1.0)
	myweapons = {}
	weaponsAndAmmo = PLAYER:GetWeapons()
	for weapon,ammo in pairs(weaponsAndAmmo) do
		if 0==ammo then ammo="---" end
		myweapons[weapon] = HUD.newStatus(weapon..":",130,0,"[ ".. ammo .." ]")
	end

	-- DEBUG Bars
	TargetName = HUD.newStatus("Target:",130,1,"")
	TargetHULL = HUD.newStatus("Target:",130,1,0)
end
registerInit(createHUD)

updateHUD = function ()
	if PLAYER:GetHull() == 0 then return end
	-- Update Positions
	x,y = PLAYER:GetPosition()
	qx,qy = coordinateToQuadrant(x,y)
	pos:setStatus(string.format("( %d , %d )",x,y))
	quad:setStatus(string.format("( %d , %d )",qx,qy))
	creditBar:setStatus(string.format("$%d",player_credits))

	-- Update Weapons and Armor
	myhull:setStatus(PLAYER:GetHull())
	weaponsAndAmmo = PLAYER:GetWeapons()
	cur_weapon = PLAYER:GetCurrentWeapon()
	for weapon,ammo in pairs(weaponsAndAmmo) do
		if cur_weapon == weapon then star=" ARMED" else star="" end
		if 0==ammo then ammo="---" end
		myweapons[weapon]:setStatus("[ ".. ammo .." ]".. star)
	end
	if SHIPS[HUD.getTarget()]~=nil then
		TargetHULL:setStatus( SHIPS[HUD.getTarget()]:GetHull() )
	end
end
registerPostStep(updateHUD)

