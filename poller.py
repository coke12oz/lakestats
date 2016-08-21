#!/usr/bin/python

import rrdtool
import Adafruit_DHT

databaseFile = "/opt/lakestats/data/lake.rrd"
MIN_TEMP = -50
ERROR_TEMP = -999.99

sensor = Adafruit_DHT.DHT11
pin = 17

rrds_to_filename = {
  "a" : "/sys/bus/w1/devices/28-0416510cdcff/w1_slave",
  "b" : "/sys/bus/w1/devices/w1_bus_master1/w1_master_slave_count",
  "c" : "/sys/bus/w1/devices/w1_bus_master1/w1_master_slave_count",
}

def read_temperature(file):
  tfile = open(file)
  text = tfile.read()
  tfile.close()
  lines = text.split("\n")
  if lines[0].find("YES") > 0:
    temp = float((lines[1].split(" ")[9])[2:])
    temp /= 1000
    temp = temp * 9.0/ 5.0 + 32.0
    return temp
  return ERROR_TEMP

def read_all():
  template = ""
  update = "N:"
  for rrd in rrds_to_filename:
    template += "%s:" % rrd
    temp = read_temperature(rrds_to_filename[rrd])
    update += "%f:" % temp
  template += "d:e"
 
  humidity, temperature = Adafruit_DHT.read_retry(sensor, pin)
  temperature = temperature * 9.0/ 5.0 + 32.0
  update += "%f:%f" % (temperature, humidity) 
  #print(template)
  #print(update)
  rrdtool.update(databaseFile, "--template", template, update)

read_all()
