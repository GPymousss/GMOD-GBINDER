Le script permet de configurer les touches pour diverses actions de jeu, pour ce faire il suffit de relier avec un "PlayerButtonDown" exemple :

hook.Add("PlayerButtonDown", "Exemple", function(ply, button)
	if not IsValid(LocalPlayer()) then return end
	if not LocalPlayer():Alive() then return end

	local calcViewKeyCode = GetConVar("g_key_calcview"):GetInt()

	if calcViewKeyCode == button then

	end
end)

IMPORTANT : Ce script nécessite la bibliothèque GLIBS de GPymousss pour fonctionner correctement.
Sans cette bibliothèque, le script ne fonctionnera pas.
Lien vers la bibliothèque : https://github.com/GPymousss/GMOD-GLIBS

Ce script est libre d'utilisation et de modification. Vous pouvez l'adapter à vos besoins, l'intégrer dans vos projets.
