# Pump Engineering Application

## Overview

Pump Engineering Application is an engineering tool designed to support insulin pump firmware development, BLE protocol verification, debugging, and system integration testing.

This application is intended for developers, verification engineers, and quality engineers.

This application is not intended for patient use and must not be used for clinical decision making.

---

## Features

### Dashboard

Provides a high-level overview of the connected pump.

- BLE connection status
- Battery level
- Reservoir level
- Therapy state
- Recent packets
- Recent events

### Command

Provides manual command execution.

- Get Status
- Get Delivery Status
- Bolus Start
- Bolus Stop
- Raw Packet Send
- Mock Alarm Generation

### Packet Monitor

Provides packet-level BLE communication analysis.

- TX/RX monitoring
- Packet filtering
- Packet search
- Packet interpretation
- Packet detail inspection

### Event Log

Provides human-readable event history.

- Connection events
- Alarm events
- Error events
- Verification events

### Test Automation

Supports verification activities.

Current functionality:

- Bolus Delivery Verification Support
- Dose error calculation
- PASS / FAIL evaluation

### Motor Debug

Displays motor-related telemetry and diagnostic information.

Current implementation uses simulated data.

### Sensor Debug

Displays sensor telemetry information.

Current implementation uses simulated data.

---

## BLE Communication

The application supports:

- BLE Scan
- BLE Connect
- Characteristic Discovery
- Packet Transmission
- Notification Reception

Development can be performed without hardware by using the integrated MockPumpDevice framework.

---

## Mock Device

MockPumpDevice simulates:

- Status Response
- Delivery Status Response
- Bolus Response
- Progress Notification
- Completion Notification
- Alarm Notification

This allows UI and protocol development before firmware is available.

---

## Intended Use

This application is intended for:

- Firmware development
- BLE protocol validation
- System integration testing
- Debugging
- Verification support

This application is not a medical device and is not intended for patient treatment.

---

## Current Status

Implemented:

- Dashboard
- Command
- Packet Monitor
- Event Log
- Test Automation
- Motor Debug
- Sensor Debug
- Mock BLE Device
- Packet Builder
- Packet Parser
- Packet Interpreter

Planned:

- OTA Update
- Security Page
- Real BLE Integration
- Verification Automation
- CSV/JSON Export
- Device Configuration