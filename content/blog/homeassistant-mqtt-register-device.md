+++
title = "Register a new device in Homeassistant via MQTT"
date = "2020-01-09T00:00:00+00:00"
description = "In this article we are going to explore how to register a new device in Homeassistant via MQTT and how to read/write its state"
tags = ["homeassistant", "hass", "mqtt", "mosquitto", "iot"]
+++

The example that we are going to be looking at is a light hooked up to an
[ESP8266 module](https://en.wikipedia.org/wiki/ESP8266) (which comes with native support for mqtt) and turn that light on
& off via [Homeassistant](https://www.home-assistant.io/).

I make heavy use of [Docker](https://docker.com) since it's the easiest way I know to get started with
running Homeassistant and mqtt locally.

This is how you do it!

# Getting Started
## Folder structure
We are going to store the Homeassistant configuration in the following directory:

```
$ mkdir config/hass
```

## Homassistant configuration file
In `config/hass/configuration.yaml`, we are going to store the following configuration
which will be picked up when Homeassistant gets booted:

```
default_config:

mqtt:
  broker: mqtt
  discovery: true

light:
  - name: "Terrace Lamps"
    platform: mqtt
    command_topic: "home/terrace/light"
    payload_on: "1"
    payload_off: "0"
```

In here we are specifying two important things:
- We are telling Homeassistant to create a connection with an mqtt server. The
  endpoint is the DNS record `mqtt` via the `broker` property, which is setup for
  us automatically when using `docker-compose`. If we were to use something else,
  we'd have to setup the DNS record ourselves, use a service discovery provider
  or punch in the IP address.

The `default_config` has been left blank on purpose and it's mandatory for this
example to work.
## docker-compose file
Our `docker-compose.yml` file should look like this:

```
version: '3'
services:
  mqtt:
    image: eclipse-mosquitto

  hass:
    image: homeassistant/home-assistant
    ports:
    - "8123:8123"
    volumes:
      - ./config/hass:/config
    links:
    - mqtt
```

This configuration file tells docker that we want two containers:

- One that runs mqtt based on the image `eclipse-mosquitto`
- Another one that runs Homeassistant based on the image `homeassistant/home-assistant`

## Firing things up
We can bring up both services with `docker-compose` like so:

```
$ docker-compose up
```

The output is somewhat lengthy but we're interested in a couple of lines in specific
which I'm going to selectively paste below:

```
hass_1  | 2020-01-09 00:55:46 INFO (MainThread) [homeassistant.setup] Setting up mqtt
hass_1  | 2020-01-09 00:55:46 INFO (MainThread) [homeassistant.setup] Setup of domain mqtt took 0.0 seconds.
```
We can see that Homeassistant is setting up the connection with our mqtt broker.
Further, we can see the logs of the mqtt server acknowledging the connection
from the Homeassistant container:
```
mqtt_1  | 1578531346: New connection from 172.25.0.3 on port 1883.
mqtt_1  | 1578531346: New client connected from 172.25.0.3 as auto-71016E2B-550B-AE4D-523E-A9DA0D25BD25 (p2, c1, k60).
```

Last, we see that Homeassistant is configuring the light that we have defined in
the `configuration.yaml` file:
```
hass_1  | 2020-01-09 00:55:46 INFO (MainThread) [homeassistant.components.light] Setting up light.mqtt
```

Homeassistant will look through the items in that `configuration.yaml`
configuration file and find our `Terrace Lamps` and map it to the `home/terrace/light`
topic on mqtt. It also specifies the payloads for when we want to turn the thing
on (`"1"`) or off (`"2"`). How we handle those signals is up to the ESP8266 module
that will also be listening on the topic `home/terrace/light`.

## Accessing the GUI
Homeassistant will be listening on http://localhost:8123.  
Follow the setup instructions and find the `Terrace Lamps` widget waiting for you on the dashboard.

You will notice that the lamps are turned off by default. You can tweak this
configuration but that's out of the scope of this article.

What we're going to do, though, is to monitor the commands that Homeassistant
will be sending to the topic on mqtt so that we can proceed later on with the
implementation on the ESP8266 module for our lights.

## Subscribing to the topic
Homeassistant has a tool for listening on a mqtt topic directly from the GUI.
You can find that under `Developer Tools -> MQTT -> Listen to a topic`.
Punch in the topic that we're interested in, which is `home/terrace/light` and
then click on the `START LISTENING` button.

On another tab, go to Homeassistant's dashboard and try turning the Terrace Lamps
on and off; you should see the 0s and 1s coming on the Developer Tools tab.

Another way to do this is directly from your terminal using docker:

```
$ docker-compose exec mqtt mosquitto_sub -t home/terrace/light
1
0
```

In here we subscribe to the topic directly using the `mosquitto_sub` tool, passing
the topic that we're interested in using the `-t` flag.

# Summary
Registering a new device in Homeassistant via mqtt is rather trivial. There are
many more settings that you can look into, though, since Homeassistant offers
also in its API a way to register configuration settings for each device in the
network but that's topic for another article.

Happy hacking!
