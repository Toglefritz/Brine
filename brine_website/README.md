# Brine

![Brine logo](assets/brine_logo_large.png)

A website for the Brine Monitor, an IoT device that monitors the amount of salt remaining
in a water softener.

# Hello :wave:

Do you ever forget to refill the salt in your water softener? Yes you do. It is probably a safe
bet to say that everybody who has a water softener in their home forgets to refill the salt from
time to time. That "time to time" might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener
and delivers alerts when the level is low. With this tool, you can keep your water softener filled
with salt and working properly, which, in turn, will keep your appliances free of mineral deposits,
your hands and hair well-moisturized, your laundry machine effective, and spots off your dishes.

## Test locally with dhttpd

The **dhttpd** package can be used to serve a Flutter web app on a local machine for development 
and testing.

> TL;DR `dart pub global run dhttpd` inside build/web

Here are the steps you need to follow:

1. First, make sure you have Dart installed. If you have Flutter SDK installed, Dart comes along with it.
2. Now, you need to activate the "dhttpd" package by running the following command in your terminal: `dart pub global activate dhttpd`
3. Navigate to your build directory of your Flutter web application which should be "build/web" inside your project folder. You can use the command line to navigate to that directory: `cd <path to your project folder>/build/web`
4. Once you're inside your "build/web" directory, you can start the server using dhttpd: `dart pub global run dhttpd`
5. Now you can open your web browser and type in "localhost:8080". You should be able to see your Flutter web app running.
