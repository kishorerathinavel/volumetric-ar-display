#include <SPI.h>

static const int G_CS_PIN = 24;
static const int R_CS_PIN = 25;
static const int B_CS_PIN = 26;

static const int G_CLR_PIN = 37;
static const int R_CLR_PIN = 38;
static const int B_CLR_PIN = 39;

static const double VREF = 2.50D;
static const double DAC_LSB = VREF / (1<<16); //volts (about 38uV)

static const int NUM_LEVELS=8;
static  uint16_t LEVELS[NUM_LEVELS];

SPISettings settings(/*2000000*/ SPI_CLOCK_DIV8, MSBFIRST, SPI_MODE3); 

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


void setup() {
  Serial.begin(1*1000*1000);
  while(!Serial) {};
  Serial.println("Begin setup");
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
  SPI.setClockDivider(SPI_CLOCK_DIV16);
  SPI.setDataMode(SPI_MODE3);   

  LEVELS[7]=0x5555;// * (1.0/256); //LSB
  LEVELS[6]=0x1F40;// * (1.0/128);
  LEVELS[5]=0x0FA0;// * (1.0/64);
  LEVELS[4]=0x0080;// * (1.0/32);
  LEVELS[3]=0x0040;// * (1.0/16);
  LEVELS[2]=0x0010;// * (1.0/8);
  LEVELS[1]=0x0004;// * (1.0/4);
  LEVELS[0]=0x0001;//0xFFFF * (1.0/2);  //MSB

  // LEVELS[7]=0x20FF;// * (1.0/256); //LSB
  // LEVELS[6]=0x10FF;// * (1.0/128);
  // LEVELS[5]=0x08FF;// * (1.0/64);
  // LEVELS[4]=0x04FF;// * (1.0/32);
  // LEVELS[3]=0x02FF;// * (1.0/16);
  // LEVELS[2]=0x01FF;// * (1.0/8);
  // LEVELS[1]=0x0040;// * (1.0/4);
  // LEVELS[0]=0x0008 ;//0xFFFF * (1.0/2);  //MSB

  // LEVELS[7]=0xFFFF;// * (1.0/256); //LSB
  // LEVELS[6]=0x7FFF;// * (1.0/128);
  // LEVELS[5]=0x1FFF;// * (1.0/64);
  // LEVELS[4]=0x07FF;// * (1.0/32);
  // LEVELS[3]=0x03FF;// * (1.0/16);
  // LEVELS[2]=0x01FF;// * (1.0/8);
  // LEVELS[1]=0x0040;// * (1.0/4);
  // LEVELS[0]=0x0008 ;//0xFFFF * (1.0/2);  //MSB
 
}

inline void sendCommonDacCode(uint16_t code) {
//  SPI.beginTransaction(settings);


  digitalWriteFast(G_CS_PIN,LOW);
  SPI.transfer16(code);
  digitalWriteFast(G_CS_PIN,HIGH);
  
  digitalWriteFast(R_CS_PIN,LOW);
  SPI.transfer16(code);
  digitalWriteFast(R_CS_PIN,HIGH);
  
  digitalWriteFast(B_CS_PIN,LOW);
  SPI.transfer16(code);
  digitalWriteFast(B_CS_PIN,HIGH);


//  digitalWriteFast(G_CS_PIN,LOW);
//  digitalWriteFast(R_CS_PIN,LOW);
//  digitalWriteFast(B_CS_PIN,LOW);
//  SPI.transfer16(code);
//  digitalWriteFast(G_CS_PIN,HIGH);
//  digitalWriteFast(R_CS_PIN,HIGH);
//  digitalWriteFast(B_CS_PIN,HIGH);

//  SPI.endTransaction();
}

inline void sendGreenDacCode(uint16_t code) {
  digitalWriteFast(G_CS_PIN,LOW);
  SPI.transfer16(code);
  digitalWriteFast(G_CS_PIN,HIGH);
}


inline void sendDacCodes(uint16_t g_code, uint16_t r_code, uint16_t b_code) {
  digitalWriteFast(G_CS_PIN,LOW);
  SPI.transfer16(g_code);
  digitalWriteFast(G_CS_PIN,HIGH);

  digitalWriteFast(R_CS_PIN,LOW);
  SPI.transfer16(r_code);
  digitalWriteFast(R_CS_PIN,HIGH);

  digitalWriteFast(B_CS_PIN,LOW);
  SPI.transfer16(b_code);
  digitalWriteFast(B_CS_PIN,HIGH);
}
  

inline void setDacLevelPercent(float level) {
  sendCommonDacCode((uint16_t)ceil(level*0xFFFF));
}

inline void setDacLevelVolts(double volts) {
  if(volts<0) {
    sendCommonDacCode(0);
  } else if(volts >=(VREF-DAC_LSB)) {
    sendCommonDacCode(0xFFFF);
  } else {
    setDacLevelPercent(volts/VREF);
  }
}

inline void pulseDac(uint16_t& code, unsigned long& us) {
  unsigned long start_time=0;
  unsigned long end_time=0;

  start_time = micros();
  end_time = start_time + us;
  sendCommonDacCode(code);
  while( micros() < end_time) {};
  sendCommonDacCode(0);
}

int g_level, b_level, r_level;
void loop() {
  unsigned long pulseLen = 0; //microseconds
  unsigned long delayLen = 58-pulseLen;
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
  Serial.setTimeout(5*1000);
  while(true) {
    //Serial.println("Doing CLEAR; press ENTER to continue");
    //digitalWriteFast(G_CLR_PIN, LOW);
    //digitalWriteFast(R_CLR_PIN, LOW);
    //digitalWriteFast(B_CLR_PIN, LOW);
    // Serial.readStringUntil('\n');
    //digitalWriteFast(G_CLR_PIN, HIGH);
    //digitalWriteFast(R_CLR_PIN, HIGH);
    //digitalWriteFast(B_CLR_PIN, HIGH);
    Serial.println("Doing cal sequence. Press ENTER for next value");
//
//   while(true) {
//    for(uint16_t code = 0; code < 0x1000; code = (code==0) ? 1 : code<<1) {
//      doClear();
//         sendCommonDacCode(code);
//          Serial.readStringUntil('\n');
//          Serial.println(code);
//    }
//    Serial.println("looped");
//   }


    
    for(int level = 0 ; level < NUM_LEVELS; level++) {
      g_level = level;
      r_level = (level + NUM_LEVELS/3)%NUM_LEVELS;
      b_level = (level + 2*NUM_LEVELS/3)%NUM_LEVELS;

      //g_level = level;
      //r_level = level;
      //b_level = level;

      Serial.println("Level for bit " + String(level) + " code=" + String(LEVELS[level],HEX));
      while(Serial.available()<1) {
        //pulseDac(LEVELS[level], pulseLen); 
	      sendCommonDacCode(LEVELS[level]);
        //sendGreenDacCode(LEVELS[level]);
	      //sendDacCodes(LEVELS[g_level], LEVELS[r_level], LEVELS[b_level]);
  //        delayMicroseconds(delayLen);
//        Serial.readStringUntil('\n');
      }
      //    for(currentValue=minValue; currentValue<=(maxValue+.01); currentValue += stepSize) {
      //      setDacLevelVolts(currentValue);
      //      Serial.println("Level = " + String(currentValue) + " code = 0x" + String((uint16_t)ceil((currentValue/VREF)*0xFFFF),HEX));
      // Serial.println("Exiting inner while loop");
      Serial.readStringUntil('\n');
//      doClear();
//      delayMicroseconds(10);
      // Serial.readStringUntil('\n');
    }
    Serial.println("End of calibration loop");
  }
}




