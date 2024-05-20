#pragma once
#include "dash.hpp"
#include <iostream>
// #include "raylib.h"
// #include "globvars.hpp"

Dash::Dash()
{
    active = true;
}

Dash::~Dash(){}

void Dash::draw(){
   DrawText(
    TextFormat("Laser count: %d",lasterCount), 
    10,10,14,
     WHITE);

    //    DrawText(
    // TextFormat("Enemies remaining: %d",globVars::aliensRemaining), 
    // 100,10,14,
    //  WHITE);

}


void Dash::update(){}