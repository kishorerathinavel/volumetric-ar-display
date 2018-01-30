#include <SPI.h>

static const int CS_PIN = 14;
static const int CLR_PIN = 15;

static const double VREF = 2.50D;
static const double DAC_LSB = VREF / (1<<16); //volts (about 38uV)

static const int NUM_LEVELS=8;
static  uint16_t LEVELS[NUM_LEVELS];

static const unsigned long pulsePeriod=63; //us
static const unsigned long pulseLength=10; //us

const static int POT1 = 19;
const static int POT2 = 20;
const static int POT3 = 21;
const static int POT4 = 22;
//const static int POT5 = 23;
//const static ssize_t NUM_POTS=5;
const static ssize_t NUM_POTS=4;//5;

const static int POTS[NUM_POTS] = { POT1, POT2, POT3, POT4 }; //, POT5 };

inline uint16_t analogReadDecimate(int pin, int dBits) {
  unsigned long accum=0;
  int nSamples=1<<dBits;

  for(int i=0; i<nSamples; i++) {
    accum += analogRead(pin);
  }

  return accum >> dBits;
}

static uint16_t potValues[NUM_POTS] = {};

inline uint16_t readPots() {
  register uint16_t sum=0;
  for(int i=0; i<NUM_POTS; i++) {
    //potValues[i] = analogReadDecimate(POTS[i],0)>>9;
    potValues[i] = analogRead(POTS[i])>>7;
    //if(i<(NUM_POTS-1)) {
    sum += potValues[i]<<(i<<2);
    //}
  }
  return sum;
}

//inline void doClear() {
//  //datasheet says clr must be asserted (low) for at least 15ns)
//  digitalWriteFast(CLR_PIN,LOW);
//  __asm__ volatile ("nop");
//  __asm__ volatile ("nop");
//  digitalWriteFast(CLR_PIN,HIGH);
//}

long potReadTime=0;

long measurePotReadTime() {
  
  const static int numSamples=2048;

  uint16_t dummy;
  long start_time=0;
  long end_time=0;
  start_time = micros();
  for(int i=0; i<numSamples; i++) {
    dummy=readPots();
  }
  end_time = micros();
  long delta_t = end_time - start_time;
  long avg_time = delta_t / numSamples;

  Serial.println(String(numSamples) + " readPots() calls took " + String(delta_t) + " microseconds\n\t= " + String(avg_time) + " per read");
  
  return avg_time;
}


void setup() {
  Serial.begin(1*1000*1000);
  while(!Serial) {};
  Serial.println("Begin setup");
  pinMode(CS_PIN,OUTPUT);
  digitalWriteFast(CS_PIN,HIGH);
  pinMode(CLR_PIN,OUTPUT);
  digitalWriteFast(CLR_PIN,HIGH); 
  

  SPI.begin();
  SPI.setBitOrder(MSBFIRST);
  SPI.setClockDivider(SPI_CLOCK_DIV2);
  SPI.setDataMode(SPI_MODE3);   
  sendDacCode(0);

  LEVELS[0]=0xFFFF * (1.0/256); //LSB
  LEVELS[1]=0xFFFF * (1.0/128);
  LEVELS[2]=0xFFFF * (1.0/64);
  LEVELS[3]=0xFFFF * (1.0/32);
  LEVELS[4]=0xFFFF * (1.0/16);
  LEVELS[5]=0xFFFF * (1.0/8);
  LEVELS[6]=0xFFFF * (1.0/4);
  LEVELS[7]=0xFFFF * (1.0/2);  //MSB

  for(int i=0; i<NUM_POTS; i++) {
    pinMode(POTS[i], INPUT);
    //analogRead(POTS[i]);
  }

  Serial.println("Setup complete");
  analogReadResolution(11);
  analogReadAveraging(0);

  potReadTime = measurePotReadTime();
  if( ((long)pulsePeriod - (long) pulseLength - (long)potReadTime) < 0 ) {
    Serial.println("**** WARNING: pot read time is too long to accomodate pulse specifications!!.");
  }

  Serial.println("Pulse Period = " + String(pulsePeriod) + " Pulse length = " 
		 + String(pulseLength) + " --> duty cycle = " + String((100.0*pulseLength)/pulsePeriod,DEC) + "%");

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
  //unsigned long pulseLen = 10; //microseconds
  //unsigned long delayLen = 63-pulseLen;
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
  Serial.println("Set DAC value via pots.");
  uint16_t dac_code = readPots();
  uint16_t last_dac_code=dac_code;
  unsigned long start_time = 0;
  unsigned long end_time = 0;
  //unsigned long nominalDelay = pulsePeriod - pulseLength;
  while(true) {
    start_time = micros();
    end_time = start_time + pulsePeriod;
    pulseDac(dac_code,const_cast<unsigned long&>(pulseLength));
    if(micros() + potReadTime <= end_time) {
      dac_code = readPots();
      if(dac_code != last_dac_code) {
	Serial.println("Using value: " + String(dac_code,HEX) + " (" + String(dac_code) + ")");
	sendDacCode(dac_code);
	Serial.flush();
	last_dac_code=dac_code;
      }

      while(micros() < end_time) { yield(); };
        
    }

    
    //    Serial.println("Doing cal sequence. Press ENTER for next value");
    //    for(int level = 0 ; level < NUM_LEVELS; level++) {
    //      Serial.println("Level for bit " + String(level) + " code=" + String(LEVELS[level],HEX));
    //      while(Serial.available()<1) {
    //        pulseDac(LEVELS[level], pulseLen); 
    //        delayMicroseconds(delayLen); 
    //      }
    ////    for(currentValue=minValue; currentValue<=(maxValue+.01); currentValue += stepSize) {
    ////      setDacLevelVolts(currentValue);
    ////      Serial.println("Level = " + String(currentValue) + " code = 0x" + String((uint16_t)ceil((currentValue/VREF)*0xFFFF),HEX));
    //      Serial.readStringUntil('\n');
    //    }
    //    Serial.println("End of calibration loop");
    
  }//while
}



