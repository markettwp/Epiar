/*
 * Filename      : image.h
 * Author(s)     : Chris Thielen (chris@luethy.net)
 * Date Created  : Unknown (2006?)
 * Last Modified : Saturday, January 5, 2008
 * Purpose       : 
 * Notes         :
 */

#ifndef __h_image__
#define __h_image__

#include "includes.h"

class Image {
	public:
		Image();
		Image( string filename );
		Image( char *filename , char *maskname);
		~Image();

		bool _Load( SDL_Surface *s );
		bool Load( string filename );
		bool o_Load( char *filename , char *maskname );
		bool Load( FILE *fp, int size );
		bool Load( unsigned char *buf, int bufSize );
		
		void Draw( int x, int y );
		void DrawAbsolute( int x, int y );
		void DrawAbsoluteTiled( int x, int y, int w, int h );
		// takes ang in radians
		void Draw( int x, int y, float ang );
		void LoadAndDraw(int x, int y, float ang, char *filename);

		int GetWidth( void );
		int GetHeight( void );
		int GetHalfWidth( void ) { return w / 2; };
		int GetHalfHeight( void ) { return h / 2; };

		bool GetMasking(){return masking;}
		void SetMasking(bool m){masking = m;}
		
		void SetScaling( int nw, int nh );

	private:
		SDL_Surface *ExpandCanvas( SDL_Surface *s, int w, int h );
		
		GLuint image;
		GLuint mask;
		bool masking;
		int w, h; // w/h of surface. may be bigger than original file if file's dimensions were not a power of 2, >= 2
		int vw, vh; // virtual w/h. this only differs if the image was expanded (w,h must be true w/h for ogl, but game often needs the supposed width and height, before expansion, which is the virtual width/height)
		int sw, sh; // scale width/height, if any
		float tw, th; // texture scaling (u/v), used by ExpandCanvas
};

#endif // __h_image__