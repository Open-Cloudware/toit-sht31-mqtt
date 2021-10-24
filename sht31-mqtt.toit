// Copyright (C) 2021 Harsh Chaudhary. All rights reserved.
// Use of this source code is governed by a MIT-style license that can be
// found in the LICENSE file.

// Libraries for SHT31-D sensor
import i2c
import gpio
import sht31_d_driver.sht31

// Libraries for MQTT
import net
import mqtt
import encoding.json
import device

// Unique MQTT client ID to identify each client that connects to the MQTT broker.
CLIENT_ID ::= "$device.hardware_id"
// Home Assistant's Mosquitto MQTT broker
HOST      ::= "192.168.29.211"
// MQTT port 1883
PORT      ::= 1883
// MQTT topic name
TOPIC     ::= "/sensor/sht31"

main:
  // Set up SHT31-D sensor
  bus := i2c.Bus
    --sda=gpio.Pin 21
    --scl=gpio.Pin 22
  device := bus.device sht31.I2C_ADDRESS
  driver := sht31.Driver device

  // Set up MQTT client
  socket := net.open.tcp_connect HOST PORT
  // Connect the Toit MQTT client to the broker
  client := mqtt.Client
    CLIENT_ID
    mqtt.TcpTransport socket
    --username="mqtt-user"
    --password="test"

  // The client is now connected.
  print "Connected to MQTT Broker @ $HOST:$PORT"
  
  // Publish readings at interval of 10 seconds
  while true:
    publish client driver.read_temperature driver.read_humidity

    sleep --ms=10000


/**
  Function to publish the sensor value on MQTT topic
*/
publish client/mqtt.Client temp/float hum/float:
  // Publish message to topic
  client.publish
    TOPIC 
    json.encode {
      "temperature": "$(%0.2f temp)",
      "humidity": "$(%0.2f hum)"
    }
  print "Published message `$temp` on '$TOPIC'"  