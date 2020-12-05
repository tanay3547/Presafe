# Presafe

## Table of Contents
1. Overview
2. Networking
3. Schema 

## Overview

### Description
Hey Guys! 
Check this amazing app designed to protect you when you go out! Our app will listen to everything that people says around you in the last minute and if we listen more than 10 abusive words that seems to be threatening, we will start a timer and if the timer is not switched off, your phone will automatically call the police. Please keep the app open in places you don't feel safe!

In need of emergency a person cannot physically approach help and in such crucial times we can use voice recoginition over a particular keyword that can activate the app which would locate the person and provide relevant help from 911.


## Networking
We are using no external APIs in our app and only working with frameworks that are embedded in Xcode. Sprint Plan in place using GitHub project management flow.


## Schema
|    Property   |                Type                |                                       Description                                      | 
| ------------- | ---------------------------------- | -------------------------------------------------------------------------------------- | 
| currWords     | An Array of Strings                | Words that seems to be abusive spoken in the last minute or might be as signal for help|
| Dictionary    | Array of Words and phrases         | A collection of abusive phrases or words that have the highest possibilty of being used|
