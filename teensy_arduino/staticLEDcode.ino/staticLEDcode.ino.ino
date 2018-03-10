#include <SPI.h>
#include <avr/io.h>
#include <avr/interrupt.h>

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

static uint16_t code = 0x0511;
void setup()   {
  Serial.begin(1*1000*1000);
  while(!Serial) {};
  Serial.println("Begin setup");
  setupSPI();
  
  sendDacCodes(code, code, code);
}

uint16_t gcode, rcode,  bcode;

void loop() {
    yield();
}


