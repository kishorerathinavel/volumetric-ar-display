#include <SPI.h>
#include <avr/io.h>
#include <avr/interrupt.h>
#include "codes.h"

const int LensPin = 6;
const int ALPpin =  35;

static const int G_CS_PIN = 24;
static const int R_CS_PIN = 25;
static const int B_CS_PIN = 26;

static const int G_CLR_PIN = 37;
static const int R_CLR_PIN = 38;
static const int B_CLR_PIN = 39;

inline void sendCommonDacCode(uint16_t code) {
  digitalWriteFast(G_CS_PIN,LOW);
  SPI.transfer16(code);
  digitalWriteFast(G_CS_PIN,HIGH);
  
  digitalWriteFast(R_CS_PIN,LOW);
  SPI1.transfer16(code);
  digitalWriteFast(R_CS_PIN,HIGH);
  
  digitalWriteFast(B_CS_PIN,LOW);
  SPI2.transfer16(code);
  digitalWriteFast(B_CS_PIN,HIGH);
}

inline void sendDacCodes(uint16_t r_code, uint16_t g_code, uint16_t b_code) {
  digitalWriteFast(G_CS_PIN,LOW);
  SPI.transfer16(g_code);
  digitalWriteFast(G_CS_PIN,HIGH);

  digitalWriteFast(R_CS_PIN,LOW);
  SPI1.transfer16(r_code);
  digitalWriteFast(R_CS_PIN,HIGH);

  digitalWriteFast(B_CS_PIN,LOW);
  SPI2.transfer16(b_code);
  digitalWriteFast(B_CS_PIN,HIGH);
}

inline void doClear() {
  //datasheet says clr must be asserted (low) for at least 15ns)
  digitalWriteFast(G_CLR_PIN,LOW);
  digitalWriteFast(R_CLR_PIN,LOW);
  digitalWriteFast(B_CLR_PIN,LOW);
  __asm__ volatile ("nop");
  __asm__ volatile ("nop");
  digitalWriteFast(G_CLR_PIN,HIGH);
  digitalWriteFast(R_CLR_PIN,HIGH);
  digitalWriteFast(B_CLR_PIN,HIGH);
}

void setupSPI() {
  pinMode(G_CS_PIN,OUTPUT);
  pinMode(R_CS_PIN,OUTPUT);
  pinMode(B_CS_PIN,OUTPUT);
  pinMode(G_CLR_PIN,OUTPUT);
  pinMode(R_CLR_PIN,OUTPUT);
  pinMode(B_CLR_PIN,OUTPUT);
  digitalWriteFast(G_CS_PIN,HIGH);
  digitalWriteFast(R_CS_PIN,HIGH);
  digitalWriteFast(B_CS_PIN,HIGH);
  digitalWriteFast(G_CLR_PIN,HIGH); 
  digitalWriteFast(R_CLR_PIN,HIGH); 
  digitalWriteFast(B_CLR_PIN,HIGH); 
  doClear();

  SPI.begin();
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV4);
  SPI.setDataMode(SPI_MODE3);   

  SPI1.begin();
  SPI1.setBitOrder(MSBFIRST);
  SPI1.setClockDivider(SPI_CLOCK_DIV4);
  SPI1.setDataMode(SPI_MODE3);   

  SPI2.begin();
  SPI2.setBitOrder(MSBFIRST);
  SPI2.setClockDivider(SPI_CLOCK_DIV4);
  SPI2.setDataMode(SPI_MODE3);   
}


void setup()   {
  Serial.begin(1*1000*1000);
  while(!Serial) {};
  Serial.println("Begin setup");
  setupSPI();

  pinMode(LensPin, INPUT);
  attachInterrupt(digitalPinToInterrupt(LensPin), ALPsteps, RISING);
  pinMode(ALPpin, OUTPUT);
}

bool disp_img = false;
int waitTime = 53;
uint16_t gcode, rcode,  bcode;
unsigned long last_time, stop_time, current_time, next_time;
// float lens_frame_time = 16720.0;
float lens_frame_time = 16665.0;
float binary_frame_time = lens_frame_time/281.0;
int imgCount = 0;
int numImg = 280;
float factor = 0.8;
void loop() {
  if(disp_img) {
    noInterrupts();
    disp_img = false;
    last_time = micros();
    next_time = 0;
    for(int i = 0; i < numImg; i++) {
      while((micros() - last_time) <= next_time) {
        //doClear();
      __asm__ volatile ("nop");
//      current_time = micros();
      	// yield();
      }
      doClear();
      // rcode = codes[i][0];
      // gcode = codes[i][1];
      // bcode = codes[i][2];
      // Serial.println("Sending Dac cde...");
      // Serial.println(rcode);
      // Serial.println(gcode);
      // Serial.println(bcode);
//      sendDacCodes(i*10, i*10, i*10);
      sendDacCodes(factor*codes[imgCount][0], factor*codes[imgCount][1], factor*codes[imgCount][2]);
//      sendDacCodes(codes[i][0], codes[i][1], codes[i][2]);
      digitalWrite(ALPpin, HIGH);
      __asm__ volatile ("nop");
      __asm__ volatile ("nop");
      digitalWrite(ALPpin, LOW);

      imgCount++;
      if(imgCount >= numImg)
        imgCount = 0;
//      delayMicroseconds(waitTime);
      // doClear();
      // last_time = micros();
      next_time = next_time + binary_frame_time;
    }

//    stop_time = micros();
//    long time_error =  lens_frame_time - (stop_time - last_time);
//    Serial.println(imgCount);
//    Serial.println(time_error);
    // waitTime = waitTime + (time_error/280);
    // Serial.println(waitTime);
    // doClear();
   interrupts();
  }
  else {
    yield();
  }
}

void ALPsteps() {
  disp_img = true;
}
