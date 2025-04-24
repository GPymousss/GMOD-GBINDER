GPYMOUSSS = GPYMOUSSS or {}

if SERVER then
	AddCSLuaFile("binder/vgui/dbinder.lua")
end

if CLIENT then
	include("binder/vgui/dbinder.lua")
end