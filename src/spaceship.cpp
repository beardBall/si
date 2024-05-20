#include "spaceship.hpp"
#include "raylib.h"


Spaceship::Spaceship()
{
        image = LoadTexture(ASSETS_PATH"Graphics/spaceship.png");
        position.x  = GetScreenWidth() / 2 - image.width/2;
        position.y  = GetScreenHeight() - image.height;
        lastFireTime = 0;
        laserSound = LoadSound(ASSETS_PATH"Sounds/laser.ogg");
        SetSoundVolume(laserSound,0.1f);
}

Spaceship::~Spaceship()
{
    UnloadTexture(image);
}

void Spaceship::draw()
{
    DrawTextureV(image,position,WHITE);
    // laser.draw();
}

void Spaceship::update()
{
        // laser.update();
}

void Spaceship::MoveLeft()
{
    position.x -=7;
    if(position.x < 0)
        position.x = 0;
}

void Spaceship::MoveRight()
{
    position.x +=7;
    if(position.x > (GetScreenWidth() - image.width))
        position.x = GetScreenWidth() - image.width;
}

void Spaceship::FireLaser()
{
    
    if(GetTime() - lastFireTime >= 0.35){
        lasers.push_back(Laser(
            {position.x + image.width/2, position.y+1}
            ,-6));
            lastFireTime = GetTime();
            PlaySound(laserSound);
        }
}
