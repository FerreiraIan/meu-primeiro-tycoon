-- ModuleScript: catálogo de livros. Só dados! Novos livros = novas linhas aqui.
-- PROTÓTIPO: por enquanto só existe o livro inicial. As habilidades abaixo são
-- apenas dados; o sistema de combate vem na Fase 2.
local Books = {
	flames = {
		Id = "flames",
		Name = "Book of Flames",
		Rarity = "Common",
		Description = "An ancient book that burns with magical fire.",
		Acquisition = "Starter",
		Abilities = {
			{ Id = "fireball", Name = "Fireball", Type = "Projectile", Cooldown = 3, EnergyCost = 10, Damage = 20 },
		},
	},
}

local Module = {}

function Module.Get(bookId)
	return Books[bookId]
end

function Module.Exists(bookId)
	return Books[bookId] ~= nil
end

return Module
