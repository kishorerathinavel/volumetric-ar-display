#include <avr/io.h>
#include <avr/interrupt.h>

const int LensPin =  2;
const int ALPpin =  4;

void setup()   {
  pinMode(LensPin, INPUT);
  attachInterrupt(digitalPinToInterrupt(LensPin), ALPsteps, RISING);
  pinMode(ALPpin, OUTPUT);
}

void loop() {
}

int waitTime = 54;
int waitTime2 = 20;

void ALPsteps() {
  for(int i = 0; i < 280; i++) {
    digitalWrite(ALPpin, HIGH);
    delayMicroseconds(waitTime2);
    digitalWrite(ALPpin, LOW);
    delayMicroseconds(waitTime - waitTime2);
  }
}
