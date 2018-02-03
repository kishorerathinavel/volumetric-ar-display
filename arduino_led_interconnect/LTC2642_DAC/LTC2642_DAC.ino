#include <SPI.h>

static const int CS_PIN = 14;
static const int CLR_PIN = 15;

static const double VREF = 2.50D;
static const double DAC_LSB = VREF / (1<<16); //volts (about 38uV)

static const int NUM_LEVELS=8;
static  uint16_t LEVELS[NUM_LEVELS];


inline void doClear() {
  //datasheet says clr must be asserted (low) for at least 15ns)
  digitalWriteFast(CLR_PIN,LOW);
  __asm__ volatile ("nop");
  __asm__ volatile ("nop");
  digitalWriteFast(CLR_PIN,HIGH);
}


void setup() {
  Serial.begin(1*1000*1000);
  while(!Serial) {};
  Serial.println("Begin setup");
  pinMode(CS_PIN,OUTPUT);
  digitalWriteFast(CS_PIN,HIGH);
  pinMode(CLR_PIN,OUTPUT);
  digitalWriteFast(CLR_PIN,HIGH); 
  doClear();

  SPI.begin();
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV2);
  SPI.setDataMode(SPI_MODE3);   

  LEVELS[0]=0xFFFF * (1.0/256); //LSB
  LEVELS[1]=0xFFFF * (1.0/128);
  LEVELS[2]=0xFFFF * (1.0/64);
  LEVELS[3]=0xFFFF * (1.0/32);
  LEVELS[4]=0xFFFF * (1.0/16);
  LEVELS[5]=0xFFFF * (1.0/8);
  LEVELS[6]=0xFFFF * (1.0/4);
  LEVELS[7]=0xFFFF * (1.0/2);  //MSB
  
}

inline void sendDacCode(uint16_t code) {
  digitalWriteFast(CS_PIN,LOW);
  SPI.transfer16(code);
  digitalWriteFast(CS_PIN,HIGH);
}

inline void setDacLevelPercent(float level) {
  sendDacCode((uint16_t)ceil(level*0xFFFF));
}

inline void setDacLevelVolts(double volts) {
  if(volts<0) {
    sendDacCode(0);
  } else if(volts >=(VREF-DAC_LSB)) {
    sendDacCode(0xFFFF);
  } else {
    setDacLevelPercent(volts/VREF);
  }
  
}

inline void pulseDac(uint16_t& code, unsigned long& us) {
  unsigned long start_time=0;
  unsigned long end_time=0;

  start_time = micros();
  end_time = start_time + us;
  sendDacCode(code);
  while( micros() < end_time) {};
  sendDacCode(0);
}

void loop() {
  unsigned long pulseLen = 10; //microseconds
  unsigned long delayLen = 63-pulseLen;
//  uint16_t code=0;
//  while(true) {
//    pulseDac(code,pulseLen);
//    delayMicroseconds(5*pulseLen);
//    code = (code+1)&0x7FFF;
//  }
  Serial.println("Begin loop()\n\n");
//  double minValue=0.0;
//  double maxValue=VREF;
//  double stepSize=0.1;
//  double currentValue=minValue;
   Serial.setTimeout(30000);
  while(true) {
    Serial.println("Doing CLEAR; press ENTER to continue");
    digitalWriteFast(CLR_PIN, LOW);
    Serial.readStringUntil('\n');
    digitalWriteFast(CLR_PIN, HIGH);
    Serial.println("Doing cal sequence. Press ENTER for next value");
    for(int level = 0 ; level < NUM_LEVELS; level++) {
      Serial.println("Level for bit " + String(level) + " code=" + String(LEVELS[level],HEX));
      while(Serial.available()<1) {
        //pulseDac(LEVELS[level], pulseLen); 
        sendDacCode(LEVELS[level]);
        delayMicroseconds(delayLen); 
      }
//    for(currentValue=minValue; currentValue<=(maxValue+.01); currentValue += stepSize) {
//      setDacLevelVolts(currentValue);
//      Serial.println("Level = " + String(currentValue) + " code = 0x" + String((uint16_t)ceil((currentValue/VREF)*0xFFFF),HEX));
      Serial.readStringUntil('\n');
    }
    Serial.println("End of calibration loop");
  }
}



