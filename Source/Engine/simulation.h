/**\filename		simulation.h
 * \author			Chris Thielen (chris@epiar.net)
 * \date			Created: July 2006
 * \date			Modified: Tuesday, June 23, 2009
 * \brief			Contains the main game loop
 * \details
 */

#ifndef __H_SIMULATION__
#define __H_SIMULATION__

#include "Engine/commodities.h"
#include "Engine/alliances.h"
#include "Engine/engines.h"
#include "Engine/models.h"
#include "Sprites/planets.h"
#include "Sprites/gate.h"
#include "Engine/weapons.h"
#include "Engine/technologies.h"
#include "Sprites/player.h"
#include "Audio/music.h"
#include "Engine/camera.h"
#include "Input/input.h"
#include "Engine/console.h"

class Simulation : public XMLFile {
	public:
		Simulation();

		bool New( string _folderpath );
		bool Load( string _folderpath );

		bool SetupToRun();
		bool SetupToEdit();

		bool Run();
		bool Edit();

		void CreateDefaultPlayer(string name);
		void LoadPlayer(string name);

		void LuaRegisters(lua_State *L);

		void HandleInput();

		void Save();
		void pause();
		void unpause();
		bool isPaused() {return paused;}
		bool isLoaded() {return loaded;}

		SpriteManager *GetSpriteManager() { return sprites; }
		Commodities *GetCommodities() { return commodities; }
		Planets *GetPlanets() { return planets; }
		Gates *GetGates() { return gates; }
		Engines *GetEngines() { return engines; }
		Models *GetModels() { return models; }
		Weapons *GetWeapons() { return weapons; }
		Alliances *GetAlliances() { return alliances; }
		Technologies *GetTechnologies() { return technologies; }
		Outfits *GetOutfits() { return outfits; }
		Players *GetPlayers() { return players; }
		Camera *GetCamera() { return camera; }
		Input *GetInput() { return &inputs; }
		Player *GetPlayer();

		string GetName() { return name; }
		string GetDescription() { return description; }

		void SetName( string _name ) { name = _name; }
		void SetDescription( string _desc ) { description = _desc; }

		void SetQuit( bool val ) { quit = val; }

	private:
		bool Parse( void );
		void CreateNavMap( void );

		// Pointers to Singletons
		///< TODO: These should all be rewritten to not be singletons
		lua_State *L;
		SpriteManager *sprites;

		Commodities *commodities;
		Planets *planets;
		Gates *gates;
		Engines *engines;
		Models *models;
		Weapons *weapons;
		Alliances *alliances;
		Technologies *technologies;
		Outfits *outfits;
		Players *players;
		Player *player;
		Camera *camera;

		// Simulation specific variables
		Song* bgmusic;
		Input inputs;
		Console *console;

		string name;
		string description;
		string folderpath;
		float currentFPS;
		bool paused;
		bool loaded;
		bool quit;
};

#endif // __H_SIMULATION__
