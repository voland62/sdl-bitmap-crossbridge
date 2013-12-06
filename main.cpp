#include "SDL.h"
#include <AS3/AS3.h>

SDL_Rect screenRect;

SDL_Surface* hello = NULL;
SDL_Surface* screen = NULL;


void draw()
{

    //Apply image to screen
    SDL_BlitSurface( hello, NULL, screen, NULL );

    //Update Screen
    SDL_Flip( screen );
    //SDL_UpdateRects(screen, 1, &screenRect);    
    
    SDL_Delay(20);

}


int main( int argc, char* args[] )
{
    
    printf("%s\n", "Im on start now" );

    screenRect.x = 0;
    screenRect.y = 0;
    screenRect.w = 640; 
    screenRect.h = 480;


    //Start SDL
    SDL_Init( SDL_INIT_VIDEO);

    //Set up screen
    screen = SDL_SetVideoMode( 640, 480, 32, SDL_SWSURFACE );

    //surface = SDL_SetVideoMode(width, height, 8, SDL_SWSURFACE);

    //Load image
    hello = SDL_LoadBMP( "/hello.bmp" );

    if (hello == NULL)
    {
        printf("load faild: %s\n", SDL_GetError());
    }
    else
    {
        printf("image file has been loaded successfully\n" );
    }

    // drawing bitmap on the screen
    draw();

    // разрыв шаблона
    AS3_GoAsync();


    //Pause
    //SDL_Delay( 5000 );

    //Free the loaded image
    //SDL_FreeSurface( hello );

    //Quit SDL
    //SDL_Quit();

    return 0;
}
