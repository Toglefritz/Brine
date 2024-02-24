# Brine Cloud Functions: Dart Frog Edition

![Brine logo](assets/icons/brine.png)

This repository contains a series of functions that, when deployed to Google Cloud, form the backend infrastructure for the Bine monitor.

# Hello :wave:

Do you ever forget to refill the salt in your water softener Yes you do. It is probably a safe bet to say that everybody who has a water softener in their home forgets to refill the salt from time to time. That "time to time" might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener and delivers alerts when the level is low. With this tool, you can keep your water softener filled with salt and working properly, which, in turn, will keep your appliances free of mineral deposits, your hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

## Overview of Dart Frog

The functions within this repository are created using Dart Frog. Dart Frog is a fast, minimalistic framework for building serverless HTTP functions in Dart. It's designed to simplify the development of microservices and APIs with Dart. Dart Frog seamlessly integrates with cloud platforms, including Google Cloud Run, which is used for the Brine cloud platform.

Another major benefit to using Dart Frog for Brine's backend infrastruture is that, because Brine also uses a companion app built using Dart/Flutter, this allows the app and the cloud platform to use the same programming language.

## Useful Dart Frog Commands

- Activate Dart Frog:

```
# 💾 Install the dart_frog cli from pub.dev
dart pub global activate dart_frog_cli
```

- Start the dev server

```
# 🏁 Start the dev server
dart_frog dev
```

- Create a production build

```
# 📦 Create a production build
dart_frog build
```