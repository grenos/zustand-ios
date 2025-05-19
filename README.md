# Zustand-SwiftUI (Work in progress)

A simple test project that recreates [Zustand](https://github.com/pmndrs/zustand)–style state management for SwiftUI, powered by [Boutique](https://github.com/mergesort/Boutique).

---

## Overview

This repository demonstrates how to build a lightweight, composable state store in SwiftUI—similar in spirit to JavaScript’s Zustand library. It uses [Boutique](https://github.com/mergesort/Boutique) under the hood to provide:

- **Global, shared state** that SwiftUI views can read from and write to.
- **Simple API**: subscribe to slices of state, update via closures.
- **No boilerplate**: no generated code, no macros, just plain Swift.

> ⚠️ **Note**: This is purely an experimental “proof of concept” and not production-ready. Use at your own risk!

---

## Features

- 🔄 **Reactive bindings**: SwiftUI views automatically refresh when the slice of state they depend on changes.
- 🧩 **Composable stores**: Combine multiple state slices into one centralized store.
- 🚀 **Minimal API**: Inspired by Zustand’s API style.
- 🔗 **Boutique-powered**: Leverages the [Boutique](https://github.com/mergesort/Boutique) package for state container management.

---

## Getting Started

### Requirements

- Xcode 14.0 or later  
- iOS 15.0+, macOS 12.0+  
- Swift 5.7+

### Installation

1. **Clone the repo**  
   ```bash
   git clone https://github.com/your-username/Zustand-SwiftUI.git
   cd Zustand-SwiftUI
