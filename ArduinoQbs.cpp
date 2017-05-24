//#include "WProgram.h"
#include "Arduino.h"


void setup()
{
    pinMode(13, OUTPUT);

    Serial.begin(115200);
    delay(1000);

    Serial.println("Start!");
}

void loop()
{
    digitalWrite(13, HIGH);
    delay(500);
    digitalWrite(13, LOW);
    delay(500);

    Serial.println("Test7!");

    if (Serial.available()) {
        Serial.read();
        digitalWrite(13, HIGH);
        delay(500);
        digitalWrite(13, LOW);
        delay(500);
    }
}
