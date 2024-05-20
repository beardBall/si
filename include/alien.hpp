#pragma once
#include "raylib.h"
#include <iostream>
#include <vector>

class Alien {

    public:
         Alien(Vector2 position, int type);
        Alien();
        ~Alien();

        void draw();
        void update();
        void MoveLeft();
        void MoveRight();
        void FireLaser();

        // std::vector<Laser> lasers;
        // Laser laser;
        // Vector2 position;
        int size;
        bool active;
        bool canShoot;
        Texture2D getImage();
        std::string name;
        Rectangle getRect();
        void die();
        Sound alienDieSound;


       int getType();

    private:
    int type;
    Texture2D alienImage;
    Vector2 position;
    double lastFireTime;
    double lastMoveTime;
    bool lastMoveLeft;




};