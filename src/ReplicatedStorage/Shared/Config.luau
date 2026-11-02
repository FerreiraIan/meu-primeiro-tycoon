-- ModuleScript: configurações gerais do jogo (sem lógica, só números e nomes)
return {
	GameName = "BOOKS OF CHAOS",
	Version = "0.1.0",

	-- Salvamento
	DataStoreName = "BooksOfChaos_PlayerData_v1",
	DataVersion = 1,
	AutoSaveSeconds = 60,

	-- Progressão
	MaxLevel = 100,
	StarterBookId = "flames",

	-- MODO DE TESTE (protótipo): dá XP e moedas de graça a cada 10 segundos
	-- para você ver o HUD e o salvamento funcionando. Mude para false depois.
	TestMode = true,
	TestIntervalSeconds = 10,
	TestXP = 25,
	TestCoins = 10,
}
