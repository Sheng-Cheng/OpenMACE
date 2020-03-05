// This program contains both the FastLED and XBee libraries
// Attempt to send a package containing a color over the XBee connection to control the color of the LED's

#include <FastLED.h>
#include <XBee.h>
#include <SoftwareSerial.h>

/*****************************************
// FastLED setup and definitions   */

// How many leds in your strip?
#define NUM_LEDS 16

// For led chips like Neopixels, which have a data line, ground, and power, you just
// need to define DATA_PIN.  For led chipsets that are SPI based (four wires - data, clock,
// ground, and power), like the LPD8806 define both DATA_PIN and CLOCK_PIN
#define DATA_PIN 9 // was 3
#define CLOCK_PIN 13

#define  QUAD_ID 5
#define  ALL_ID 0

// Define the array of leds
CRGB leds[NUM_LEDS];

int Status(0), oldStatus(0), currentTime(0);

/******************************************
XBee setup   */

XBee xbee = XBee();
XBeeResponse response = XBeeResponse();
// create reusable response objects for responses we expect to handle 
ZBRxResponse rx = ZBRxResponse();
ModemStatusResponse msr = ModemStatusResponse();

//// Define NewSoftSerial TX/RX pins
//// Connect Arduino pin 8 to TX of usb-serial device
//uint8_t ssRX = 8;
//// Connect Arduino pin 9 to RX of usb-serial device
//uint8_t ssTX = 9;
//// Remember to connect all devices to a common Ground: XBee, Arduino and USB-Serial device
//SoftwareSerial nss(ssRX, ssTX);


void setup() {
  // put your setup code here, to run once:

Serial.begin(9600);
// Added this
Serial1.begin(9600);

//while(!Serial){};

xbee.setSerial(Serial1);  //Changed from Serial to Serial1
//nss.begin(9600);

//Serial.print("Starting up...");


FastLED.addLeds<WS2812, DATA_PIN, RGB>(leds, NUM_LEDS);

for (int i=0;i<NUM_LEDS;i++){
  
 leds[i].setRGB(100,100,100);
  FastLED.show();
}
}

void loop() {
  // XBee Loop

  xbee.readPacket();
//    Serial.println("Reading Packet...");
    if (xbee.getResponse().isAvailable()) {
      // got something
           
      if (xbee.getResponse().getApiId() == ZB_RX_RESPONSE) {
        // got a zb rx packet
        
        // now fill our zb rx class
        xbee.getResponse().getZBRxResponse(rx);
      
        Serial.println("Got an rx packet!");

        // Message Protocol:  byte 0 = QUAD_ID, byte 2-49 = RGB values for the LEDs, byte 1 = Status
        if (rx.getData()[0] == QUAD_ID || rx.getData()[0] == ALL_ID) {
//          if (rx.getData()[0] == ALL_ID) {
          for (int i=0;i<NUM_LEDS;i++){
  
              leds[i].setRGB(rx.getData()[3*i+2], rx.getData()[3*i+3], rx.getData()[3*i+4]);
              FastLED.show();
              }
//              Read Status and set
            oldStatus = Status;
            Status = rx.getData()[1];
            Serial.println("oldStatus = ");
            Serial.println(oldStatus);
            Serial.println("Status = ");
            Serial.println(Status);
        }
            
      if (rx.getOption() == ZB_PACKET_ACKNOWLEDGED) {
            // the sender got an ACK
            Serial.println("packet acknowledged");
        } else {
          Serial.println("packet not acknowledged");
     }
        
        Serial.print("checksum is ");
        Serial.println(rx.getChecksum(), HEX);

        Serial.print("packet length is ");
        Serial.println(rx.getPacketLength(), DEC);
        
         for (int i = 0; i < rx.getDataLength(); i++) {
          Serial.print("payload [");
          Serial.print(i, DEC);
          Serial.print("] is ");
          Serial.println(rx.getData()[i]);
        }
        
       for (int i = 0; i < xbee.getResponse().getFrameDataLength(); i++) {
       // Serial.print("frame data [");
        //Serial.print(i, DEC);
        //Serial.print("] is ");
        //Serial.println(xbee.getResponse().getFrameData()[i], HEX);
      }
      }
    }
//      else if (xbee.getResponse().isError()) {
//      Serial.print("error code:");
//      Serial.println(xbee.getResponse().getErrorCode());
//    }

//    Status check

if (Status == 0) {
  FastLED.setBrightness(255);
//  Serial.println("Full Brightness");
  FastLED.show();
}
if (Status == 1) {
  FastLED.setBrightness( sin8(millis()));
  FastLED.show();
}
if (Status == 2) {
  FastLED.setBrightness( sin8(millis()/10.0));
  FastLED.show();
}
//if (Status == 3) {
//  currentTime = millis();
//  while ((currentTime + 500) > millis()  ){
//  FastLED.setBrightness( sin8(millis()));
//  FastLED.show();
//  }
//  Status = oldStatus;
//}

}
