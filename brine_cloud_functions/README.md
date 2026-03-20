# Brine Cloud Functions

This repository contains a series of functions that, when deployed to Firebase, form the backend infrastructure for 
the Bine monitor.

## Hello 👋

Do you ever forget to refill the salt in your water softener? Yes you do. It is probably a safe bet to say that 
everybody who has a water softener in their home forgets to refill the salt from time to time. That "time to time" 
might even be several months in row.

The Brine water softener monitor keeps track of the amount of salt remaining in your water softener and delivers alerts 
when the level is low. With this tool, you can keep your water softener filled with salt and working properly, which, 
in turn, will keep your appliances free of mineral deposits, your hands and hair well-moisturized, your laundry machine 
effective, and spots off your dishes.

## Useful Terminal Commands for Cloud Functions Development

This section provides a list of essential terminal commands that you will find useful when working with Cloud Functions 
for Firebase. These commands facilitate the development, testing, and deployment of your functions.

### Setting Up Your Environment

1. **Login to Firebase**: Before you start, make sure you are logged in to Firebase through the CLI.

```sh
firebase login
```

This command authenticates your Firebase CLI with your Firebase account, enabling you to interact with your Firebase 
projects from the command line.

2. **Start the Firebase Emulator**: The Firebase Emulator Suite allows you to run your Cloud Functions locally, making 
development and testing faster and easier.

```sh
firebase emulators:start
```

This command starts the emulator for Cloud Functions, along with any other emulators you've configured (e.g., Firestore,
Realtime Database, Auth).

3. **Deploy a Specific Function**: To deploy a single function to Firebase, use:

```sh
firebase deploy --only functions:<functionName>
```

Replace <functionName> with the name of the function you wish to deploy. This is useful for deploying changes to a 
specific function without affecting others.

4. **View Logs for Deployed Functions**: After deploying your functions, you can view logs to monitor their behavior
 or diagnose issues.

```sh
firebase functions:log
```

Use this command to fetch and display logs from your deployed Cloud Functions. You can filter logs by function name, 
time range, and other criteria.

### Cleanup and Maintenance

1. **List All Deployed Functions**: To see a list of all the functions that you have deployed:

``` sh
firebase functions:list
```

This command provides an overview of your deployed Cloud Functions, including their names, statuses, and trigger types.

2. **Delete a Deployed Function**: If you need to remove a function that is no longer needed:

```sh
firebase functions:delete <functionName>
```

Replace <functionName> with the name of the function you wish to delete. This command removes the specified function 
from Firebase.