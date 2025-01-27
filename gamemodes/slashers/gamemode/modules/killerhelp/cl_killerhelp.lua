-- Utopia Games - Slashers
--
-- @Author: Garrus2142
-- @Date:   2017-07-25 16:15:50
-- @Last Modified by:   Valafi
-- @Last Modified time: 2021-03-21 03:27:00

local GM = GM or GAMEMODE
local exit_police

local ICON_EXITHELP = Material("icons/icon_exit.png")


sound.Add({
	name = "killerhelp.heartbeat",
	channel = CHAN_STATIC,
	sound = "slashers/effects/heartbeat_loop.wav"
})

local function AddExit()
	local pos, endtime
	pos = net.ReadVector()
	if LocalPlayer().ClassID ~= CLASS_SURV_POPULAR then return end
	if not LocalPlayer():Alive() then return end

	exit_police = pos
end
net.Receive("sls_popularhelp_AddExit", AddExit)

local function HUDPaintBackground()
	local curtime = CurTime()

	-- Popularhelp
	if  LocalPlayer():Team() ~= TEAM_KILLER and exit_police then
		if not GM.ROUND.Active then
			exit_police = nil
		else
			local pos1 = exit_police:ToScreen()
			surface.SetDrawColor(Color(255, 255, 255))
			surface.SetMaterial(ICON_EXITHELP)
			surface.DrawTexturedRect(pos1.x - 64, pos1.y - 64, 128, 128)
		end
	end
end
hook.Add("HUDPaintBackground", "sls_killerhelp_HUDPaintBackground", HUDPaintBackground)


local function Think()
	if not GM.ROUND.Active or not GM.ROUND.Survivors or LocalPlayer():Team() ~= TEAM_KILLER then return end
	for _, v in ipairs(GM.ROUND.Survivors) do
		if v:GetNWBool("killerhelp_camp") and not v.kh_play then
			v:EmitSound("killerhelp.heartbeat")
			v.kh_play = true
		elseif not v:GetNWBool("killerhelp_camp") and v.kh_play then
			v:StopSound("killerhelp.heartbeat")
			v.kh_play = false
		end
	end
end
hook.Add("Think", "sls_killerhelp_Think", Think)

local function Reset()
	doors = {}
	steps = {}
	victimPos = nil

	for _, v in ipairs(player.GetAll()) do
		if v.kh_play then
			v:StopSound("killerhelp.heartbeat")
			v.kh_play = false
		end
	end
end
hook.Add("sls_round_PreStart", "sls_killerhelp_PreStart", Reset)
hook.Add("sls_round_End", "sls_killerhelp_End", Reset)
