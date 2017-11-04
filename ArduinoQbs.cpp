#include "Arduino.h"

int const ledPin = LED_BUILTIN;

void setup()
{
    pinMode(ledPin, OUTPUT);

    Serial.begin(115200);
    delay(1000);

    Serial.println("Start!");
}

void loop()
{
    digitalWrite(ledPin, HIGH);
    delay(500);
    digitalWrite(ledPin, LOW);
    delay(500);

    /*Serial.println("Test!");

    if (Serial.available()) {
        Serial.read();
        digitalWrite(ledPin, HIGH);
        delay(500);
        digitalWrite(ledPin, LOW);
        delay(500);
    }//*/
}
