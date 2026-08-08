# AIS Receiver

A software-defined AIS receiver developed as an electronic engineering project, combining RF electronics, PCB design, FPGA-based digital signal processing, and embedded software.

## Overview

The project focuses on the design and development of a receiver for the **Automatic Identification System (AIS)**, a VHF communication system used by vessels to exchange identification and navigation information.

The system combines a custom-designed RF receiver front-end with a **Red Pitaya** platform for signal acquisition and digital processing.

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
                │ Impedance Matching │
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
                │      │ DSP   │    │
                │      │Filtering│  │
                │      │Demod.  │   │
                │      └───┬───┘    │
                │          │        │
                │      ┌───▼───┐    │
                │      │  SoC  │    │
                │      │       │    │
                │      │Control │   │
                │      │Processing│ │
                │      └───────┘    │
                └─────────┬─────────┘
                          │
                          ▼
                   AIS Data Output
