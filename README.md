# AIS Receiver

A software-defined AIS receiver developed as an Electronic Engineering project, combining RF electronics, PCB design, FPGA-based digital signal processing, and embedded systems.

## Overview

The project focuses on the design and development of a receiver for the **Automatic Identification System (AIS)**, a VHF communication system used by vessels to exchange identification and navigation information.

The system combines a custom-designed RF front-end with a **Red Pitaya** platform for signal acquisition and digital processing.

The Red Pitaya's **FPGA and SoC** are used together to implement the digital processing chain and control the receiver.

## System Architecture

```text
                    AIS VHF Signal
                          │
                          ▼
                ┌───────────────────┐
                │    RF Front-End   │
                │                   │
                │ Filtering         │
                │ Impedance Matching│
                │ Signal Conditioning│
                └─────────┬─────────┘
                          │
                          ▼
                ┌───────────────────┐
                │     Red Pitaya    │
                │                   │
                │      ┌───────┐    │
                │      │  ADC  │    │
                │      └───┬───┘    │
                │          │        │
                │      ┌───▼───┐    │
                │      │ FPGA  │    │
                │      │       │    │
                │      │ Real- │    │
                │      │ time  │    │
                │      │ DSP   │    │
                │      └───┬───┘    │
                │          │        │
                │      ┌───▼───┐    │
                │      │  SoC  │    │
                │      │       │    │
                │      │Control│    │
                │      │ &     │    │
                │      │Processing│ │
                │      └───────┘    │
                └─────────┬─────────┘
                          │
                          ▼
                     AIS Data
```

## RF Front-End

A custom RF front-end was designed to receive and condition AIS signals before digital acquisition.

The RF design focuses on:

* 50 Ω impedance-controlled signal paths
* RF filtering
* Impedance matching
* Signal conditioning
* RF component placement
* Grounding and return-current paths
* PCB layout for RF signals

The PCB was designed using **Altium Designer**, with particular attention to signal integrity and RF routing.

## Digital Signal Processing

Signal acquisition and digital processing are performed using a **Red Pitaya** platform.

The architecture takes advantage of both the FPGA and the SoC, allowing the system to divide real-time processing and higher-level control tasks between hardware and software.

### FPGA

The FPGA is used for real-time digital processing, taking advantage of hardware parallelism and deterministic execution.

The FPGA processing chain includes signal acquisition and real-time signal processing required by the receiver.

### SoC

The SoC is used for higher-level processing, system control, and communication with the FPGA.

This hardware/software partition allows time-critical processing to be implemented in FPGA logic while higher-level operations are handled by software running on the SoC.

## PCB Design

The receiver PCB was developed using **Altium Designer**.

Particular attention was given to:

* 50 Ω RF traces
* RF component placement
* Impedance matching networks
* Filtering
* Ground planes
* Via placement
* Signal integrity
* RF routing

## AIS

The receiver is designed for AIS communications in the maritime VHF band.

AIS transmissions contain information related to vessel identification and navigation, such as:

* Vessel identification
* Position
* Course
* Speed
* Navigation information

## Technologies

* RF Electronics
* VHF Communications
* PCB Design
* Altium Designer
* Red Pitaya
* FPGA
* SoC
* Digital Signal Processing
* Embedded Systems
* Hardware/Software Co-Design
* 50 Ω RF Design

## Project Goals

The main goals of the project are:

1. Design an RF front-end suitable for AIS reception.
2. Develop a PCB with appropriate RF layout and impedance control.
3. Acquire the received signal using the Red Pitaya.
4. Implement real-time digital processing using the FPGA.
5. Use the SoC for higher-level processing and system control.
6. Integrate the RF hardware with the digital processing platform.
7. Receive and process AIS transmissions.

## Skills Demonstrated

This project combines several areas of Electronic Engineering:

* RF circuit design
* High-frequency PCB design
* Digital electronics
* FPGA development
* Embedded systems
* Digital signal processing
* SoC-based systems
* Hardware/software integration
* Signal integrity
* Communication systems

## Academic Project

Developed as part of an **Electronic Engineering** project at:

**Universidad Tecnológica Nacional (UTN)**
Facultad Regional Buenos Aires

## Authors

* Nicolás Albano
* Juan Yáñez Landa
* Kirsten Hergenreder

## Status

🚧 **In development**

The receiver hardware and digital processing chain are currently under development and testing.
